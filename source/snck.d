module snck;

import std.range.primitives : isInputRange;
import std.stdio : File, stderr;

struct SnckConf {
    File file;
    double minSeconds = 0.1;
    bool showPercent = true;
    bool showCounter = true;
    bool showProgressBar = true;
    size_t barBlocks = 10;
    bool showElapsedTime = true;
    bool showETA = true;
    bool showSpeed = true;
    bool eraseLast = true;

    @property
    ref fd() {
        if (!this.file.isOpen) {
            this.file = stderr;
        }
        return this.file;
    }

    @property
    bool showAnyTimeStats() {
        return showElapsedTime || showETA || showSpeed;
    }
}

struct Snck(R) if (isInputRange!R) {
    import std.range.primitives : ElementType, hasLength;
    import std.array; // : empty, front, popFront;
    import std.conv : to;
    import std.datetime.stopwatch;

    R range;
    StopWatch watch = StopWatch(AutoStart.no);
    alias E = ElementType!R;
    size_t count = 0;
    Duration previous;
    SnckConf conf;
    enum rewriteLine = "\r\033[K";

    this(R range) {
        this.range = range;
        this.watch.start();
    }

    @property empty() const {
        return range.empty;
    }

    auto front() {
        return range.front();
    }

    void popFront() {
        range.popFront;
        ++count;

        with (this.conf) {
            // prevent too frequent message
            auto now = watch.peek;
            auto secs = (now - previous).total!"nsecs" * 1e-9;
            if (!range.empty && secs < minSeconds) return;
            fd.write(this.rewriteLine);

            static if (hasLength!R) {
                auto total = count + range.length;
            }

            if (showPercent) {
                static if (hasLength!R) {
                    fd.writef!"%3d%s: "(100 * count / total, "%");
                }
                fd.writef!"%d"(this.count);
                static if (hasLength!R) {
                    fd.writef!"/%d"(total);
                }
            }

            if (showProgressBar) {
                static if (hasLength!R) {
                    fd.write("|");
                    auto passed = barBlocks * count / total;
                    foreach (i; 0 .. barBlocks) {
                        if (i <= passed) {
                            fd.write("█");
                        } else {
                            fd.write(" ");
                        }
                    }
                    fd.write("|");
                }
            }

            if (showAnyTimeStats) {
                fd.writef!" [";
                if (showElapsedTime) this.printTime(now);

                static if (hasLength!R) {
                    auto fps = 1e9 * count / now.total!"nsecs";
                    if (showETA) {
                        auto remained = dur!"seconds"(to!long(range.length.to!double / fps));
                        fd.write("<");
                        this.printTime(remained);
                    }
                    if (showSpeed) fd.writef!", %.2fit/s"(fps);
                }
                fd.writef!"]";
            }

            if (this.range.empty) {
                fd.writef(eraseLast ? this.rewriteLine : "\n");
            }
            this.previous = now;
        }
    }

    void printTime(Duration d) {
        auto s = d.split!("hours", "minutes", "seconds");
        if (s.hours > 0) {
            this.conf.fd.writef!"%02d"(s.hours);
        } else {
            this.conf.fd.writef!"%02d:%02d"(s.minutes, s.seconds);
        }
    }
}

auto snck(R)(R range) {
    return Snck!R(range);
}

auto snck(R)(R range, SnckConf conf) {
    auto ret = Snck!R(range);
    ret.conf = conf;
    return ret;
}



unittest
{
    import core.thread;
    import std.range;
    foreach (i; [1, 2, 3].snck) {
        Thread.sleep(dur!"msecs"(i * 300));
    }

    foreach (i; iota(1000).snck) {
        Thread.sleep(dur!"msecs"(1));
    }

    SnckConf conf = {
        barBlocks: 20,
        minSeconds: 0.001,
        eraseLast: false,
    };
    foreach (i; iota(2000).snck(conf)) {
        Thread.sleep(dur!"msecs"(1));
    }
}

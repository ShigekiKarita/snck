module snck;

import std.range.primitives : isInputRange;


struct Snck(R) if (isInputRange!R) {
    import std.range.primitives : ElementType, hasLength;
    import std.stdio : File, stderr;
    import std.array; // : empty, front, popFront;
    import std.conv : to;
    import std.datetime.stopwatch;

    R range;
    File file;
    StopWatch watch = StopWatch(AutoStart.no);
    alias E = ElementType!R;
    size_t count = 0;
    size_t nblocks = 10;

    this(R range) {
        this.range = range;
        this.file = stderr;
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
        file.write("\r");

        // display percentage
        static if (hasLength!R) {
            auto total = count + range.length;
            file.writef!"%3d%s: "(100 * count / total, "%");
        }
        file.writef!"%d"(this.count);
        static if (hasLength!R) {
            file.writef!"/%d"(total);
        }

        // TODO display progress bar
        static if (hasLength!R) {
            file.write("|");
            auto passed = nblocks * count / total;
            foreach (i; 0 .. nblocks) {
                if (i <= passed) {
                    file.write("█");
                } else {
                    file.write(" ");
                }
            }
            file.write("|");
        }

        // display elapsed time
        file.writef!" [";
        auto elapsed = watch.peek;
        this.printTime(elapsed);
        // display estimated amount of remaining time
        static if (hasLength!R) {
            auto fps = 1e9 * count / elapsed.total!"nsecs";
            auto remained = dur!"seconds"(to!long(range.length.to!double / fps));
            file.write("<");
            this.printTime(remained);
            file.writef!", %.2fit/s"(fps);
        }
        file.writef!"]";
        file.writef("\n");

        if (this.range.empty) {
            file.writef("\n");
        }
        // file.flush();
    }

    void printTime(Duration d) {
        auto s = d.split!("hours", "minutes", "seconds");
        if (s.hours > 0) {
            file.writef!"%02d"(s.hours);
        } else {
            file.writef!"%02d:%02d"(s.minutes, s.seconds);
        }
    }
}

auto snck(R)(R range) {
    return Snck!R(range);
}



unittest
{
    import core.thread;
    foreach (i; [1, 2, 3].snck) {
        Thread.sleep(dur!"seconds"(i));
    }
}

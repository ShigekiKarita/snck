# snck

`snck` is a port of [tdqm](https://github.com/tqdm/tqdm) in D.
`snck` is an acronym of "Shi-N-Cho-Ku" that means "progress" in Japanese.

## usage

```d
import snck : snck;
import std.range;
import core.thread;

void main() {
  foreach (i; iota(3).snck) {
    Thread.sleep(dur!"seconds"(1));
  }
}
```

this code prints progress of foreach into stderr as follows:

```
 33%: 1/3|████      | [00:01<00:02, 1.00it/s]
 66%: 2/3|███████   | [00:02<00:01, 1.00it/s]
100%: 3/3|██████████| [00:03<00:00, 1.00it/s]
```


## advanced usage

you can tweak any configurations in

```d
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
}
```

for example

```d
SnckConf conf = {
  barBlocks: 20,     // more long progress bar
  minSeconds: 0.001, // more frequent updates
  eraseLast: false   // do not erase finished last stats
};

foreach (i; iota(2000).snck(conf)) {
  Thread.sleep(dur!"msecs"(1));
}
```


## TODO

- support types using `opApply`
- add unit tests

# snck

`snck` is a port of [tdqm](https://github.com/tqdm/tqdm) in D.
`snck` is an acronym of "Shi-N-Cho-Ku" that means "progress" in Japanese.

## usage

```d
import snck : snck;
import core.thread;

void main() {
  foreach (i; [1, 2, 3].snck) {
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

## TODO

- support types using `opApply`
- add unit tests

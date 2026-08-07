## Quasi-Tron

In which I attempt to re-implement
[Quazatron](https://torinak.com/qaop/play/quazatron) in
[Fennel](https://fennel-lang.org/), using [LÖVE](https://www.love2d.org/).

I have no idea how far I'll get. It's just a fun thing to try.

### Notes

I started with
[absaolutely-minimal-love2d-fennel](https://sr.ht/~benthor/absolutely-minimal-love2d-fennel/),
but stuck [fennel.lua](https://fennel-lang.org/downloads/fennel-1.6.1.lua) in
`.lib/` so [ripgrep](https://ripgrep.dev/) will ignore it. See initial commit.

I haven't bundled `fennel.lua` here. To get it:

```
$ curl -o .lib/fennel.lua https://fennel-lang.org/downloads/fennel-1.6.1.lua
```

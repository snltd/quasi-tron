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

I'm using:

- The Arch `fennel` package.
- [fennel-ls](https://xerool.net/fennel-ls/index.html). So every `love` function
  didn't show up as unknown, I added the docset:
  ```sh
  $ mkdir -p ~/.local/share/fennel-ls/docsets
  $ curl -o ~/.local/share/fennel-ls/docsets/love2d.lua https://p.hagelb.org/docsets/love2d.lua
  ```
  and a `flsproject.fnl`.
- [fnlfmt](https://github.com/frankitox/fnlfmt) for formatting, though I'm not
  crazy about some of its opinions.
- [helix](https://helix-editor.com/) with this in `languages.toml`.
  ```toml
  [[language]]
  name = "fennel"
  scope = "source.fennel"
  file-types = ["fnl"]
  roots = ["flsproject.fnl"]
  language-servers = ["fennel-ls"]
  ```

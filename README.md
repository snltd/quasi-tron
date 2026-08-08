## Quasi-Tron

[![Unit Tests](https://github.com/snltd/quasi-tron/actions/workflows/test.yml/badge.svg)](https://github.com/snltd/quasi-tron/actions/workflows/test.yml)

In which I attempt to kind-of implement some interpretation of
[Quazatron](https://torinak.com/qaop/play/quazatron) in
[Fennel](https://fennel-lang.org/), using [LÖVE](https://www.love2d.org/).

I have no idea how far I'll get. It's just a fun thing to try.

Run whatever's there with

```sh
$ love .
```

Run tests with

```sh
$ fennel --add-fennel-path ".lib/?.fnl" test/run.fnl
```

### Notes

I started with
[absaolutely-minimal-love2d-fennel](https://sr.ht/~benthor/absolutely-minimal-love2d-fennel/),
but stuck [fennel.lua](https://fennel-lang.org/downloads/fennel-1.6.1.lua) in
`.lib/` so [ripgrep](https://ripgrep.dev/) will ignore it. See initial commit.

I haven't bundled `fennel.lua` here. To get it:

```sh
$ curl -o .lib/fennel.lua https://fennel-lang.org/downloads/fennel-1.6.1.lua
```

I'm using:

- The Arch `fennel` package for runtime, with
  [`rlwrap`](https://git.sr.ht/~technomancy/faith/) for vi-bindings and history.
- [fennel-ls](https://xerool.net/fennel-ls/index.html) is my language server. So
  every `love.*` function didn't show up as unknown, I added the docset:
  ```sh
  $ mkdir -p ~/.local/share/fennel-ls/docsets
  $ curl -o ~/.local/share/fennel-ls/docsets/love2d.lua https://p.hagelb.org/docsets/love2d.lua
  ```
  and a [`flsproject.fnl`](./flsproject.fnl).
- [fnlfmt](https://github.com/frankitox/fnlfmt) for formatting. I'm not crazy
  about some of its opinions, but at least it's consistent.
- [helix](https://helix-editor.com/) is my editor, with this in `languages.toml`
  to tie together all of the above
  ```toml
  [[language]]
  name = "fennel"
  scope = "source.fennel"
  file-types = ["fnl"]
  roots = ["flsproject.fnl"]
  language-servers = ["fennel-ls"]
  ```
- [faith](https://git.sr.ht/~technomancy/faith/) for testing. The library is
  vendored in `.lib`:
  ```sh
  $ curl -o .lib/faith.fnl https://git.sr.ht/~technomancy/faith/blob/main/faith.fnl
  ```

# Bookmarks.yazi

Simple implementation of [vim-like mark's](https://neovim.io/doc/user/motion.html#mark-motions) for [yazi](https://github.com/sxyazi/yazi).

```toml
[[manager.prepend_keymap]]
on = [ "m" ]
exec = "plugin bookmarks --sync --args='set'"
desc = "Set a bookmark"
```

```toml
[[manager.prepend_keymap]]
on = [ "'" ]
exec = "plugin bookmarks --sync --args='jump'"
desc = "Jump to a bookmark"
```

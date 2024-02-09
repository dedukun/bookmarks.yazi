# Bookmarks.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin that adds the basic functionality of [vi-like marks](https://neovim.io/doc/user/motion.html#mark-motions).

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

```toml
[[manager.prepend_keymap]]
on = [ "b", "d" ]
exec = "plugin bookmarks --sync --args='delete'"
desc = "Jump to a bookmark"
```

```toml
[[manager.prepend_keymap]]
on = [ "b", "D" ]
exec = "plugin bookmarks --sync --args='deleteall'"
desc = "Jump to a bookmark"
```

# bookmarks.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin that adds the basic functionality of [vi-like marks](https://neovim.io/doc/user/motion.html#mark-motions).

> [!NOTE]
> The latest main branch of Yazi is required at the moment.

https://github.com/dedukun/bookmarks.yazi/assets/25795432/9a9fe345-dd06-442e-99f1-8475ab22fad5

## Installation

```sh
# Linux/macOS
git clone https://github.com/dedukun/bookmarks.yazi.git ~/.config/yazi/plugins/bookmarks.yazi

# Windows
git clone https://github.com/dedukun/bookmarks.yazi.git %AppData%\yazi\config\plugins\bookmarks.yazi
```

## Configuration

Add this to your `keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = [ "m" ]
exec = "plugin bookmarks --args=save"
desc = "Save current position as a bookmark"

[[manager.prepend_keymap]]
on = [ "'" ]
exec = "plugin bookmarks --args=jump"
desc = "Jump to a bookmark"

[[manager.prepend_keymap]]
on = [ "b", "d" ]
exec = "plugin bookmarks --args=delete"
desc = "Delete a bookmark"

[[manager.prepend_keymap]]
on = [ "b", "D" ]
exec = "plugin bookmarks --args=delete_all"
desc = "Delete all bookmarks"
```

---

Additionally you can enable notifications via the plugin's `setup` function in `init.lua`, the following are the default configurations:

```lua
require("bookmarks"):setup({
	notify = {
		enable = false,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})
```

For the `new` and `delete` messages, you can use `<key>` and `<folder>`, which will be replaced by the repective new/deleted bookmark's associated key and folder.

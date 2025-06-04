# bookmarks.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin that adds the basic functionality of [vi-like marks](https://neovim.io/doc/user/motion.html#mark-motions).

https://github.com/dedukun/bookmarks.yazi/assets/25795432/9a9fe345-dd06-442e-99f1-8475ab22fad5

## Requirements

- [Yazi](https://github.com/sxyazi/yazi) v25.4.8+

## Features

- Create/delete bookmarks
- Custom Notifications
- `''` to go back to the previous folder
- Bookmarks persistence

## Installation

```sh
ya pack -a dedukun/bookmarks
```

## Import/Export bookmarks

This plugin uses [Yazi's DDS](https://yazi-rs.github.io/docs/dds/) for bookmark persistence, as such,
the bookmarks are saved in DDS's state file (`~/.local/state/yazi/.dds` on Linux and `C:\Users\USERNAME\AppData\Roaming\yazi\state\.dds` on Windows)

**_NOTE:_** This system may be used by other plugins that you have installed, so this file might have more data than just the bookmarks.

## Configuration

Add this to your `keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = [ "m" ]
run = "plugin bookmarks save"
desc = "Save current position as a bookmark"

[[manager.prepend_keymap]]
on = [ "'" ]
run = "plugin bookmarks jump"
desc = "Jump to a bookmark"

[[manager.prepend_keymap]]
on = [ "b", "d" ]
run = "plugin bookmarks delete"
desc = "Delete a bookmark"

[[manager.prepend_keymap]]
on = [ "b", "D" ]
run = "plugin bookmarks delete_all"
desc = "Delete all bookmarks"
```

---

Additionally there are configurations that can be done using the plugin's `setup` function in Yazi's `init.lua`, i.e. `~/.config/yazi/init.lua`.
The following are the default configurations:

```lua
-- ~/.config/yazi/init.lua
require("bookmarks"):setup({
	last_directory = { enable = false, persist = false, mode="dir" },
	persist = "none",
	desc_format = "full",
	file_pick_mode = "hover",
	custom_desc_input = false,
	show_keys = false,
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

### `last_directory`

When enabled, a new bookmark is automatically created in `'` which allows the user to jump back to
the last directory.

There's also the option to enable persistence to this automatic bookmark.

Finally, there's a `mode` option with the following options:

| Value  | Description                                                  |
| ------ | ------------------------------------------------------------ |
| `jump` | It saves the position before the last used mark              |
| `mark` | It saves the last created mark                               |
| `dir`  | Default, it saves the last visited directory (old behaviour) |

### `persist`

When enabled the bookmarks will persist, i.e. if you close and reopen Yazi they will still be
present.

There are three possible values for this option:

| Value  | Description                                                                                                          |
| ------ | -------------------------------------------------------------------------------------------------------------------- |
| `none` | The default value, i.e., no persistance                                                                              |
| `all`  | All the bookmarks are saved in persistent memory                                                                     |
| `vim`  | This mode emulates the vim global marks, i.e., only the bookmarks in upper case (A-Z) are saved to persistent memory |

### `desc_format`

The format for the bookmark description.

There are two possible values for this option:

| Value    | Description                                                                                     |
| -------- | ----------------------------------------------------------------------------------------------- |
| `full`   | The default, it shows the full path of the bookmark, i.e., the parent folder + the hovered file |
| `parent` | Only shows the parent folder of the bookmark                                                    |

### `file_pick_mode`

The mode for choosing which directory to bookmark.

There are two possible values for this option:

| Value    | Description                                                         |
| -------- | ------------------------------------------------------------------- |
| `hover`  | The default, it uses the path of the hovered file for new bookmarks |
| `parent` | Uses the path of the parent folder for new bookmarks                |

### `notify`

When enabled, notifications will be shown when the user creates a new bookmark and deletes one or
all saved bookmarks.

By default the notification has a 1 second timeout that can be changed with `notify.timeout`.

Furthermore, you can customize the notification messages with `notify.message`.
For the `new` and `delete` messages, the `<key>` and `<folder>` keywords can be used, which will be replaced by the respective new/deleted bookmark's associated key and folder.

### `custom_desc_input`

When enabled, user can change description for new bookmark before it is saved.

By default the custom description input is filled with path.

### `show_keys`

When enabled, saving a new bookmark will display a list of all available keys.

If a key already has a saved bookmark, its description will be shown.

This helps prevent accidental overwriting of existing bookmarks.

By default no information is shown.

-- stylua: ignore
local SUPPORTED_KEYS = {
	{ on = "0"}, { on = "1"}, { on = "2"}, { on = "3"}, { on = "4"},
	{ on = "5"}, { on = "6"}, { on = "7"}, { on = "8"}, { on = "9"},
	{ on = "A"}, { on = "B"}, { on = "C"}, { on = "D"}, { on = "E"},
	{ on = "F"}, { on = "G"}, { on = "H"}, { on = "I"}, { on = "J"},
	{ on = "K"}, { on = "L"}, { on = "M"}, { on = "N"}, { on = "O"},
	{ on = "P"}, { on = "Q"}, { on = "R"}, { on = "S"}, { on = "T"},
	{ on = "U"}, { on = "V"}, { on = "W"}, { on = "X"}, { on = "Y"}, { on = "Z"},
	{ on = "a"}, { on = "b"}, { on = "c"}, { on = "d"}, { on = "e"},
	{ on = "f"}, { on = "g"}, { on = "h"}, { on = "i"}, { on = "j"},
	{ on = "k"}, { on = "l"}, { on = "m"}, { on = "n"}, { on = "o"},
	{ on = "p"}, { on = "q"}, { on = "r"}, { on = "s"}, { on = "t"},
	{ on = "u"}, { on = "v"}, { on = "w"}, { on = "x"}, { on = "y"}, { on = "z"},
}

local _send_notification = ya.sync(
	function(state, message)
		ya.notify {
			title = "Bookmarks",
			content = message,
			timeout = state.notify.timeout,
		}
	end
)

local _persist_bookmarks = ya.sync(function(state)
	ya.err("Persist Bookmarks")
	ps.sub_remote("bookmarks", function(body)
		if not state.bookmarks and body then
			state.bookmarks = {}

			for _, value in pairs(body) do
				table.insert(state.bookmarks, value)
			end
		end
	end)
end)

local _save_bookmark = ya.sync(function(_, bookmarks)
	ya.err("Save Bookmark")
	ps.pub_static(10, "bookmarks", bookmarks)
end)

local _save_last_directory = ya.sync(function(state)
	ps.sub("cd", function()
		local folder = Folder:by_kind(Folder.CURRENT)
		state.last_dir = state.curr_dir
		state.curr_dir = {
			on = "'",
			desc = tostring(folder.cwd),
			cursor = folder.cursor,
		}
	end)

	ps.sub("hover", function()
		local folder = Folder:by_kind(Folder.CURRENT)
		state.curr_dir.cursor = folder.cursor
	end)
end)

-- ***********************************************
-- **============= C O M M A N D S =============**
-- ***********************************************/

local save_bookmark = ya.sync(function(state, idx)
	local folder = Folder:by_kind(Folder.CURRENT)

	state.bookmarks = state.bookmarks or {}
	state.indexes = state.indexes or {}
	local _idx = state.indexes[idx]
	if _idx == nil then
		_idx = #state.bookmarks + 1
		state.indexes[idx] = _idx
	end

	state.bookmarks[_idx] = {
		on = SUPPORTED_KEYS[idx].on,
		desc = tostring(folder.cwd),
		cursor = folder.cursor,
	}

	if state.persist then
		_save_bookmark(state.bookmarks)
	end

	if state.notify and state.notify.enable then
		local message = state.notify.message.new
		message, _ = message:gsub("<key>", SUPPORTED_KEYS[idx].on)
		message, _ = message:gsub("<folder>", tostring(folder.cwd))
		_send_notification(message)
	end
end)

local all_bookmarks = ya.sync(function(state, append_last_dir)
	local bookmarks = {}

	if state.bookmarks then
		for _, value in pairs(state.bookmarks) do
			table.insert(bookmarks, value)
		end
	end

	if append_last_dir and state.last_dir then
		table.insert(bookmarks, state.last_dir)
	end

	return bookmarks
end)

local delete_bookmark = ya.sync(function(state, idx)
	if state.notify and state.notify.enable then
		local message = state.notify.message.delete
		message, _ = message:gsub("<key>", state.bookmarks[idx].on)
		message, _ = message:gsub("<folder>", state.bookmarks[idx].desc)
		_send_notification(message)
	end

	table.remove(state.bookmarks, idx)

	if state.persist then
		_save_bookmark(state.bookmarks)
	end
end)

local delete_all_bookmarks = ya.sync(function(state)
	state.bookmarks = nil

	if state.persist then
		_save_bookmark(nil)
	end

	if state.notify and state.notify.enable then
		_send_notification(state.notify.message.delete_all)
	end
end)

return {
	entry = function(_, args)
		local action = args[1]
		if not action then
			return
		end

		if action == "save" then
			local key = ya.which { cands = SUPPORTED_KEYS, silent = true }
			if key then
				save_bookmark(key)
			end
			return
		end

		if action == "delete_all" then
			return delete_all_bookmarks()
		end

		local bookmarks = all_bookmarks(action == "jump")
		local selected = #bookmarks > 0 and ya.which { cands = bookmarks }
		if not selected then
			return
		end

		if action == "jump" then
			ya.manager_emit("cd", { bookmarks[selected].desc })
			ya.manager_emit("arrow", { -99999999 })
			ya.manager_emit("arrow", { bookmarks[selected].cursor })
		elseif action == "delete" then
			delete_bookmark(selected)
		end
	end,
	setup = function(state, args)
		if not args then
			return
		end

		if args.save_last_directory then
			_save_last_directory()
		end

		if args.persist then
			state.persist = true
			_persist_bookmarks()
		end

		state.notify = {
			enable = false,
			timeout = 1,
			message = {
				new = "New bookmark '<key>' -> '<folder>'",
				delete = "Deleted bookmark in '<key>'",
				delete_all = "Deleted all bookmarks",
			},
		}
		if type(args.notify) == "table" then
			if type(args.notify.enable) == "boolean" then
				state.notify.enable = args.notify.enable
			end
			if type(args.notify.timeout) == "number" then
				state.notify.timeout = args.notify.timeout
			end
			if type(args.notify.message) == "table" then
				if type(args.notify.message.new) == "string" then
					state.notify.message.new = args.notify.message.new
				end
				if type(args.notify.message.delete) == "string" then
					state.notify.message.delete = args.notify.message.delete
				end
				if type(args.notify.message.delete_all) == "string" then
					state.notify.message.delete_all = args.notify.message.delete_all
				end
			end
		end
	end,
}

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

	if state.notify and state.notify.enable then
		local message = state.notify.message.new
		message, _ = message:gsub("<key>", SUPPORTED_KEYS[idx].on)
		message, _ = message:gsub("<folder>", tostring(folder.cwd))
		ya.notify {
			title = "Bookmarks",
			content = message,
			timeout = state.notify.timeout,
		}
	end
end)

local all_bookmarks = ya.sync(function(state) return state.bookmarks or {} end)

local delete_bookmark = ya.sync(function(state, idx)
	if state.notify and state.notify.enable then
		local message = state.notify.message.delete
		message, _ = message:gsub("<key>", state.bookmarks[idx].on)
		message, _ = message:gsub("<folder>", state.bookmarks[idx].desc)
		ya.notify {
			title = "Bookmarks",
			content = message,
			timeout = state.notify.timeout,
		}
	end

	table.remove(state.bookmarks, idx)
end)

local delete_all_bookmarks = ya.sync(function(state)
	state.bookmarks = nil

	if state.notify and state.notify.enable then
		ya.notify {
			title = "Bookmarks",
			content = state.notify.message.delete_all,
			timeout = state.notify.timeout,
		}
	end
end)

local test_sub = ya.sync(function()
	ya.err("TEST SUB")
	ps.sub_remote("bookmarks", function(body) ya.err("BOOKMARKS SUB", serialize(body)) end)
end)

local test_pub = ya.sync(function()
	ya.err("TEST PUB")
	ps.pub_static(10, "bookmarks", "TEST PUB")
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
			test_pub()
			return
		end

		if action == "delete_all" then
			return delete_all_bookmarks()
		end

		local bookmarks = all_bookmarks()
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

		test_sub()
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

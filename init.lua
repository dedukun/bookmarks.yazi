-- stylua: ignore
local SUPPORTED_KEYS = {
	{ on = "p" }, { on = "b" }, { on = "e" }, { on = "t" }, { on = "a" },
	{ on = "o" }, { on = "i" }, { on = "n" }, { on = "s" }, { on = "r" },
	{ on = "h" }, { on = "l" }, { on = "d" }, { on = "c" }, { on = "u" },
	{ on = "m" }, { on = "f" }, { on = "g" }, { on = "w" }, { on = "v" },
	{ on = "k" }, { on = "j" }, { on = "x" }, { on = "z" }, { on = "y" },
	{ on = "q" },
}

local save_bookmark = ya.sync(function()
	local folder = Folder:by_kind(Folder.CURRENT)
	local under_cursor_file = folder.window[folder.cursor - folder.offset + 1]
	state.bookmarks = state.bookmarks or {}
	state.bookmarks[#state.bookmarks + 1] = {
		on = SUPPORTED_KEYS[#state.bookmarks + 1].on,
		cwd = tostring(folder.cwd),
		desc = tostring(under_cursor_file.url),
		cursor = folder.cursor,
	}
end)

local all_bookmarks = ya.sync(function() return state.bookmarks or {} end)

local delete_bookmark = ya.sync(function(idx) table.remove(state.bookmarks, idx) end)

local delete_all_bookmarks = ya.sync(function() state.bookmarks = nil end)

return {
	entry = function(_, args)
		local action = args[1]
		if not action then
			return
		end

		if action == "save" then
			save_bookmark()
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
			ya.manager_emit("cd", { bookmarks[selected].cwd })
			ya.manager_emit("arrow", { -99999999 })
			ya.manager_emit("arrow", { bookmarks[selected].cursor })
		elseif action == "delete" then
			delete_bookmark(selected)
		end
	end,
}

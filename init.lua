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

local function save_bookmark(idx)
	if idx == -1 then
		return
	end

	local folder = Folder:by_kind(Folder.CURRENT)

	local key = SUPPORTED_KEYS[idx].on

	state.bookmarks = state.bookmarks or {}
	state.bookmarks[key] = { cursor = folder.cursor, path = tostring(folder.cwd) }
end

local function jump_to_bookmark(bookmark)
	state.bookmarks = state.bookmarks or {}

	local selected_bookmark = state.bookmarks[bookmark]

	ya.manager_emit("cd", { selected_bookmark.path })
	ya.manager_emit("arrow", { -99999999 })
	ya.manager_emit("arrow", { selected_bookmark.cursor })
end

local function delete_bookmark(bookmark)
	state.bookmarks = state.bookmarks or {}
	state.bookmarks[bookmark] = nil
end

local function delete_all_bookmarks()
	state.bookmarks = nil
end

local function next(sync, args)
	ya.manager_emit("plugin", { "bookmarks", sync = sync, args = table.concat(args, " ") })
end

return {
	entry = function(_, args)
		local action = args[1]
		if not action then
			return
		end

		if action == "set" then
			local key = args[2]
			if not key then
				next(false, { "_set" })
			else
				save_bookmark(tonumber(key))
			end
		elseif action == "_set" then
			local key = ya.which({
				cands = SUPPORTED_KEYS,
				silent = true,
			})

			if not key then
				-- selection was cancelled
				return
			end

			next(true, { "set", key })
		elseif action == "jump" or action == "delete" then
			local bookmark = args[2]
			if not bookmark then
				-- tried to use ya.sync but was unsuccessful, doing this way for the moment
				if state.bookmarks then
					local arguments = { "_" .. action }
					for k, _ in pairs(state.bookmarks) do
						table.insert(arguments, k)
						table.insert(arguments, state.bookmarks[k].path)
					end
					next(false, arguments)
				end
			else
				if action == "jump" then
					jump_to_bookmark(bookmark)
				elseif action == "delete" then
					delete_bookmark(bookmark)
				end
			end
		elseif action == "_jump" or action == "_delete" then
			if #args == 1 then
				-- Should never enter here, but just to be safe
				return
			end

			local marked_keys = {}
			for i = 2, #args, 2 do
				table.insert(marked_keys, { on = args[i], desc = args[i + 1] })
			end

			local selected_bookmark = ya.which({
				cands = marked_keys,
			})

			if not selected_bookmark then
				-- selection was cancelled
				return
			end

			next(true, { string.sub(action, 2), marked_keys[selected_bookmark].on })
		elseif action == "deleteall" then
			delete_all_bookmarks()
		end
	end,
}

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

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local function save_bookmark(idx)
	ya.err("SAVE BOOKMARK")

	if idx == -1 then
		return
	end

	local key = SUPPORTED_KEYS[idx].on

	state.bookmarks = state.bookmarks or {}
	state.bookmarks[key] = { cursor = 1, path = "ola" }
end

local function jump_to_bookmark()
	ya.err("JUMP TO BOOKMARK")
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

		ya.err("ARGS: " .. dump(args))

		if action == "set" then
			ya.err("SET BOOKMARK")

			local key = args[2]
			if not key then
				next(false, { "_set" })
			else
				ya.err("SET BOOKMARK")
				save_bookmark(tonumber(key))
			end
		elseif action == "_set" then
			ya.err("_SET")

			local key = ya.which({
				cands = SUPPORTED_KEYS,
				silent = true,
			})

			ya.err(key)
			next(true, { "set", key })
		elseif action == "jump" then
			ya.err("JUMP BOOKMARK")

			local key = args[2]
			if not key then
				-- tried to use ya.sync but was unsuccessful, doing this way for the moment
				if state.bookmarks then
					local arguments = { "_jump" }
					for k, _ in pairs(state.bookmarks) do
						table.insert(arguments, k)
					end
					next(false, arguments)
				end
			else
				ya.err("JUMP TO KEY: " .. key)
			end
		elseif action == "_jump" then
			ya.err("_JUMP")

			if #args == 1 then
				return
			end

			local marked_keys = {}
			for i = 2, #args, 1 do
				ya.err("I: " .. i)
				table.insert(marked_keys, { on = args[i], desc = "Jump to bookmark '" .. args[i] .. "'" })
			end

			local selected_bookmark = ya.which({
				cands = marked_keys,
			})

			next(true, { "jump", selected_bookmark })
		end
	end,
}

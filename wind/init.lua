local ltask = require "ltask"

local SERVICE_ROOT <const> = 1


local wind = {}


function wind.unique_service(name, ...)
	return ltask.call(SERVICE_ROOT, "unique_spawn", name, ...)
end


function wind.new_service(name, ...)
	return ltask.call(SERVICE_ROOT, "spawn", name, ...)
end


-- cache
local unique = {}

function wind.query(name)
	if not unique[name] then
		unique[name] = ltask.call(SERVICE_ROOT, "query", name)
	end
	return unique[name]
end


return wind
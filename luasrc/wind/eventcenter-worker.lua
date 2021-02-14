local ltask = require "ltask"

local name = string.format("Eventcenter-Worker['%s']", ...)


local subscriber = {}


local function match(event, pattern)
    for k,v in pairs(pattern) do
        if event[k] ~= v then
            return false
        end
    end
    return true
end


print(name .. " start")
local S = setmetatable({}, { __gc = function() print(name .. "exit")  end } )


function S.sub(from, id, pattern)
	subscriber[from..id] = {from = from, id = id, pattern = pattern}
end


function S.unsub(from, id)
	subscriber[from..id] = nil
end


function S.pub(from, event)
	for _,u in pairs(subscriber) do
		if match(event, u.pattern) then
			local ok = pcall(ltask.send, u.from, 'WIND_EVENT', u.id, event)
			if not ok then
				S.unsub(u.from, u.id)
			end
		end
	end
end


function S.exit()
	ltask.quit()
end


return S

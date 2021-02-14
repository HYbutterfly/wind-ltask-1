local ltask = require "ltask"
local wind = require "wind"


local worker = {}


print ("Eventcenter-Manager start")

local S = setmetatable({}, { __gc = function() print "Eventcenter-Manager exit" end } )


function S.query(name)
	if not worker[name] then
		worker[name] = wind.new_service("wind/eventcenter-worker", name)
	end
	return worker[name]
end


function S.exit()
	ltask.quit()
end


return S

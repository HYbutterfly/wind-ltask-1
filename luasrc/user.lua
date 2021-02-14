local ltask = require "ltask"
local ec = require "wind.eventcenter"
local timer = require "wind.timer"



local S = setmetatable({}, { __gc = function() print "User exit" end } )

print ("User init :", ...)


local n = 0
local function heartbeat()
	n = n + 1

	print("=========== heartbeat")
	ec.pub{ type = 'test', n = n }
end


timer.create(200, function (c)
	print("timeout", c)
	return c == 3
end, 5, function ()
	print('end')
end)



function S.ping(...)
	print("================ ping")
	ltask.timeout(10, function() heartbeat() end)
	ltask.timeout(20, function() heartbeat() end)
	ltask.timeout(30, function() heartbeat() end)
	ltask.sleep(40) -- sleep 0.4 sec
	return "PING", ...
end

function S.exit()
	ltask.quit()
end

return S

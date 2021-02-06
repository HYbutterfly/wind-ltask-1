local ltask = require "ltask"

local S = setmetatable({}, { __gc = function() print "User exit" end } )

print ("User init :", ...)

function S.ping(...)
	ltask.timeout(10, function() print(1) end)
	ltask.timeout(20, function() print(2) end)
	ltask.timeout(30, function() print(3) end)
	ltask.sleep(40) -- sleep 0.4 sec
	return "PING", ...
end

function S.exit()
	ltask.quit()
end

return S

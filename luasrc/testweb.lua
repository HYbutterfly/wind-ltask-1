local ltask = require "ltask"
local server = require "wind.httpserver"



server.get("/test", function ()
	-- body
end)

server.post("/login", function (header, data)
	print(type(data))
	return "ok"
end)



print("testweb start")
server.start('0.0.0.0', 8887)
print("testweb over")


local S = {}


return S
local ltask = require "ltask"
local server = require "wind.httpserver"
local cjson = require "cjson"



server.get("/test", function ()
	-- body
end)


server.post("/login", function (header, data)
	return {ok = true, account = data.account}
end)



server.start('0.0.0.0', 8887)




local S = {}


return S
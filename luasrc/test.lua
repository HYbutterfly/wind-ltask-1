local ltask = require "ltask"
local mongo = require "wind.mongo"
local ec = require "wind.eventcenter"
local uniqueid = require "wind.uniqueid"
local httpc = require "wind.httpclient"
local logger = require "wind.logger"
require "preload.init"

local S = setmetatable({}, { __gc = function() print "Test exit" end } )

print ("Test init :", ...)



local u = mongo.test.miss_find_one({head = 6})


dump(u)


logger.info("get test event ...")
ec.sub({type = "test"}, function (event)
	dump(event)

end)


print("userid", uniqueid.gen("userid"))
print(httpc.post("http://127.0.0.1:8081/test", '{"hello": 123}'))


function S.exit()
	ltask.quit()
end

return S

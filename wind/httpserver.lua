--
-- post body must be json
--

local timer = require "wind.timer"
local httpd = require "3rd.lsocket.samples.rshttpd"
local cjson = require "cjson"


local M = {}


local handle = {
	get = {},
	post = {}
}


function M.get(path, func)
	handle.get[path] = func
end


function M.post(path, func)
	handle.post[path] = func
end


local started = false

function M.start(ip, port)
	assert(started == false)
	local server = httpd.new(ip, port, 1000, print)


	local function handle_request(method, path, ...)
		local func = handle[method][path]
		if func then
			local ok, err = pcall(func, ...)
			if ok then
				assert(type(err) == "table")
				return "200", cjson.encode(err)
			else
				print("httpserver error", err)
				return "500", err
			end
		else
			local err = string.format("httpserver no handle method:'%s', path:'%s'", method, path)
			print(err)
			return "500", err
		end
	end


	server:addhandler("get", function (rq, header)
		return handle_request("get", rq.path, header)
	end)


	server:addhandler("post", function (rq, header, data)
		local ok, err
		if data ~= "" then
			ok, err = pcall(cjson.decode, data)
			if not ok then
				return "400", err
			end
			data = err
		else
			data = {}
		end
		return handle_request("post", rq.path, header, data)
	end)


	started = true
	print(string.format("httpserver listen on %s:%d", ip, port))

	
	timer.create(1, function ()
		server:step(0.1)
	end, -1)
end



return M
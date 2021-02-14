local ltask = require "ltask"
local root = require "ltask.root"

local SERVICE_GATEWAY <const> = 4

local config = ...

local S = {}

do
	-- root init response to itself
	local function init_receipt(type, msg , sz)
		if type == config.MESSAGE_ERROR then
			print("Root init error:", ltask.unpack(msg, sz))
		end
	end

	ltask.suspend(0, coroutine.create(init_receipt))
end

local function init_service(address, name, ...)
	root.init_service(address, "@"..config.service)
	ltask.syscall(address, "init", config.service_path .. name..".lua", ...)
end

-- todo: manage services

local SERVICE_N = 0
local unique = {}

function S.spawn(name, ...)
	local address = assert(ltask.post_message(0, 0, config.MESSAGE_SCHEDULE_NEW))
	local ok, err = pcall(init_service, address, name, ...)
	if not ok then
		ltask.post_message(0,address,config.MESSAGE_SCHEDULE_DEL)
		error(err)
	end
	print("SERVICE NEW", name, address)
	SERVICE_N = SERVICE_N + 1
	return address
end

function S.unique_spawn(name, ...)
	assert(not unique[name], name)
	unique[name] = S.spawn(name, ...)
	return unique[name]
end

function S.query(name)
	return unique[name]
end


local function kill(address)
	if ltask.post_message(0, address, config.MESSAGE_SCHEDULE_HANG) then
		-- address must not in schedule
		root.close_service(address)
		ltask.post_message(0,address,config.MESSAGE_SCHEDULE_DEL)
		return true
	end
	return false
end

function S.quit()
	local s = ltask.current_session()
	SERVICE_N = SERVICE_N - 1
	kill(s.from)
	ltask.no_response()

	if SERVICE_N == 0 then
		-- Only root alive
		for _, id in ipairs(config.exclusive) do
			ltask.send(id, "QUIT")
		end
		ltask.quit()
	end
end

local function boot()
	print "Root init"
	print(os.date("%c", (ltask.now())))
	local addr = S.spawn("user", "Hello")
	print(ltask.call(addr, "ping", "PONG"))
	print(ltask.send(addr, "ping", "SEND"))
	ltask.send(addr, "exit")
	print(ltask.send(addr, "ping", "SEND"))
end

local function my_boot()
	print "Root init"
	S.unique_spawn('wind/logger')
	S.unique_spawn('wind/eventcenter-manager')
	S.unique_spawn('wind/uniqueid')
	
	local usr = S.spawn('user')
	S.spawn('test')
	
	ltask.call(usr, "ping")
	ltask.send(SERVICE_GATEWAY, "start")

	S.unique_spawn("wind/logind")
end

ltask.dispatch(S)

my_boot()

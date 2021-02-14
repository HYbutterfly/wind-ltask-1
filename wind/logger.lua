local ltask = require "ltask"
local wind = require "wind"


local function server()
	return wind.query("wind/logger")
end


local from = ltask.self()
local logger = {}


function logger.info(...)
	ltask.send(server(), 'info', from, ...)
end


function logger.warn(...)
	ltask.send(server(), 'warn', from, ...)
end


function logger.error(...)
	ltask.send(server(), 'error', from, ...)
end



return logger
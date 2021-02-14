local LOG_LEVEL_INFO <const> = 1
local LOG_LEVEL_WARN <const> = 2
local LOG_LEVEL_ERROR <const> = 3

local ltask = require "ltask"
local conf = require "conf"
local daemon = conf.daemon
local limit = conf.log_level or 1

local day, today, filename, file


local function get_filename()
	local day = os.date("%Y%m%d")
	return day, "logs/" .. day .. ".log"
end


if daemon then
	day, filename = get_filename()
	local err; file, err = io.open(filename, "a")
	assert(file, err)
end



local function write2file(text)
	today, filename = get_filename()
	if today ~= day then
		file:close()
		day = today
		file = io.open(filename, "a")
	end
	file:write(text)
	file:write('\n')
	file:flush()
end


local function write_log(lv, from, ...)
	if lv >= limit then
		local from = string.format("[%05d]", from)
		local time = os.date("%H:%M:%S")
		local log = {from, time, ...}
		for i,v in ipairs(log) do
			log[i] = tostring(v)
		end

		local str = table.concat(log, " ")
		print(str)
		if daemon then
			write2file(str)
		end
	end
end


local S = {}


function S.info(...)
	write_log(LOG_LEVEL_INFO, ...)
end


function S.warn(...)
	write_log(LOG_LEVEL_WARN, ...)
end


function S.error(...)
	write_log(LOG_LEVEL_ERROR, ...)
end


return S
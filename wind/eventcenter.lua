local ltask = require "ltask"
local wind = require "wind"


local worker_cache = {}

local function query_worker(name)
	if not worker_cache[name] then
		local mgr = wind.query("wind/eventcenter-manager")
		worker_cache[name] = ltask.call(mgr, "query", name)
	end
	return worker_cache[name]
end


local ec = {}


local subscriber = {}

function ec.sub(pattern, callback, limit)
    local worker = query_worker(assert(pattern.type))

    limit = limit or math.huge
    local u = {pattern = pattern, callback = callback, limit = limit, count = 0}
    local id = tostring(u):sub(10, -1) -- "0x123456789012"
    ltask.call(worker, "sub", ltask.self(), id, pattern)
    subscriber[id] = u

    function u.unsub()
        if subscriber[id] then
            subscriber[id] = nil
            ltask.send(worker, "unsub", ltask.self(), id)
        end
    end

    return u
end


function ec.sub_once(pattern, callback)
	return ec.sub(pattern, callback, 1)
end


function ec.pub(event)
	local worker = query_worker(event.type)
	ltask.send(worker, "pub", ltask.self(), event)
end


function ltask.handle_wind_event(id, event)
	local u = subscriber[id]
	if u then
	    u.callback(event)
	    u.count = u.count + 1
	    if u.count >= u.limit then
	        u.unsub()
	    end
	end
end



return ec
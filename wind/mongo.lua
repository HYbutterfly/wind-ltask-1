local ltask = require "ltask"
local miss = require "lualib.miss-mongo"

local SERVICE_DB_MONGO <const> = 3


local mongo = {}


local function miss_one(coll, o)
    local query = {_id = o._id}
    local event = {}

    function event.assign(k, v)
        mongo.update(coll, query, {["$set"] = {[k] = v}})
    end

    function event.unset(k)
        mongo.update(coll, query, {["$unset"] = {[k] = ""}})
    end

    function event.tpush(k, v)
        mongo.update(coll, query, {["$push"] = {[k] = v}})
    end

    function event.tinsert(k, index, v)
        mongo.update(coll, query, {["$push"] = {
            [k] = {
                ["$each"] = {v},
                ["$position"] = index
            }
        }})
    end

    function event.tpop(k, i)
        mongo.update(coll, query, {["$pop"] = {[k] = i}})
    end

    local function handler(e, ...)
        -- print("miss:", e, ...)
        local f = event[e]
        f(...)
    end

    local proxy = miss.miss(o, handler)
    return proxy
end



function mongo.count(...)
	return ltask.call(SERVICE_DB_MONGO, 'count', ...)
end


function mongo.update(...)
	return ltask.call(SERVICE_DB_MONGO, 'update', ...)
end


function mongo.remove(...)
	return ltask.call(SERVICE_DB_MONGO, 'remove', ...)
end


function mongo.find_all(...)
	return ltask.call(SERVICE_DB_MONGO, 'find_all', ...)
end


function mongo.find_one_or_insert(coll, query, obj)
    if not obj then
        obj = assert(fields)
        fields = nil
    end
    local one = mongo.find_one(coll, query, fields)
    if not one then
        one = obj
        one._id = mongo.insert(coll, obj)
    end
    return one
end


function mongo.find_one(...)
	return ltask.call(SERVICE_DB_MONGO, 'find_one', ...)
end


function mongo.insert(...)
	return ltask.call(SERVICE_DB_MONGO, 'insert', ...)
end

-- miss
function mongo.miss_find_one_or_insert(coll, ...)
    local o = mongo.find_one_or_insert(coll, ...)
    return miss_one(coll, o)
end


function mongo.miss_find_all(coll, ...)
    local obj_list = mongo.find_all(coll, ...)
    for i,o in ipairs(obj_list) do
        obj_list[i] = miss_one(coll, o)
    end
    return obj_list
end


function mongo.miss_find_one(coll, ...)
    local o = mongo.find_one(coll, ...)
    if o then
        return miss_one(coll, o)
    end
end


function mongo.miss_insert(coll, o)
    o._id = mongo.insert(coll, o)
    return miss_one(coll, o)
end



local cache = {}

local function collection(coll)
    local c = cache[coll]
    if not c then
        c = setmetatable({}, {__index = setmetatable({}, {__index = function (_, k)
            return function (...)
                local f = assert(mongo[k], k)
                return f(coll, ...)
            end
        end})})
        cache[coll] = c
    end
    return c
end

return setmetatable({}, {__index = function(_, coll)
    return collection(coll)
end})
local ltask = require "ltask"
local db = require "wind.mongo"
local conf = require "conf.uniqueid"

local create = {}

function create:inc_num()
	local name = assert(self.name)
	local start_num = assert(self.start_num)
	local doc

	if self.persistent then
		doc = db[conf.collname].miss_find_one {name = name}
		if doc then
			assert(doc.type == "inc_num")
		else
			doc = db[conf.collname].miss_insert {name = name, type = "inc_num", start = start_num, last = start_num}
		end
	else
		doc = {name = name, start = start_num, last = start_num}
	end

	function self.gen()
		doc.last = doc.last + 1
		return tostring(math.floor(doc.last))
	end

	function self.free()
		-- pass
	end

	return self
end


function create:random_num()
	local name = assert(self.name)
	local length = self.length or 6
    local doc

    if self.persistent then
        doc = db[conf.collname].miss_find_one {name = name}
        if doc then
            assert(doc.type == "random_num")
        else
            doc = db[conf.collname].miss_insert {name = name, type = "random_num", generated = {}}
        end
    else
        doc = {name = name, generated = {}}
    end

    local self = {}
    
    function self.gen()
        local id
        repeat
            id = tostring(math.random(10^(length-1)+1, 10^length-1))
        until not doc.generated[id]
        doc.generated[id] = true
        return id
    end

    function self.free(id)
        doc.generated[id] = nil        
    end

    return self
end


print("uniqueid start")
local generator = {}

for _,v in ipairs(conf.uniqueid_list) do
	generator[v.name] = create[v.type](v)
end



local S = {}


function S.gen(name)
    local uid = assert(generator[name], string.format("Undefined generator:%s, see conf/uniqueid.lua", name))
    return uid.gen()
end


function S.free(name, id)
    local uid = assert(generator[name], string.format("Undefined generator:%s, see conf/uniqueid.lua", name))
    return uid.free(id)
end


return S
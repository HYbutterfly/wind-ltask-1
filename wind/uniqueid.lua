local ltask = require "ltask"
local wind = require "wind"


local uniqueid = {}


function uniqueid.gen(name)
    return ltask.call(wind.query("wind/uniqueid"), "gen", name)
end


function uniqueid.free(name, id)
    return ltask.send(wind.query("wind/uniqueid"), "free", name, id)
end


return uniqueid
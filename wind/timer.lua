local ltask = require "ltask"


local cancel_map = {}


local M = {}

function M.create(delay, func, iteration, on_end)

    local now = ltask.now()

    local count = 0
    local iteration = iteration or 1
    local destroy = false

     local function cancel()
        destroy = true
        cancel_map[cancel] = nil
    end

    local function gen_timeout()
    	ltask.timeout(delay, function ()
    		if destroy then
    			return
    		end
    		count = count + 1
    		destroy = func(count)
    		if destroy or (iteration > 0 and count >= iteration) then
    			if on_end then
    				cancel()
    				on_end(count)
    			end
    		else
    			gen_timeout()
    		end
    	end)
    end


    cancel_map[cancel] = true
    gen_timeout()

    return cancel
end


function M.destroy_all()
	for c,_ in pairs(cancel_map) do
		c()
	end
	cancel_map = {}
end



return M
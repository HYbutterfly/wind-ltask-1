local ltask = require "ltask"
local socket = require "socket"

local quit = false


local function dispatch_messages()
    local from, session, type, msg, sz = ltask.recv_message()
    if from then
        if from == SERVICE_ROOT then
            local command = ltask.unpack_remove(msg, sz)
            if command == "QUIT" then
                quit = true
            end
        else
            print("Gateway message : ", from, ltask.unpack_remove(msg, sz))
        end
        return true
    end
end


local server = assert(socket.bind("127.0.0.1", 8888))
local sock_tab = {server}


local function remove_client(client)
    for i,v in ipairs(sock_tab) do
        if v == client then
            return table.remove(sock_tab, i)
        end
    end
end

local function close_server()
    for _,sock in ipairs(sock_tab) do
        sock:close()
    end
end


print("Gateway start, Listen on 8888")
while not quit do
    local recvt = socket.select(sock_tab, nil, 0.1)
    if #recvt > 0 then
        for _,sock in ipairs(recvt) do
            if sock == server then
                local client = server:accept()
                if client then
                    sock_tab[#sock_tab+1] = client 
                end
            else
                local line, err = sock:receive()
                if line then
                    print("recv:", line)
                    sock:send(line..'\n')
                else
                    print("err:", err)
                    client:close()
                    remove_client(client)
                end
            end
        end
    else
        dispatch_messages()
    end
end
close_server()
print "Gateway quit"
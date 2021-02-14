local SERVICE_ROOT <const> = 1

local ltask = require "ltask"
local ls = require "lsocket"


local quit = false
local started = false

local server, sockets
local socketinfo = {}


local function add_socket(sock, ip)
    sockets[#sockets+1] = sock
    socketinfo[sock] = ip
end


local function remove_socket(sock)
    for i, s in ipairs(sockets) do
        if s == sock then
            table.remove(sockets, i)
            socketinfo[sock] = nil
            return
        end
    end
end


local REQUEST = {}


local function handle_request(cmd, ...)
    print("handle_request", cmd, ...)
    local f = REQUEST[cmd]
    return f(...)
end


local function server_start()
    assert(started == false)
    server, err = ls.bind("tcp", "0.0.0.0", 8888)
    if not server then
        return print(err)
    end

    sockets = {server}
    started = true
    print("gateway listen on ", 8888)
end


local function do_server()
    local ready = ls.select(sockets, 0)
    if ready then
        for _, s in ipairs(ready) do
            if s == server then
                local s1, ip, port = s:accept()
                print("Connection from "..ip..":"..port)
                add_socket(s1, ip)
            else
                local str, err = s:recv()
                if str ~= nil then
                    str = string.gsub(str, "\n$", "")
                    s:send("You sent: "..str.."\n")
                elseif err == nil then
                    s:close()
                    remove_socket(s)
                else
                    print("error: "..err)
                end
            end
        end
        return true
    end
end


print("gateway start")
while not quit do
    local from, session, type, msg, sz = ltask.recv_message()

    if from then
        if from == SERVICE_ROOT then
            local command = ltask.unpack_remove(msg, sz)
            if command == 'QUIT' then
                quit = true
            else
                assert(command == 'start')
                server_start()
            end
        else
            local r = handle_request(ltask.unpack_remove(msg, sz))
            exclusive.send(from, session, MESSAGE_RESPONSE, ltask.pack(r))
        end
        coroutine.yield()
    else
        if started then
            while do_server() do end
        end
        coroutine.yield()
    end
end
print("gateway exit")
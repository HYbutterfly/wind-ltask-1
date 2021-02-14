local ls = require "lsocket"


local function parse_reply(reply)
	local body = ""
	local n = reply:find('\r\n')
	local firstline = reply:sub(1, n-1)
	local code, info = firstline:match "HTTP/[%d%.]+%s+([%d]+)%s+(.*)$"
	code = assert(tonumber(code))

	n = reply:find('\r\n\r\n')
	if n then
		body = reply:sub(n+4, -1)
	end

	return code, body
end


local function request(host, port, method, path, header, content)
	content = content or ""
	sock, err = ls.connect(host, port)
	if not sock then
		return nil, err
	end

	ls.select(nil, {sock})
	local ok, err = sock:status()
	if not ok then
		return nil, err
	end

	local host_info = host..":"..port
	local header_content = ""
	if header then
		if not header.host then
			header.host = host_info
		end
		for k,v in pairs(header) do
			header_content = string.format("%s%s:%s\r\n", header_content, k, v)
		end
	else
		header_content = string.format("host:%s\r\n", host_info)
	end

	local rq = string.format("%s %s HTTP/1.1\r\n%scontent-length:%d\r\n\r\n%s", method, path, header_content, #content, content)

	ls.select(nil, {sock})
	assert(#rq == sock:send(rq))

	ls.select({sock})
	local reply = ""
	local str, err
	repeat
		ls.select({sock})
		str, err = sock:recv()
		if str then
			reply = reply .. str
		elseif err then
			error(err)
		end
	until not str
	return parse_reply(reply)
end



local M = {}


local function parse_url(url)
	local host, port, path = string.match(url, "^http://([^:/]+):?(%d*)(/?.*)$")
	if not host then
		error("invalid url.")
	end
	if #port == 0 then port = 80 end
	if #path == 0 then path = "/" end
	return host, port, path
end


function M.get(url, header)
	local host, port, path = parse_url(url)
	return request(host, port, 'GET', path, header)
end


function M.post(url, body, header)
	local host, port, path = parse_url(url)
	return request(host, port, 'POST', path, header, body)
end



return M
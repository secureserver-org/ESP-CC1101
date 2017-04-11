-- ESP-CC1101 https://github.com/sam210723/ESP-CC1101
-- HTTP server

local creds = require "creds"

local server = {}

function server.begin(port)
  local srv = net.createServer(net.TCP)

  srv:listen(port,
    function(socket)
      socket:on("receive",
        function(socket, payload)
          print("TCP_PEER=" .. socket:getpeer())
          handleReq(socket, payload)
        end
      )

      -- Close socket once response has been sent
      socket:on("sent",
        function(socket)
          socket:close()
        end
      )
    end
  )

  print("TCP_LISTENING")
end

function genRes(socket, url, method)
  if url == "/" then
    socket:send(httpRes(200, '{"code":200,"status":"OK"}'))
  elseif url == "/help" then
    socket:send(httpRes(200, readAll("help.json")))
  elseif url == "/433" then
    if method == "GET" then
      socket:send(httpRes(200, '{"/433":"GET","code":200,"status":"OK"}'))
    elseif method == "POST" then
      socket:send(httpRes(200, '{"/433":"POST","code":200,"status":"OK"}'))
    else
      socket:send(httpRes(404, '{"code":404,"status":"Not Found"}'))
    end
  end
end

function handleReq(socket, payload)
  local req = getReqDetails(payload)

  local urls = {"/", "/help", "/433"}

  -- If client is authorized
  if req.auth == creds.http then
    -- If URL exists
    if tableHasValue(urls, req.path) then
      genRes(socket, req.path, req.method)
    else -- If URL does not exist
      socket:send(httpRes(404, '{"code":404,"status":"Not Found"}'))
    end
  else -- If client is not authorized
    socket:send(httpRes(401, '{"code":401,"status":"Access Denied"}'))
  end
end

function httpRes(code, body)
  if code == 200 then
    code = "200 OK"
  elseif code == 401 then
    code = "401 Access Denied"
  elseif code == 404 then
    code = "404 Not Found"
  end

  if body == nil then
    body = ""
  end

  return  "HTTP/1.1 " .. code .. "\r\n" ..
          "Content-Type: application/json\r\n" ..
          "Connection: Closed\r\n" ..
          "WWW-Authenticate: Basic realm=\"ESP-CC1101\"\r\n" ..
          "\r\n" .. body
end

function getReqDetails(payload)
  local details = {}

  -- Split request into lines
  local reqLines = split(payload, "\r\n")

  -- Split first request line by spaces, first word is method, second is path
  details.method = split(reqLines[1], " ")[1] -- HTTP Method
  details.path = split(reqLines[1], " ")[2] -- URL

  -- Loop through request lines to find Authorization header
  for i, line in ipairs(reqLines) do
    if string.match(line, "Authorization: ") then
      details.auth = split(line, " ")[3] -- Only base64 encoded key (assumed basic auth)
    end
  end

  return details
end

function split(str, delim)
    local result,pat,lastPos = {},"(.-)" .. delim .. "()",1
    for part, pos in string.gfind(str, pat) do
        table.insert(result, part); lastPos = pos
    end
    table.insert(result, string.sub(str, lastPos))
    return result
end

function tableHasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function readAll(f)
  if file.open(f, "r") then
    content = file.read()
    file.close()
  end

  return content
end

return server

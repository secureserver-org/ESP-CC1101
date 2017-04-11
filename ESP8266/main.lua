-- ESP-CC1101 https://github.com/sam210723/ESP-CC1101
-- Main

local networking = require "networking"
local server = require "server"

networking.setup()
server.begin(80)

-- ESP-CC1101 https://github.com/sam210723/ESP-CC1101
-- Networking Module

local networking = {}

local creds = require "creds"

function networking.setup()
  wifi.setmode(wifi.STATIONAP)

  apSetup()
  wifiSetup()
end

function apSetup()
  -- Access Point setup
  ap_cfg = {
    ssid = "SDR",
    pwd = "greatscott",
    auth = wifi.WPA2_PSK,
    channel=10
  }
  ap_ip_cfg = {
    ip = "192.168.0.1",
    netmask = "255.255.255.0",
    gateway = "192.168.0.1"
  }
  wifi.ap.setip(ap_ip_cfg)
  wifi.ap.config(ap_cfg)

  print("AP_ACTIVE")
  print("AP_IP=" .. wifi.ap.getip())
end

function wifiSetup()
  -- WiFi setup
  station_cfg = {
    ssid = creds.ssid,
    pwd = creds.pwd
  }
  wifi.sta.config(station_cfg)

  print("WIFI_CONNECTING")
  wifi.sta.connect()

  -- Wait for WiFi IP with timeout
  connectTime = tmr.now()
  tmr.alarm(1, 1000, 1,
    function()
      timeout = 15000 * 1000 -- 15s in us
      if wifi.sta.status() == wifi.STA_GOTIP then
        tmr.stop(1)
        print("WIFI_CONNETED")
        print("WIFI_IP=" .. wifi.sta.getip())
      else -- Timeout
        if tmr.now() - connectTime > timeout then
          tmr.stop(1)
          print("WIFI_TIMEOUT")
        end
      end
    end
  )
end

return networking

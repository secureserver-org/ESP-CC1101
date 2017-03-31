function wifiSetup()
  local creds = require "creds"

  wifi.setmode(wifi.STATIONAP)

  -- Access Point setup
  ap_cfg = {
    ssid = "Yard Stick",
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
        tcpServerSetup()
      else -- Timeout
        if tmr.now() - connectTime > timeout then
          tmr.stop(1)
          print("WIFI_TIMEOUT")
          tcpServerSetup()
        end
      end
    end
  )
end

-- Start TCP server
function tcpServerSetup()
  srv=net.createServer(net.TCP)
  srv:listen(80,
    function(conn)
      conn:on("receive",
        function(conn, payload)
          print("TCP_PEER="..conn:getpeer())
          handlePeer(conn, payload)
        end
      )
      conn:on("sent",
        function(conn)
          conn:close()
        end
      )
    end
  )

  print("TCP_LISTENING")
end

-- Handle HTTP requests
function handlePeer(conn, payload)
  conn:send("HTTP/1.1 200 OK\r\n" ..
            "Content-Type: application/json\r\n" ..
            "Connection: Closed\r\n" ..
            "\r\n" ..
            '{"some":"json"}'
  )
end

wifiSetup()

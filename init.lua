require ('credentials')
require('ds18b20.lua')

function meter_and_report()
    wifi.sleeptype(wifi.NONE_SLEEP)
    tmr.stop(0)
    conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) print(payload) end)
    conn:connect(80, credentials.ip)
    temp = meter:read()
    print("T = "..temp.."C")

    conn:send("GET /lampotila/index.php/save/"..credentials.key.."?tem1="..temp.." HTTP/1.1\r\n")
    conn:send("Accept: */*\r\n") 
    conn:send("Host: sompasauna.fi\r\n")
    conn:send("User-Agent: SompaMeter/1.0 (compatible; esp8266 Lua;)\r\n")
    conn:send("\r\n")
    temp = nil
    conn:on("sent",function(conn)
        print("Closing connection")
        conn:close()
    end)
    conn:on("disconnection", function(conn) 
        print("Got disconnection...")
        wifi.sleeptype(wifi.MODEM_SLEEP)
        conn = nil
        -- Emergency fix for lost ip propblem
        tmr.alarm(0, 60000, 1, function() node.restart() end )
        -- tmr.alarm(0, 60000, 1, function() meter_and_report() end )
    end)
end

print ("initializing network")
wifi.setmode(wifi.STATION)
wifi.sta.config(credentials.ssid, credentials.pwd)
wifi.sta.connect()

tmr.alarm(1, 1000, 1, function() 
    if wifi.sta.getip()== nil then 
        print("IP unavailable, Waiting...") 
    else 
        tmr.stop(1)
        print("Config done, IP is "..wifi.sta.getip())
        meter_and_report()
    end 
end)

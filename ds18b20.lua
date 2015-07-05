--'
-- 18b20 one wire example for NODEMCU
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Vowstar <vowstar@nodemcu.com>
--' 

-- mofied version to behave more like library
pin = 7 --pin for one wire library

meter = {
    addr=0,
    read=function(self)
        local result = nil
        ow.setup(pin)
        local crc = ow.crc8(string.sub(self.addr,1,7))
        if (crc == self.addr:byte(8)) then
            if ((self.addr:byte(1) == 0x10) or (self.addr:byte(1) == 0x28)) then
            ow.reset(pin)
            ow.select(pin, self.addr)
            ow.write(pin, 0x44, 1)
            local present = ow.reset(7)
            ow.select(pin, self.addr)
            ow.write(pin,0xBE,1)
            local data = nil
            data = string.char(ow.read(pin))
            for i = 1, 8 do
                data = data .. string.char(ow.read(pin))
            end
            local crc = ow.crc8(string.sub(data,1,8))
            if (crc == data:byte(9)) then
                result = (data:byte(1) + data:byte(2) * 256)
                if (result > 32767) then
                    result = result - 65536
                end
                result = result * 625
                result = result / 10000
                return result
            end
            tmr.wdclr()
        end
    return result
    end 
end
}

-- Initialize the meter
ow.setup(pin)
ow.skip(pin)
ow.write(pin, 0x44, 1)
tmr.wdclr() 
tmr.delay(750000)
ow.reset_search(pin)
ow.target_search(7,0x28)
-- for some reason my meter is always 2nd one
-- skip search loop here
addr = ow.search(pin)
print(addr)
addr = ow.search(pin)
print(addr)
meter.addr=addr
tmr.wdclr()
ow.reset_search(pin)

local pico = dofile("../src/pico.lua")
pico.init(true)

local phy = pico.get_size().phy
local log = pico.get_size().log

print(phy.x)
print(log.x)
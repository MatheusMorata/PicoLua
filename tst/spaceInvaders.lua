local pico = dofile("../src/pico.lua")
local utils = dofile("utils.lua")

pico.init(true)

utils.nave(pico)   
utils.inimigos(pico) 


while true do
    pico.input.delay(16)
end

pico.init(false)
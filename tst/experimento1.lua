local pico = dofile("../src/pico.lua")

pico.init(true)

while true do
    pico.input.delay(16)
end

pico.init(false)
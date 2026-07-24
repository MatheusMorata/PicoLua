local pico = dofile("../src/pico.lua")

local executando = true

pico.init(true)

while executando do

    pico.output.clear()

    pico.input.delay(16)

    if pico.input.event_quit() then

        executando = false
    end

end

pico.init(false)
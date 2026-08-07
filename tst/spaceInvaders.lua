local pico = dofile("../src/pico.lua")

pico.init(true)


-- loop basico pra manter a janela viva
while true do
    pico.input.delay(16)
end

pico.init(false)
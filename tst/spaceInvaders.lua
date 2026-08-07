local pico = dofile("../src/pico.lua")
local utils = dofile("utils.lua")

pico.init(true)

utils.nave(pico)   -- desenha o quadrado verde (nave)

-- loop basico pra manter a janela viva
while true do
    pico.input.delay(16)
end

pico.init(false)
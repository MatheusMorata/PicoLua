local pico = dofile("../src/pico.lua")
local SDL = require "SDL"

pico.init(true)

while true do
    pico.output.clear()

    pico.output.draw_rect({
        x = 10,
        y = 10,
        w = 20,
        h = 20
    })

    SDL.delay(16)
end
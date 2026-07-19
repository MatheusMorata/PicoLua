--local pico = require "pico"
local pico = dofile("../src/pico.lua")
pico.init(true)

local running = true
local event = {}

while running do

    while pico.input.event_ask(event, SDL.ANY) do

        if event.type == SDL.QUIT
        or (event.type == SDL.KEYDOWN
            and event.key.keysym.scancode == SDL.SCANCODE_ESCAPE) then

            running = false
        end
    end

    pico.output.clear()
    pico.input.delay(16)
end

pico.init(false)
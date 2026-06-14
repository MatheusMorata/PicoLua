local pico = dofile("../src/pico.lua")
pico.init(true)

pico.set.color_clear({ r = 0, g = 0, b = 0, a = 255 })
pico.set.color_draw({ r = 255, g = 255, b = 255, a = 255 })
pico.output.clear()

-- Pontos espalhados
pico.output.draw_pixels({
    { x = 10, y = 10 },
    { x = 11, y = 11 },
    { x = 12, y = 12 },
    { x = 20, y = 5  },
    { x = 30, y = 20 },
    { x = 50, y = 30 },
    { x = 63, y = 35 },
})

-- Círculo aproximado no centro
local cx, cy, r = 32, 18, 10
local pontos = {}
for i = 0, 360, 5 do
    local rad = math.rad(i)
    table.insert(pontos, {
        x = math.floor(cx + r * math.cos(rad)),
        y = math.floor(cy + r * math.sin(rad))
    })
end
pico.output.draw_pixels(pontos)

pico.input.delay(5000)

pico.init(false)
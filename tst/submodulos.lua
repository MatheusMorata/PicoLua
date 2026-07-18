local pico = dofile("../src/pico.lua")

local quadrado = {}
local linha = {}


pico.init(true)

pico.set.color_clear({ r = 0, g = 0, b = 0, a = 255 })
pico.set.color_draw({ r = 255, g = 0, b = 0, a = 255 })

pico.output.clear()


for y = 10, 24 do
    for x = 10, 29 do
        table.insert(quadrado, {
            x = x,
            y = y
        })
    end
end

for i = 0, 63 do
    table.insert(linha, {
        x = i,
        y = math.floor(i * 35 / 63)
    })
end

pico.output.draw_pixels(quadrado)

pico.output.draw_pixels(linha)

pico.input.delay(5000)

pico.init(false)
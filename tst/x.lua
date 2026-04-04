local pico = dofile("../src/pico.lua")

pico.init(true)

pico.set.size(
    { x = 160, y = 160 },
    { x = 16, y = 16 }
)

for i = 0, 15 do
    pico.output.draw_pixel({ x = i, y = i })
    pico.output.draw_pixel({ x = 15 - i, y = i })
    pico.input.delay(100)
end

pico.input.delay(1000)

pico.init(false)
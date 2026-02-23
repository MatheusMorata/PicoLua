local pico = dofile("../src/pico.lua")
pico.init(true)
pico.set.size(
    { w = 160, h = 160 }, 
    { w = 16,  h = 16 }  
)

for i = 0, 15 do
    pico.output.draw_pixel({ x = i,     y = i })
    pico.output.draw_pixel({ x = 15-i,  y = i })
    pico.input.delay(100)
end

pico.input.delay(1000)
pico.init(false)
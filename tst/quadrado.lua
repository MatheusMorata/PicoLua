local pico = dofile("../src/pico.lua")

pico.init(true)

pico.set.size(
    {w = 160, h = 160},   -- tamanho físico
    {w = 16,  h = 16}     -- tamanho lógico
)

pico.set.color_draw({r=255,g=255,b=255,a=255})

pico.set.style(PICO_FILL)

pico.output.clear()

pico.output.draw_rect({
    x = 40,
    y = 40,
    w = 60,
    h = 60
})

pico.output.present()

pico.input.delay(3000)

pico.init(false)
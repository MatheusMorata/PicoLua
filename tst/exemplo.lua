local pico = dofile("../src/pico.lua")

-- inicia SDL
pico.init(true)

-- define tamanho da janela
pico.set.size(
    {w = 160, h = 160},   -- tamanho físico
    {w = 16,  h = 16}     -- tamanho lógico
)

-- desenha o X animado
for i = 0, 15 do
    pico.output.draw_pixel({x = i, y = i})
    pico.output.draw_pixel({x = 15 - i, y = i})
    pico.input.delay(100)
end

-- espera 1 segundo
pico.input.delay(1000)

-- finaliza SDL
pico.init(false)
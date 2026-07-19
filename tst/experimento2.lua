-- cenario_simples.lua
local pico = dofile("../src/pico.lua")
pico.init(true)

-- Define dimensões: 800x600 pixels -> 80x60 unidades
pico.set.size({x = 800, y = 600}, {x = 80, y = 60})

-- Limpa a tela
pico.output.clear()

-- ============================================
-- DESENHA ELEMENTOS
-- ============================================

-- 1. Retângulo verde no canto superior esquerdo
pico.set.color_draw({r = 0, g = 255, b = 0, a = 255})
pico.set.style("fill")
pico.output.draw_rect({x = 2, y = 2, w = 10, h = 5})

-- 2. Retângulo vermelho no centro
pico.set.color_draw({r = 255, g = 0, b = 0, a = 255})
pico.output.draw_rect({x = 38, y = 28, w = 4, h = 4})


pico.set.color_draw({r = 0, g = 100, b = 255, a = 255})
pico.output.draw_rect({x = 68, y = 2, w = 10, h = 5})

pico.set.color_draw({r = 255, g = 255, b = 0, a = 255})
pico.output.draw_rect({x = 2, y = 53, w = 10, h = 5})

pico.set.color_draw({r = 255, g = 0, b = 255, a = 255})
pico.output.draw_rect({x = 68, y = 53, w = 10, h = 5})

pico.set.color_draw({r = 255, g = 165, b = 0, a = 255})
pico.output.draw_poly({
    {x = 40, y = 10},
    {x = 35, y = 17},
    {x = 45, y = 17}
})

pico.set.color_draw({r = 255, g = 255, b = 255, a = 255})
pico.set.style("stroke")
pico.output.draw_line({x = 5, y = 5}, {x = 75, y = 55})

pico.set.color_draw({r = 255, g = 255, b = 255, a = 255})


local fonte_ok = pcall(function()
    pico.set.font("arial.ttf", 8)
end)

if fonte_ok and pico.get.font() then
    pico.output.draw_text("800x600 pixels -> 80x60 unidades", {x = 20, y = 2})
    pico.output.draw_text("ESC para sair", {x = 20, y = 56})
end

pico.input.delay(5000)  
pico.init(false)
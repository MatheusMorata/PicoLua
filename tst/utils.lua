local utils = {}

function utils.nave(pico)
    pico.set.color_draw({ r = 0, g = 255, b = 0, a = 255 })
    pico.set.style('PICO_FILL')

    pico.output.draw_rect({
        x = 10,  -- posição horizontal
        y = 10,  -- posição vertical
        w = 6,   -- largura pequena
        h = 6,   -- altura pequena
    })
end

return utils
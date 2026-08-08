local utils = {}

function utils.inimigos(pico)

    pico.set.color_draw({
        r = 255,
        g = 0,
        b = 0,
        a = 255
    })

    local pixels = {}

    -- Cada inimigo possui 3x3 pixels
    local function inimigo(x, y)
        for py = 0, 2 do
            for px = 0, 2 do
                pixels[#pixels + 1] = {
                    x = x + px,
                    y = y + py
                }
            end
        end
    end

    -- 7 colunas x 3 linhas
    for linha = 0, 2 do
        for coluna = 0, 6 do

            inimigo(
                5 + coluna * 9,
                6 + linha * 5
            )

        end
    end

    pico.output.draw_pixels(pixels, #pixels)

end


function utils.nave(pico)

    pico.set.color_draw({
        r = 0,
        g = 255,
        b = 0,
        a = 255
    })

    -- Nave triangular pequena
    -- Centralizada em x = 32
    local pixels = {
        -- ponta
        { x = 32, y = 42 },

        -- segunda linha
        { x = 31, y = 43 },
        { x = 32, y = 43 },
        { x = 33, y = 43 },

        -- terceira linha
        { x = 30, y = 44 },
        { x = 31, y = 44 },
        { x = 32, y = 44 },
        { x = 33, y = 44 },
        { x = 34, y = 44 },

        -- base
        { x = 29, y = 45 },
        { x = 30, y = 45 },
        { x = 31, y = 45 },
        { x = 32, y = 45 },
        { x = 33, y = 45 },
        { x = 34, y = 45 },
        { x = 35, y = 45 },

        -- motores
        { x = 30, y = 46 },
        { x = 34, y = 46 },
    }

    pico.output.draw_pixels(pixels, #pixels)

end


return utils
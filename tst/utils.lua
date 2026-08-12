local utils = {}

function utils.inimigos(pico, deslocamento_x, deslocamento_y)

    pico.set.color_draw({
        r = 255,
        g = 0,
        b = 0,
        a = 255
    })

    local pixels = {}

    local function inimigo(x, y)

        for py = 0, 2 do
            for px = 0, 2 do
                pixels[#pixels + 1] = {
                    x = x + px + deslocamento_x,
                    y = y + py + deslocamento_y
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

-- Nave triangular pequena
-- nave = { x = <centro horizontal>, y = <y da ponta> }
function utils.nave(pico, nave)

    pico.set.color_draw({
        r = 0,
        g = 255,
        b = 0,
        a = 255
    })

    local cx, cy = nave.x, nave.y

    -- Deslocamentos relativos ao centro (originalmente centrado em x=32)
    local pixels = {
        -- ponta
        { x = cx + 0, y = cy + 0 },

        -- segunda linha
        { x = cx - 1, y = cy + 1 },
        { x = cx + 0, y = cy + 1 },
        { x = cx + 1, y = cy + 1 },

        -- terceira linha
        { x = cx - 2, y = cy + 2 },
        { x = cx - 1, y = cy + 2 },
        { x = cx + 0, y = cy + 2 },
        { x = cx + 1, y = cy + 2 },
        { x = cx + 2, y = cy + 2 },

        -- base
        { x = cx - 3, y = cy + 3 },
        { x = cx - 2, y = cy + 3 },
        { x = cx - 1, y = cy + 3 },
        { x = cx + 0, y = cy + 3 },
        { x = cx + 1, y = cy + 3 },
        { x = cx + 2, y = cy + 3 },
        { x = cx + 3, y = cy + 3 },

        -- motores
        { x = cx - 2, y = cy + 4 },
        { x = cx + 2, y = cy + 4 },
    }

    pico.output.draw_pixels(pixels, #pixels)

end

-- Desenha o tiro (retângulo amarelo)
-- tiro = { x = ..., y = ... }
function utils.tiro(pico, tiro)

    pico.set.anchor_draw({ x = PICO_LEFT, y = PICO_TOP })

    pico.set.color_draw({
        r = 255,
        g = 255,
        b = 0,
        a = 255
    })

    pico.output.draw_rect({
        x = tiro.x,
        y = tiro.y,
        w = 1,
        h = 2
    })

    -- restaura âncora padrão (centro), usada por nave/inimigos
    pico.set.anchor_draw({ x = PICO_CENTER, y = PICO_MIDDLE })

end

-- Desenha a cena inteira: limpa, nave, inimigos e tiro (se existir)
function utils.desenhar(pico, nave, tiro, inimigos_x, inimigos_y)

    pico.output.clear()

    utils.nave(pico, nave)

    utils.inimigos(
        pico,
        inimigos_x,
        inimigos_y
    )

    if tiro then
        utils.tiro(pico, tiro)
    end

end

return utils
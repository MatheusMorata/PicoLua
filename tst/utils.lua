local utils = {}


--------------------------------------------------
-- INIMIGOS
--------------------------------------------------

function utils.inimigos(pico, deslocamento_x, deslocamento_y, vivos)

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
                    x = x + px + deslocamento_x,
                    y = y + py + deslocamento_y
                }

            end
        end

    end


    -- 7 colunas x 3 linhas
    for linha = 1, 3 do

        for coluna = 1, 7 do

            if vivos[linha][coluna] then

                inimigo(
                    5 + (coluna - 1) * 9,
                    6 + (linha - 1) * 5
                )

            end

        end

    end


    if #pixels > 0 then
        pico.output.draw_pixels(
            pixels,
            #pixels
        )
    end

end


--------------------------------------------------
-- NAVE
--------------------------------------------------

function utils.nave(pico, nave)

    pico.set.color_draw({
        r = 0,
        g = 255,
        b = 0,
        a = 255
    })

    local cx, cy = nave.x, nave.y

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

    pico.output.draw_pixels(
        pixels,
        #pixels
    )

end


--------------------------------------------------
-- TIRO
--------------------------------------------------

function utils.tiro(pico, tiro)

    pico.set.anchor_draw({
        x = PICO_LEFT,
        y = PICO_TOP
    })

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

    pico.set.anchor_draw({
        x = PICO_CENTER,
        y = PICO_MIDDLE
    })

end


--------------------------------------------------
-- DESENHA TUDO
--------------------------------------------------

function utils.desenhar(
    pico,
    nave,
    tiro,
    inimigos_x,
    inimigos_y,
    vivos
)

    pico.output.clear()

    utils.nave(
        pico,
        nave
    )

    utils.inimigos(
        pico,
        inimigos_x,
        inimigos_y,
        vivos
    )

    if tiro then

        utils.tiro(
            pico,
            tiro
        )

    end

end


return utils
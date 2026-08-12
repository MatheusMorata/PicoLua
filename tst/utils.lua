local utils = {}

--------------------------------------------------
-- INIMIGOS
--------------------------------------------------

function utils.inimigos(pico, inimigos)

    pico.set.color_draw({
        r = 255,
        g = 0,
        b = 0,
        a = 255
    })

    local pixels = {}

    for _, inimigo in ipairs(inimigos) do

        if inimigo.vivo then

            -- Cada inimigo possui 3x3 pixels
            for py = 0, 2 do

                for px = 0, 2 do

                    pixels[#pixels + 1] = {
                        x = inimigo.x + px,
                        y = inimigo.y + py
                    }

                end

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

-- nave = {
--     x = centro horizontal,
--     y = ponta superior
-- }

function utils.nave(pico, nave)

    pico.set.color_draw({
        r = 0,
        g = 255,
        b = 0,
        a = 255
    })

    local cx = nave.x
    local cy = nave.y

    local pixels = {

        -- ponta
        {
            x = cx + 0,
            y = cy + 0
        },

        -- segunda linha
        {
            x = cx - 1,
            y = cy + 1
        },

        {
            x = cx + 0,
            y = cy + 1
        },

        {
            x = cx + 1,
            y = cy + 1
        },

        -- terceira linha
        {
            x = cx - 2,
            y = cy + 2
        },

        {
            x = cx - 1,
            y = cy + 2
        },

        {
            x = cx + 0,
            y = cy + 2
        },

        {
            x = cx + 1,
            y = cy + 2
        },

        {
            x = cx + 2,
            y = cy + 2
        },

        -- base
        {
            x = cx - 3,
            y = cy + 3
        },

        {
            x = cx - 2,
            y = cy + 3
        },

        {
            x = cx - 1,
            y = cy + 3
        },

        {
            x = cx + 0,
            y = cy + 3
        },

        {
            x = cx + 1,
            y = cy + 3
        },

        {
            x = cx + 2,
            y = cy + 3
        },

        {
            x = cx + 3,
            y = cy + 3
        },

        -- motores
        {
            x = cx - 2,
            y = cy + 4
        },

        {
            x = cx + 2,
            y = cy + 4
        }
    }

    pico.output.draw_pixels(
        pixels,
        #pixels
    )
end


--------------------------------------------------
-- TIRO
--------------------------------------------------

-- tiro = {
--     x = posição horizontal,
--     y = posição vertical
-- }

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

    -- Restaura a âncora padrão
    pico.set.anchor_draw({
        x = PICO_CENTER,
        y = PICO_MIDDLE
    })
end


--------------------------------------------------
-- PONTUAÇÃO
--------------------------------------------------

function utils.pontuacao(pico, pontos)

    pico.set.anchor_draw({
        x = PICO_RIGHT,
        y = PICO_TOP
    })

    pico.set.color_draw({
        r = 255,
        g = 255,
        b = 255,
        a = 255
    })

    pico.output.draw_text(
        {
            x = 63,
            y = 0
        },
        tostring(pontos)
    )

    -- Restaura a âncora padrão
    pico.set.anchor_draw({
        x = PICO_CENTER,
        y = PICO_MIDDLE
    })
end


--------------------------------------------------
-- COLISÃO DO TIRO COM OS INIMIGOS
--------------------------------------------------

function utils.colisao_tiro_inimigos(tiro, inimigos)

    if not tiro then
        return false
    end

    for _, inimigo in ipairs(inimigos) do

        if inimigo.vivo then

            --------------------------------------------------
            -- ÁREA DO INIMIGO
            --------------------------------------------------

            local inimigo_esq = inimigo.x
            local inimigo_dir = inimigo.x + 2

            local inimigo_top = inimigo.y
            local inimigo_baixo = inimigo.y + 2


            --------------------------------------------------
            -- ÁREA DO TIRO
            --------------------------------------------------

            local tiro_esq = tiro.x
            local tiro_dir = tiro.x

            local tiro_top = tiro.y
            local tiro_baixo = tiro.y + 1


            --------------------------------------------------
            -- TESTE DE INTERSEÇÃO
            --------------------------------------------------

            if tiro_esq <= inimigo_dir
                and tiro_dir >= inimigo_esq
                and tiro_top <= inimigo_baixo
                and tiro_baixo >= inimigo_top then

                --------------------------------------------------
                -- INIMIGO FOI ATINGIDO
                --------------------------------------------------

                inimigo.vivo = false

                return true
            end
        end
    end

    return false
end


--------------------------------------------------
-- DESENHAR CENA
--------------------------------------------------

function utils.desenhar(
    pico,
    nave,
    inimigos,
    tiro,
    pontos
)

    --------------------------------------------------
    -- LIMPA A TELA
    --------------------------------------------------

    pico.output.clear()


    --------------------------------------------------
    -- NAVE
    --------------------------------------------------

    utils.nave(
        pico,
        nave
    )


    --------------------------------------------------
    -- INIMIGOS
    --------------------------------------------------

    utils.inimigos(
        pico,
        inimigos
    )


    --------------------------------------------------
    -- TIRO
    --------------------------------------------------

    if tiro then

        utils.tiro(
            pico,
            tiro
        )

    end


    --------------------------------------------------
    -- PONTUAÇÃO
    --------------------------------------------------

    utils.pontuacao(
        pico,
        pontos
    )
end


return utils
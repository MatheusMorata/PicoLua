local utils = {}

--------------------------------------------------
-- CONFIGURAÇÃO DOS INIMIGOS
--------------------------------------------------

local INIMIGO_LARGURA = 3
local INIMIGO_ALTURA = 3


--------------------------------------------------
-- DESENHA UM INIMIGO
--------------------------------------------------

local function desenhar_inimigo(
    pico,
    enemy
)

    for py = 0, INIMIGO_ALTURA - 1 do

        for px = 0, INIMIGO_LARGURA - 1 do

            pico.output.draw_pixel({

                x = enemy.x + px,

                y = enemy.y + py

            })

        end

    end

end


--------------------------------------------------
-- TELA INICIAL
--------------------------------------------------

function utils.tela_inicio(
    pico
)

    pico.output.clear()

    pico.set.anchor_draw({

        x = PICO_LEFT,

        y = PICO_TOP

    })

    pico.set.color_draw({

        r = 0,

        g = 255,

        b = 0,

        a = 255

    })

    pico.output.draw_text(

        {

            x = 0,

            y = 20

        },

        "SPACE INVADERS"

    )

    pico.set.color_draw({

        r = 255,

        g = 255,

        b = 255,

        a = 255

    })

    pico.set.anchor_draw({

        x = PICO_CENTER,

        y = PICO_MIDDLE

    })

end


--------------------------------------------------
-- DESENHA OS INIMIGOS
--------------------------------------------------

function utils.inimigos(
    pico,
    inimigos
)

    pico.set.anchor_draw({

        x = PICO_LEFT,

        y = PICO_TOP

    })

    pico.set.color_draw({

        r = 255,

        g = 0,

        b = 0,

        a = 255

    })

    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            desenhar_inimigo(
                pico,
                enemy
            )

        end

    end

    pico.set.color_draw({

        r = 255,

        g = 255,

        b = 255,

        a = 255

    })

    pico.set.anchor_draw({

        x = PICO_CENTER,

        y = PICO_MIDDLE

    })

end


--------------------------------------------------
-- NAVE
--------------------------------------------------

function utils.nave(
    pico,
    nave
)

    pico.set.anchor_draw({

        x = PICO_LEFT,

        y = PICO_TOP

    })

    pico.set.color_draw({

        r = 0,

        g = 255,

        b = 0,

        a = 255

    })

    local cx = nave.x
    local cy = nave.y

    local pixels = {

        {
            x = cx + 0,
            y = cy + 0
        },

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

    pico.set.color_draw({

        r = 255,

        g = 255,

        b = 255,

        a = 255

    })

    pico.set.anchor_draw({

        x = PICO_CENTER,

        y = PICO_MIDDLE

    })

end


--------------------------------------------------
-- TIRO
--------------------------------------------------

function utils.tiro(
    pico,
    tiro
)

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

    pico.set.color_draw({

        r = 255,

        g = 255,

        b = 255,

        a = 255

    })

    pico.set.anchor_draw({

        x = PICO_CENTER,

        y = PICO_MIDDLE

    })

end


--------------------------------------------------
-- PONTUAÇÃO
--------------------------------------------------

function utils.pontuacao(
    pico,
    pontos
)

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

            y = 1

        },

        tostring(pontos)

    )

    pico.set.anchor_draw({

        x = PICO_CENTER,

        y = PICO_MIDDLE

    })

end


--------------------------------------------------
-- PAUSE
--------------------------------------------------

function utils.pause(
    pico
)

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

    pico.output.draw_text(

        {

            x = 22,

            y = 24

        },

        "PAUSE"

    )

    pico.set.color_draw({

        r = 255,

        g = 255,

        b = 255,

        a = 255

    })

    pico.set.anchor_draw({

        x = PICO_CENTER,

        y = PICO_MIDDLE

    })

end


--------------------------------------------------
-- GAME OVER
--------------------------------------------------

function utils.game_over(
    pico,
    pontos
)

    --------------------------------------------------
    -- LIMPA A TELA
    --------------------------------------------------

    pico.output.clear()


    --------------------------------------------------
    -- ÂNCORA SUPERIOR ESQUERDA
    --
    -- Usamos a origem da tela para que o cálculo
    -- manual da posição seja previsível.
    --------------------------------------------------

    pico.set.anchor_draw({

        x = PICO_LEFT,

        y = PICO_TOP

    })


    --------------------------------------------------
    -- COR BRANCA
    --------------------------------------------------

    pico.set.color_draw({

        r = 255,

        g = 255,

        b = 255,

        a = 255

    })


    --------------------------------------------------
    -- GAME OVER
    --------------------------------------------------

    local texto_game_over = "GAME OVER!"

    local largura_game_over =
        #texto_game_over * 4


    local x_game_over =
        (64 - largura_game_over) / 2


    pico.output.draw_text(

        {

            x = x_game_over,

            y = 18

        },

        texto_game_over

    )


    --------------------------------------------------
    -- SCORE
    --------------------------------------------------

    local texto_score =
        "Score: " .. tostring(pontos)


    local largura_score =
        #texto_score * 4


    local x_score =
        (64 - largura_score) / 2


    pico.output.draw_text(

        {

            x = x_score,

            y = 27

        },

        texto_score

    )


    --------------------------------------------------
    -- RESTAURA ÂNCORA
    --------------------------------------------------

    pico.set.anchor_draw({

        x = PICO_CENTER,

        y = PICO_MIDDLE

    })

end


--------------------------------------------------
-- DESENHA A CENA
--------------------------------------------------

function utils.desenhar(
    pico,
    nave,
    inimigos,
    tiro,
    pontos,
    pausado
)

    pico.output.clear()

    utils.inimigos(
        pico,
        inimigos
    )

    utils.nave(
        pico,
        nave
    )

    if tiro then

        utils.tiro(
            pico,
            tiro
        )

    end

    utils.pontuacao(
        pico,
        pontos
    )

    if pausado then

        utils.pause(
            pico
        )

    end

end


--------------------------------------------------
-- RETORNA A BIBLIOTECA
--------------------------------------------------

return utils
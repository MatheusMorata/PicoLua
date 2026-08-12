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

    pico.set.grid(false)

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
    pico.set.grid(true)
end


--------------------------------------------------
-- INIMIGOS
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

            x = 32 - 10,

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
-- TELA DE GAME OVER
--------------------------------------------------

function utils.game_over(
    pico,
    pontos
)

    pico.output.clear()


    --------------------------------------------------
    -- ÂNCORA SUPERIOR ESQUERDA
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
    --
    -- Aproximadamente 10 caracteres x 4 pixels.
    --------------------------------------------------

    local texto_game_over =
        "GAME OVER!"


    local largura_game_over =
        #texto_game_over * 4


    local x_game_over =
        math.floor(
            (64 - largura_game_over) / 2
        )


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
        math.floor(
            (64 - largura_score) / 2
        )


    pico.output.draw_text(

        {

            x = x_score,

            y = 28

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
-- TELA DE NOVO RECORDE
--------------------------------------------------

function utils.novo_recorde(
    pico,
    nome,
    posicao
)

    pico.output.clear()


    --------------------------------------------------
    -- ÂNCORA SUPERIOR ESQUERDA
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
    -- NEW
    --------------------------------------------------

    local texto_new =
        "NEW"


    local largura_new =
        #texto_new * 4


    local x_new =
        math.floor(
            (64 - largura_new) / 2
        )


    pico.output.draw_text(

        {

            x = x_new,

            y = 8

        },

        texto_new

    )


    --------------------------------------------------
    -- HIGH SCORE
    --------------------------------------------------

    local texto_high =
        "HIGH SCORE"


    local largura_high =
        #texto_high * 4


    local x_high =
        math.floor(
            (64 - largura_high) / 2
        )


    pico.output.draw_text(

        {

            x = x_high,

            y = 16

        },

        texto_high

    )


    --------------------------------------------------
    -- MONTA O NOME
    --------------------------------------------------

    local texto_nome = ""


    for i = 1, 5 do

        if nome[i] then

            texto_nome =
                texto_nome .. nome[i]

        else

            texto_nome =
                texto_nome .. "_"

        end


        if i < 5 then

            texto_nome =
                texto_nome .. " "

        end

    end


    --------------------------------------------------
    -- CENTRALIZA O NOME
    --------------------------------------------------

    local largura_nome =
        #texto_nome * 4


    local x_nome =
        math.floor(
            (64 - largura_nome) / 2
        )


    pico.output.draw_text(

        {

            x = x_nome,

            y = 27

        },

        texto_nome

    )


    --------------------------------------------------
    -- INDICADOR DA POSIÇÃO
    --------------------------------------------------

    local x_cursor =
        x_nome + (posicao - 1) * 10


    pico.output.draw_text(

        {

            x = x_cursor,

            y = 35

        },

        "^"

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
-- RETORNA
--------------------------------------------------

return utils
local pico = dofile("../src/pico.lua")
local utils = dofile("utils.lua")

pico.init(true)

--------------------------------------------------
-- NAVE
--------------------------------------------------

local nave = {
    x = 32,
    y = 42
}

local NAVE_MIN_X = 3
local NAVE_MAX_X = 64 - 1 - 3


--------------------------------------------------
-- TIRO
--------------------------------------------------

local tiro = nil
local z_antes = false


--------------------------------------------------
-- INIMIGOS
--------------------------------------------------

local inimigos_x = 0
local inimigos_y = 0

-- 1 = direita
-- -1 = esquerda
local inimigos_direcao = 1

-- Movimento bem lento
local contador_inimigos = 0
local intervalo_inimigos = 5

-- Limites do grupo de inimigos
local INIMIGOS_MIN_X = 5
local INIMIGOS_MAX_X = 5 + (6 * 9) + 2


--------------------------------------------------
-- DESENHO INICIAL
--------------------------------------------------

utils.desenhar(
    pico,
    nave,
    tiro,
    inimigos_x,
    inimigos_y
)


--------------------------------------------------
-- LOOP PRINCIPAL
--------------------------------------------------

while true do

    --------------------------------------------------
    -- MOVIMENTO DA NAVE
    --------------------------------------------------

    if pico.get.key(pico.key.A) == 1 then

        nave.x = math.max(
            NAVE_MIN_X,
            nave.x - 1
        )

    end


    if pico.get.key(pico.key.D) == 1 then

        nave.x = math.min(
            NAVE_MAX_X,
            nave.x + 1
        )

    end


    --------------------------------------------------
    -- DISPARO
    --------------------------------------------------

    local z_agora =
        pico.get.key(pico.key.Z) == 1

    -- Dispara somente quando a tecla é pressionada
    if z_agora and not z_antes and not tiro then

        tiro = {
            x = nave.x,
            y = nave.y - 1
        }

    end

    z_antes = z_agora


    --------------------------------------------------
    -- MOVIMENTO DO TIRO
    --------------------------------------------------

    if tiro then

        tiro.y = tiro.y - 2

        if tiro.y < 0 then
            tiro = nil
        end

    end


    --------------------------------------------------
    -- MOVIMENTO DOS INIMIGOS
    --------------------------------------------------

    contador_inimigos = contador_inimigos + 1

    if contador_inimigos >= intervalo_inimigos then

        contador_inimigos = 0

        inimigos_x =
            inimigos_x +
            inimigos_direcao


        --------------------------------------------------
        -- BORDA DIREITA
        --------------------------------------------------

        if inimigos_x + INIMIGOS_MAX_X >= 64 then

            inimigos_x =
                64 - INIMIGOS_MAX_X

            inimigos_direcao = -1

            -- Desce uma linha
            inimigos_y = inimigos_y + 1

        end


        --------------------------------------------------
        -- BORDA ESQUERDA
        --------------------------------------------------

        if inimigos_x + INIMIGOS_MIN_X <= 0 then

            inimigos_x =
                -INIMIGOS_MIN_X

            inimigos_direcao = 1

            -- Desce uma linha
            inimigos_y = inimigos_y + 1

        end

    end


    --------------------------------------------------
    -- DESENHA A CENA
    --------------------------------------------------

    utils.desenhar(
        pico,
        nave,
        tiro,
        inimigos_x,
        inimigos_y
    )


    --------------------------------------------------
    -- CONTROLE DA VELOCIDADE DO JOGO
    --------------------------------------------------

    pico.input.delay(16)

end


--------------------------------------------------
-- FINALIZA
--------------------------------------------------

pico.init(false)
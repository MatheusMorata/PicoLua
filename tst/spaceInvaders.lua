local pico = dofile("../src/pico.lua")
local utils = dofile("utils.lua")


--------------------------------------------------
-- INICIALIZAÇÃO
--------------------------------------------------

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

local inimigos_direcao = 1

-- Quanto maior, mais lento
local contador_inimigos = 0
local intervalo_inimigos = 20


--------------------------------------------------
-- MATRIZ DE INIMIGOS
--
-- 3 linhas x 7 colunas
--------------------------------------------------

local vivos = {}

for linha = 1, 3 do

    vivos[linha] = {}

    for coluna = 1, 7 do
        vivos[linha][coluna] = true
    end

end


--------------------------------------------------
-- LIMITES DOS INIMIGOS
--------------------------------------------------

local INIMIGOS_MIN_X = 5
local INIMIGOS_MAX_X = 5 + (6 * 9) + 2


--------------------------------------------------
-- FUNÇÃO PARA DESENHAR
--------------------------------------------------

utils.desenhar(
    pico,
    nave,
    tiro,
    inimigos_x,
    inimigos_y,
    vivos
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

    if z_agora
       and not z_antes
       and not tiro then

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
    -- COLISÃO DO TIRO
    --------------------------------------------------

    if tiro then

        local tiro_rect = {
            x = tiro.x,
            y = tiro.y,
            w = 1,
            h = 2
        }


        local acertou = false


        for linha = 1, 3 do

            for coluna = 1, 7 do

                if vivos[linha][coluna] then

                    local inimigo_rect = {
                        x = 5 + (coluna - 1) * 9 + inimigos_x,
                        y = 6 + (linha - 1) * 5 + inimigos_y,
                        w = 3,
                        h = 3
                    }


                    if pico_rect_vs_rect(
                        tiro_rect,
                        inimigo_rect
                    ) then

                        -- Remove o inimigo
                        vivos[linha][coluna] = false

                        -- Remove o tiro
                        tiro = nil

                        acertou = true

                        break

                    end

                end

            end


            if acertou then
                break
            end

        end

    end


    --------------------------------------------------
    -- MOVIMENTO DOS INIMIGOS
    --------------------------------------------------

    contador_inimigos =
        contador_inimigos + 1


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

            inimigos_y =
                inimigos_y + 1

        end


        --------------------------------------------------
        -- BORDA ESQUERDA
        --------------------------------------------------

        if inimigos_x + INIMIGOS_MIN_X <= 0 then

            inimigos_x =
                -INIMIGOS_MIN_X

            inimigos_direcao = 1

            inimigos_y =
                inimigos_y + 1

        end

    end


    --------------------------------------------------
    -- DESENHA
    --------------------------------------------------

    utils.desenhar(
        pico,
        nave,
        tiro,
        inimigos_x,
        inimigos_y,
        vivos
    )


    --------------------------------------------------
    -- CONTROLE DO TEMPO
    --------------------------------------------------

    pico.input.delay(16)

end


--------------------------------------------------
-- FINALIZA
--------------------------------------------------

pico.init(false)
local pico = dofile("../src/pico.lua")
local utils = dofile("utils.lua")


--------------------------------------------------
-- INICIALIZAÇÃO
--------------------------------------------------

pico.init(true)

pico.set.expert(true)


--------------------------------------------------
-- TAMANHO DA JANELA
--------------------------------------------------

pico.set.size(

    {

        x = 640,

        y = 480

    },

    {

        x = 64,

        y = 48

    }

)


--------------------------------------------------
-- FONTE
--------------------------------------------------

pico.set.font(
    "tiny.ttf",
    8
)


--------------------------------------------------
-- ESTADOS
--------------------------------------------------

local estado = "inicio"


--------------------------------------------------
-- ESTADOS DAS TECLAS
--------------------------------------------------

local z_antes = false
local p_antes = false
local y_antes = false


--------------------------------------------------
-- NAVE
--------------------------------------------------

local nave = {

    x = 32,

    y = 42

}


--------------------------------------------------
-- TIRO
--------------------------------------------------

local tiro = nil


--------------------------------------------------
-- PONTUAÇÃO
--------------------------------------------------

local pontos = 0


--------------------------------------------------
-- PAUSE
--------------------------------------------------

local pausado = false


--------------------------------------------------
-- LIMITES DA NAVE
--------------------------------------------------

local NAVE_MIN_X = 3

local NAVE_MAX_X =
    64 - 1 - 3


--------------------------------------------------
-- INIMIGOS
--------------------------------------------------

local inimigos = {}


--------------------------------------------------
-- CRIA OS INIMIGOS
--------------------------------------------------

local function criar_inimigos()

    inimigos = {}

    for linha = 0, 2 do

        for coluna = 0, 6 do

            inimigos[#inimigos + 1] = {

                x = 5 + coluna * 9,

                y = 6 + linha * 5,

                vivo = true

            }

        end

    end

end


--------------------------------------------------
-- INICIALIZA OS INIMIGOS
--------------------------------------------------

criar_inimigos()


--------------------------------------------------
-- MOVIMENTO DOS INIMIGOS
--------------------------------------------------

local inimigo_direcao = 1

local INIMIGO_INTERVALO = 5

local contador_inimigo = 0


--------------------------------------------------
-- REINICIA A PARTIDA
--------------------------------------------------

local function reiniciar_jogo()

    --------------------------------------------------
    -- NAVE
    --------------------------------------------------

    nave.x = 32
    nave.y = 42


    --------------------------------------------------
    -- TIRO
    --------------------------------------------------

    tiro = nil


    --------------------------------------------------
    -- PONTUAÇÃO
    --------------------------------------------------

    pontos = 0


    --------------------------------------------------
    -- PAUSE
    --------------------------------------------------

    pausado = false


    --------------------------------------------------
    -- MOVIMENTO DOS INIMIGOS
    --------------------------------------------------

    inimigo_direcao = 1
    contador_inimigo = 0


    --------------------------------------------------
    -- RECRIA OS INIMIGOS
    --------------------------------------------------

    criar_inimigos()


    --------------------------------------------------
    -- VOLTA PARA O JOGO
    --------------------------------------------------

    estado = "jogo"


    --------------------------------------------------
    -- Evita que o mesmo Y seja interpretado
    -- novamente.
    --------------------------------------------------

    y_antes = true

end


--------------------------------------------------
-- MOVE OS INIMIGOS
--------------------------------------------------

local function mover_inimigos()

    contador_inimigo =
        contador_inimigo + 1


    if contador_inimigo < INIMIGO_INTERVALO then

        return

    end


    contador_inimigo = 0


    --------------------------------------------------
    -- LIMITES DOS INIMIGOS
    --------------------------------------------------

    local menor_x = 64

    local maior_x = 0

    local encontrou = false


    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            encontrou = true

            menor_x = math.min(

                menor_x,

                enemy.x

            )

            maior_x = math.max(

                maior_x,

                enemy.x + 2

            )

        end

    end


    if not encontrou then

        return

    end


    --------------------------------------------------
    -- BORDA DIREITA
    --------------------------------------------------

    if inimigo_direcao > 0
    and maior_x >= 63 then

        inimigo_direcao = -1

        for _, enemy in ipairs(inimigos) do

            if enemy.vivo then

                enemy.y =
                    enemy.y + 1

            end

        end

        return

    end


    --------------------------------------------------
    -- BORDA ESQUERDA
    --------------------------------------------------

    if inimigo_direcao < 0
    and menor_x <= 0 then

        inimigo_direcao = 1

        for _, enemy in ipairs(inimigos) do

            if enemy.vivo then

                enemy.y =
                    enemy.y + 1

            end

        end

        return

    end


    --------------------------------------------------
    -- MOVIMENTO HORIZONTAL
    --------------------------------------------------

    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            enemy.x =
                enemy.x + inimigo_direcao

        end

    end

end


--------------------------------------------------
-- VERIFICA VITÓRIA
--------------------------------------------------

local function verificar_vitoria()

    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            return false

        end

    end

    return true

end


--------------------------------------------------
-- VERIFICA DERROTA
--
-- Se os inimigos chegarem na linha da nave,
-- o jogador perde.
--------------------------------------------------

local function verificar_colisao_nave()

    --------------------------------------------------
    -- LINHA LIMITE
    --------------------------------------------------

    local LIMITE_DERROTA = 39


    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            if enemy.y + 2 >= LIMITE_DERROTA then

                return true

            end

        end

    end


    return false

end


--------------------------------------------------
-- COLISÃO DO TIRO
--------------------------------------------------

local function verificar_colisao()

    if not tiro then

        return

    end


    local tiro_x1 = tiro.x
    local tiro_x2 = tiro.x

    local tiro_y1 = tiro.y
    local tiro_y2 = tiro.y + 1


    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            local inimigo_x1 = enemy.x
            local inimigo_x2 = enemy.x + 2

            local inimigo_y1 = enemy.y
            local inimigo_y2 = enemy.y + 2


            local colisao =

                tiro_x1 <= inimigo_x2
                and

                tiro_x2 >= inimigo_x1
                and

                tiro_y1 <= inimigo_y2
                and

                tiro_y2 >= inimigo_y1


            if colisao then

                enemy.vivo = false

                tiro = nil

                pontos =
                    pontos + 10

                return

            end

        end

    end

end


--------------------------------------------------
-- TELA INICIAL
--------------------------------------------------

utils.tela_inicio(
    pico
)


--------------------------------------------------
-- LOOP PRINCIPAL
--------------------------------------------------

while true do


    --------------------------------------------------
    -- INÍCIO
    --------------------------------------------------

    if estado == "inicio" then

        local z_agora =
            pico.get.key(pico.key.Z) == 1


        if z_agora
        and not z_antes then

            estado = "jogo"

            z_antes = true

        end


        z_antes =
            z_agora


        utils.tela_inicio(
            pico
        )


    --------------------------------------------------
    -- JOGO
    --------------------------------------------------

    elseif estado == "jogo" then

        --------------------------------------------------
        -- PAUSE
        --------------------------------------------------

        local p_agora =
            pico.get.key(pico.key.P) == 1


        if p_agora
        and not p_antes then

            pausado =
                not pausado

        end


        p_antes =
            p_agora


        --------------------------------------------------
        -- JOGO ATIVO
        --------------------------------------------------

        if not pausado then


            --------------------------------------------------
            -- MOVIMENTO DA NAVE
            --------------------------------------------------

            if pico.get.key(pico.key.A) == 1 then

                nave.x =
                    math.max(

                        NAVE_MIN_X,

                        nave.x - 1

                    )

            end


            if pico.get.key(pico.key.D) == 1 then

                nave.x =
                    math.min(

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


            z_antes =
                z_agora


            --------------------------------------------------
            -- MOVIMENTO DO TIRO
            --------------------------------------------------

            if tiro then

                tiro.y =
                    tiro.y - 2


                if tiro.y < 0 then

                    tiro = nil

                end

            end


            --------------------------------------------------
            -- MOVIMENTO DOS INIMIGOS
            --------------------------------------------------

            mover_inimigos()


            --------------------------------------------------
            -- COLISÃO DO TIRO
            --------------------------------------------------

            verificar_colisao()


            --------------------------------------------------
            -- VERIFICA DERROTA
            --------------------------------------------------

            if verificar_colisao_nave() then

                estado = "derrota"


            --------------------------------------------------
            -- VERIFICA VITÓRIA
            --------------------------------------------------

            elseif verificar_vitoria() then

                estado = "derrota"

            end

        end


        --------------------------------------------------
        -- DESENHA O JOGO
        --------------------------------------------------

        utils.desenhar(

            pico,

            nave,

            inimigos,

            tiro,

            pontos,

            pausado

        )


    --------------------------------------------------
    -- GAME OVER
    --------------------------------------------------

    elseif estado == "derrota" then


        utils.game_over(

            pico,

            pontos

        )


        --------------------------------------------------
        -- Y PARA JOGAR NOVAMENTE
        --------------------------------------------------

        local y_agora =
            pico.get.key(pico.key.Y) == 1


        if y_agora
        and not y_antes then

            reiniciar_jogo()

        end


        y_antes =
            y_agora

    end


    --------------------------------------------------
    -- ESPERA
    --------------------------------------------------

    pico.input.delay(16)

end


--------------------------------------------------
-- FINALIZAÇÃO
--------------------------------------------------

pico.init(false)
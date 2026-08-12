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
-- ESTADO DO JOGO
--
-- inicio
-- jogo
-- vitoria
-- derrota
--------------------------------------------------

local estado = "inicio"


--------------------------------------------------
-- ESTADO DA TECLA Z
--------------------------------------------------

local z_antes = false


--------------------------------------------------
-- ESTADO DA TECLA P
--------------------------------------------------

local p_antes = false


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
--
-- 7 colunas x 3 linhas
--------------------------------------------------

for linha = 0, 2 do

    for coluna = 0, 6 do

        inimigos[#inimigos + 1] = {

            x = 5 + coluna * 9,

            y = 6 + linha * 5,

            vivo = true

        }

    end

end


--------------------------------------------------
-- MOVIMENTO DOS INIMIGOS
--------------------------------------------------

local inimigo_direcao = 1

local INIMIGO_INTERVALO = 20

local contador_inimigo = 0


--------------------------------------------------
-- MOVE OS INIMIGOS
--------------------------------------------------

local function mover_inimigos()

    contador_inimigo =
        contador_inimigo + 1


    --------------------------------------------------
    -- AINDA NÃO É HORA DE MOVER
    --------------------------------------------------

    if contador_inimigo < INIMIGO_INTERVALO then
        return
    end


    contador_inimigo = 0


    --------------------------------------------------
    -- ENCONTRA OS LIMITES DOS INIMIGOS VIVOS
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


    --------------------------------------------------
    -- TODOS FORAM DESTRUÍDOS
    --------------------------------------------------

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
-- VERIFICA SE TODOS OS INIMIGOS FORAM
-- DESTRUÍDOS
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
-- VERIFICA COLISÃO DO INIMIGO COM A NAVE
--------------------------------------------------

local function verificar_colisao_nave()

    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            --------------------------------------------------
            -- ÁREA DO INIMIGO
            --------------------------------------------------

            local inimigo_x1 =
                enemy.x

            local inimigo_x2 =
                enemy.x + 2

            local inimigo_y1 =
                enemy.y

            local inimigo_y2 =
                enemy.y + 2


            --------------------------------------------------
            -- ÁREA DA NAVE
            --------------------------------------------------

            local nave_x1 =
                nave.x - 3

            local nave_x2 =
                nave.x + 3

            local nave_y1 =
                nave.y

            local nave_y2 =
                nave.y + 4


            --------------------------------------------------
            -- TESTE DE COLISÃO
            --------------------------------------------------

            local colisao =

                inimigo_x1 <= nave_x2
                and

                inimigo_x2 >= nave_x1
                and

                inimigo_y1 <= nave_y2
                and

                inimigo_y2 >= nave_y1


            if colisao then

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


    --------------------------------------------------
    -- ÁREA DO TIRO
    --------------------------------------------------

    local tiro_x1 =
        tiro.x

    local tiro_x2 =
        tiro.x

    local tiro_y1 =
        tiro.y

    local tiro_y2 =
        tiro.y + 1


    --------------------------------------------------
    -- TESTA TODOS OS INIMIGOS
    --------------------------------------------------

    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            --------------------------------------------------
            -- ÁREA DO INIMIGO
            --------------------------------------------------

            local inimigo_x1 =
                enemy.x

            local inimigo_x2 =
                enemy.x + 2

            local inimigo_y1 =
                enemy.y

            local inimigo_y2 =
                enemy.y + 2


            --------------------------------------------------
            -- TESTE DE COLISÃO
            --------------------------------------------------

            local colisao =

                tiro_x1 <= inimigo_x2
                and

                tiro_x2 >= inimigo_x1
                and

                tiro_y1 <= inimigo_y2
                and

                tiro_y2 >= inimigo_y1


            if colisao then

                --------------------------------------------------
                -- DESTRÓI O INIMIGO
                --------------------------------------------------

                enemy.vivo = false


                --------------------------------------------------
                -- REMOVE O TIRO
                --------------------------------------------------

                tiro = nil


                --------------------------------------------------
                -- ADICIONA 10 PONTOS
                --------------------------------------------------

                pontos =
                    pontos + 10


                return

            end

        end

    end

end


--------------------------------------------------
-- DESENHA A TELA INICIAL UMA VEZ
--------------------------------------------------

utils.tela_inicio(
    pico
)


--------------------------------------------------
-- LOOP PRINCIPAL
--------------------------------------------------

while true do


    --------------------------------------------------
    -- TELA INICIAL
    --------------------------------------------------

    if estado == "inicio" then


        --------------------------------------------------
        -- Z
        --------------------------------------------------

        local z_agora =
            pico.get.key(pico.key.Z) == 1


        --------------------------------------------------
        -- Z FOI PRESSIONADO
        --------------------------------------------------

        if z_agora
        and not z_antes then

            estado = "jogo"


            --------------------------------------------------
            -- Impede que o mesmo Z dispare imediatamente
            --------------------------------------------------

            z_antes = true

        end


        --------------------------------------------------
        -- GUARDA ESTADO DA TECLA
        --------------------------------------------------

        z_antes =
            z_agora


        --------------------------------------------------
        -- DESENHA TELA INICIAL
        --------------------------------------------------

        utils.tela_inicio(
            pico
        )


    --------------------------------------------------
    -- JOGO
    --------------------------------------------------

    elseif estado == "jogo" then


        --------------------------------------------------
        -- TECLA P
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
        -- JOGO NÃO PAUSADO
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


            --------------------------------------------------
            -- ESTADO DA TECLA Z
            --------------------------------------------------

            z_antes =
                z_agora


            --------------------------------------------------
            -- MOVIMENTO DO TIRO
            --------------------------------------------------

            if tiro then

                tiro.y =
                    tiro.y - 2


                --------------------------------------------------
                -- TIRO SAIU DA TELA
                --------------------------------------------------

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
            -- VERIFICA VITÓRIA
            --
            -- É verificada depois da colisão do tiro.
            --------------------------------------------------

            if verificar_vitoria() then

                estado = "vitoria"

            else


                --------------------------------------------------
                -- VERIFICA DERROTA
                --------------------------------------------------

                if verificar_colisao_nave() then

                    estado = "derrota"

                end

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
    -- VITÓRIA
    --------------------------------------------------

    elseif estado == "vitoria" then


        utils.vitoria(
            pico
        )


    --------------------------------------------------
    -- DERROTA
    --------------------------------------------------

    elseif estado == "derrota" then


        utils.derrota(
            pico,
            pontos
        )

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
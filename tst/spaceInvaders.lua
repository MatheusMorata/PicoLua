local pico = dofile("../src/pico.lua")
local utils = dofile("utils.lua")


--------------------------------------------------
-- INICIALIZAÇÃO
--------------------------------------------------

pico.init(true)

pico.set.font("tiny.ttf", 12)

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
-- CONTROLE DO DISPARO
--------------------------------------------------

local z_antes = false


--------------------------------------------------
-- LIMITES DA NAVE
--------------------------------------------------

-- A nave possui largura de -3 até +3.
local NAVE_MIN_X = 3
local NAVE_MAX_X = 64 - 1 - 3


--------------------------------------------------
-- INIMIGOS
--------------------------------------------------

local inimigos = {}


--------------------------------------------------
-- CRIA 7 COLUNAS X 3 LINHAS
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

-- 1 = direita
-- -1 = esquerda
--
-- Começamos indo para a esquerda.

local inimigo_direcao = -1


--------------------------------------------------
-- VELOCIDADE
--------------------------------------------------

-- Tempo entre cada movimento dos inimigos,
-- em milissegundos.
--
-- 500 = lento
-- 300 = médio
-- 100 = rápido

local inimigo_intervalo = 500


--------------------------------------------------
-- CONTROLE DO TEMPO
--------------------------------------------------

local ultimo_movimento = pico.get.ticks()


--------------------------------------------------
-- DESENHA A PRIMEIRA CENA
--------------------------------------------------

utils.desenhar(
    pico,
    nave,
    inimigos,
    tiro,
    pontos
)


--------------------------------------------------
-- LOOP PRINCIPAL
--------------------------------------------------

while true do


    --------------------------------------------------
    -- MOVIMENTO DA NAVE PARA A ESQUERDA
    --------------------------------------------------

    if pico.get.key(pico.key.A) == 1 then

        nave.x = math.max(
            NAVE_MIN_X,
            nave.x - 1
        )

    end


    --------------------------------------------------
    -- MOVIMENTO DA NAVE PARA A DIREITA
    --------------------------------------------------

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


    --------------------------------------------------
    -- CRIA UM NOVO TIRO
    --
    -- Só dispara uma vez quando Z é pressionado.
    --------------------------------------------------

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


        --------------------------------------------------
        -- VERIFICA COLISÃO
        --------------------------------------------------

        if utils.colisao_tiro_inimigos(
            tiro,
            inimigos
        ) then

            --------------------------------------------------
            -- ACERTOU UM INIMIGO
            --------------------------------------------------

            pontos = pontos + 10

            tiro = nil


        --------------------------------------------------
        -- TIRO SAIU DA TELA
        --------------------------------------------------

        elseif tiro.y < 0 then

            tiro = nil

        end

    end


    --------------------------------------------------
    -- TEMPO ATUAL
    --------------------------------------------------

    local agora =
        pico.get.ticks()


    --------------------------------------------------
    -- MOVIMENTO DOS INIMIGOS
    --------------------------------------------------

    if agora - ultimo_movimento
        >= inimigo_intervalo then


        --------------------------------------------------
        -- ATUALIZA O TEMPO
        --------------------------------------------------

        ultimo_movimento = agora


        --------------------------------------------------
        -- VERIFICA SE ALGUM INIMIGO
        -- VAI SAIR DA TELA
        --------------------------------------------------

        local pode_mover = true


        for _, inimigo in ipairs(inimigos) do

            if inimigo.vivo then

                local proximo_x =
                    inimigo.x + inimigo_direcao


                --------------------------------------------------
                -- LIMITE ESQUERDO
                --------------------------------------------------

                if proximo_x < 0 then

                    pode_mover = false

                    break

                end


                --------------------------------------------------
                -- LIMITE DIREITO
                --------------------------------------------------

                if proximo_x + 2 >= 64 then

                    pode_mover = false

                    break

                end

            end

        end


        --------------------------------------------------
        -- MOVE OS INIMIGOS
        --------------------------------------------------

        if pode_mover then

            for _, inimigo in ipairs(inimigos) do

                if inimigo.vivo then

                    inimigo.x =
                        inimigo.x + inimigo_direcao

                end

            end


        --------------------------------------------------
        -- CHEGOU NA BORDA
        --------------------------------------------------

        else

            --------------------------------------------------
            -- INVERTE A DIREÇÃO
            --------------------------------------------------

            inimigo_direcao =
                -inimigo_direcao


            --------------------------------------------------
            -- DESCE UMA LINHA
            --------------------------------------------------

            for _, inimigo in ipairs(inimigos) do

                if inimigo.vivo then

                    inimigo.y =
                        inimigo.y + 1

                end

            end

        end

    end


    --------------------------------------------------
    -- DESENHA A CENA
    --------------------------------------------------

    utils.desenhar(
        pico,
        nave,
        inimigos,
        tiro,
        pontos
    )


    --------------------------------------------------
    -- DELAY DO LOOP
    --------------------------------------------------

    pico.input.delay(16)

end


--------------------------------------------------
-- FINALIZAÇÃO
--------------------------------------------------

pico.init(false)
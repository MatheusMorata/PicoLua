local pico = dofile("../src/pico.lua")

local utils = dofile("utils.lua")


--------------------------------------------------
-- INICIALIZAÇÃO
--------------------------------------------------

pico.init(true)

pico.set.title("Space Invaders")
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

-- inicio
-- jogo
-- novo_recorde
-- game_over


--------------------------------------------------
-- TECLAS
--------------------------------------------------

local z_antes = false
local p_antes = false
local y_antes = false

local a_antes = false
local d_antes = false

local w_antes = false
local s_antes = false


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
-- MELHOR PONTUAÇÃO
--------------------------------------------------

local melhor_pontuacao = 0


--------------------------------------------------
-- NOME DO RECORDISTA
--------------------------------------------------

local melhor_nome = {

    "A",
    "A",
    "A",
    "A",
    "A"

}


--------------------------------------------------
-- PAUSE
--------------------------------------------------

local pausado = false


--------------------------------------------------
-- POSIÇÃO DO NOME
--------------------------------------------------

local nome = {}

local nome_posicao = 1


--------------------------------------------------
-- LIMITES DA NAVE
--------------------------------------------------

local NAVE_MIN_X = 3

local NAVE_MAX_X =
    64 - 1 - 3


--------------------------------------------------
-- LINHA DE DERROTA
--
-- Se um inimigo chegar nesta linha,
-- o jogador perde.
--------------------------------------------------

local LINHA_DERROTA = 38


--------------------------------------------------
-- INIMIGOS
--------------------------------------------------

local inimigos = {}


--------------------------------------------------
-- CRIA OS INIMIGOS
--
-- 7 colunas x 3 linhas
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
-- CRIA INIMIGOS
--------------------------------------------------

criar_inimigos()


--------------------------------------------------
-- MOVIMENTO DOS INIMIGOS
--------------------------------------------------

local inimigo_direcao = 1

local INIMIGO_INTERVALO = 5

local contador_inimigo = 0


--------------------------------------------------
-- REINICIA O JOGO
--------------------------------------------------

local function reiniciar_jogo()

    nave.x = 32
    nave.y = 42

    tiro = nil

    pontos = 0

    pausado = false

    inimigo_direcao = 1

    contador_inimigo = 0

    z_antes = false
    p_antes = false

    criar_inimigos()

    estado = "jogo"

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
    -- ENCONTRA OS LIMITES
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
-- VERIFICA LINHA DE DERROTA
--------------------------------------------------

local function verificar_linha_derrota()

    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            --------------------------------------------------
            -- O inimigo possui 3 pixels de altura.
            --------------------------------------------------

            local parte_inferior =
                enemy.y + 2


            if parte_inferior >= LINHA_DERROTA then

                return true

            end

        end

    end


    return false

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
-- COLISÃO COM A NAVE
--------------------------------------------------

local function verificar_colisao_nave()

    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            local inimigo_x1 =
                enemy.x

            local inimigo_x2 =
                enemy.x + 2

            local inimigo_y1 =
                enemy.y

            local inimigo_y2 =
                enemy.y + 2


            local nave_x1 =
                nave.x - 3

            local nave_x2 =
                nave.x + 3

            local nave_y1 =
                nave.y

            local nave_y2 =
                nave.y + 4


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


    local tiro_x1 =
        tiro.x

    local tiro_x2 =
        tiro.x

    local tiro_y1 =
        tiro.y

    local tiro_y2 =
        tiro.y + 1


    for _, enemy in ipairs(inimigos) do

        if enemy.vivo then

            local inimigo_x1 =
                enemy.x

            local inimigo_x2 =
                enemy.x + 2

            local inimigo_y1 =
                enemy.y

            local inimigo_y2 =
                enemy.y + 2


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
-- INICIA REGISTRO DO RECORDE
--------------------------------------------------

local function iniciar_novo_recorde()

    nome = {

        nil,
        nil,
        nil,
        nil,
        nil

    }


    nome_posicao = 1

    estado = "novo_recorde"

end


--------------------------------------------------
-- CONVERTE SCANCODE PARA LETRA
--------------------------------------------------

local function obter_letra()

    local letras = {

        { "A", pico.key.A },
        { "B", pico.key.B },
        { "C", pico.key.C },
        { "D", pico.key.D },
        { "E", pico.key.E },
        { "F", pico.key.F },
        { "G", pico.key.G },
        { "H", pico.key.H },
        { "I", pico.key.I },
        { "J", pico.key.J },
        { "K", pico.key.K },
        { "L", pico.key.L },
        { "M", pico.key.M },
        { "N", pico.key.N },
        { "O", pico.key.O },
        { "P", pico.key.P },
        { "Q", pico.key.Q },
        { "R", pico.key.R },
        { "S", pico.key.S },
        { "T", pico.key.T },
        { "U", pico.key.U },
        { "V", pico.key.V },
        { "W", pico.key.W },
        { "X", pico.key.X },
        { "Y", pico.key.Y },
        { "Z", pico.key.Z }

    }


    for _, item in ipairs(letras) do

        local letra = item[1]
        local tecla = item[2]


        if tecla
        and pico.get.key(tecla) == 1 then

            return letra

        end

    end


    return nil

end


--------------------------------------------------
-- ESCREVE UMA LETRA
--------------------------------------------------

local function atualizar_nome()

    local letra =
        obter_letra()


    if letra then

        nome[nome_posicao] =
            letra

    end

end


--------------------------------------------------
-- LOOP DA TELA DE NOVO RECORDE
--------------------------------------------------

local function atualizar_novo_recorde()

    --------------------------------------------------
    -- A
    --------------------------------------------------

    local a_agora =
        pico.get.key(pico.key.A) == 1


    if a_agora
    and not a_antes then

        nome_posicao =
            math.max(
                1,
                nome_posicao - 1
            )

    end


    a_antes =
        a_agora


    --------------------------------------------------
    -- D
    --------------------------------------------------

    local d_agora =
        pico.get.key(pico.key.D) == 1


    if d_agora
    and not d_antes then

        nome_posicao =
            math.min(
                5,
                nome_posicao + 1
            )

    end


    d_antes =
        d_agora


    --------------------------------------------------
    -- W
    --------------------------------------------------

    local w_agora =
        pico.get.key(pico.key.W) == 1


    if w_agora
    and not w_antes then

        local atual =
            nome[nome_posicao]


        if atual then

            local codigo =
                string.byte(atual)


            codigo =
                codigo + 1


            if codigo > string.byte("Z") then

                codigo =
                    string.byte("A")

            end


            nome[nome_posicao] =
                string.char(codigo)

        else

            nome[nome_posicao] =
                "A"

        end

    end


    w_antes =
        w_agora


    --------------------------------------------------
    -- S
    --------------------------------------------------

    local s_agora =
        pico.get.key(pico.key.S) == 1


    if s_agora
    and not s_antes then

        local atual =
            nome[nome_posicao]


        if atual then

            local codigo =
                string.byte(atual)


            codigo =
                codigo - 1


            if codigo < string.byte("A") then

                codigo =
                    string.byte("Z")

            end


            nome[nome_posicao] =
                string.char(codigo)

        else

            nome[nome_posicao] =
                "Z"

        end

    end


    s_antes =
        s_agora


    --------------------------------------------------
    -- Z CONFIRMA
    --------------------------------------------------

    local z_agora =
        pico.get.key(pico.key.Z) == 1


    if z_agora
    and not z_antes then

        --------------------------------------------------
        -- Se a posição estiver vazia,
        -- coloca A automaticamente.
        --------------------------------------------------

        if not nome[nome_posicao] then

            nome[nome_posicao] =
                "A"

        end


        --------------------------------------------------
        -- Avança para a próxima posição
        --------------------------------------------------

        if nome_posicao < 5 then

            nome_posicao =
                nome_posicao + 1

        else

            --------------------------------------------------
            -- TERMINOU O NOME
            --------------------------------------------------

            for i = 1, 5 do

                melhor_nome[i] =
                    nome[i]

            end


            melhor_pontuacao =
                pontos


            estado =
                "game_over"

        end

    end


    z_antes =
        z_agora

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

            estado =
                "jogo"

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
            -- VITÓRIA
            --------------------------------------------------

            if verificar_vitoria() then

                estado =
                    "game_over"


            --------------------------------------------------
            -- DERROTA PELA LINHA
            --------------------------------------------------

            elseif verificar_linha_derrota() then

                if pontos > melhor_pontuacao then

                    iniciar_novo_recorde()

                else

                    estado =
                        "game_over"

                end


            --------------------------------------------------
            -- DERROTA POR COLISÃO COM A NAVE
            --------------------------------------------------

            elseif verificar_colisao_nave() then

                if pontos > melhor_pontuacao then

                    iniciar_novo_recorde()

                else

                    estado =
                        "game_over"

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
    -- NOVO RECORDE
    --------------------------------------------------

    elseif estado == "novo_recorde" then


        atualizar_novo_recorde()


        utils.novo_recorde(

            pico,

            nome,

            nome_posicao

        )


    --------------------------------------------------
    -- GAME OVER
    --------------------------------------------------

    elseif estado == "game_over" then


        --------------------------------------------------
        -- Y REINICIA
        --------------------------------------------------

        local y_agora =
            pico.get.key(pico.key.Y) == 1


        if y_agora
        and not y_antes then

            reiniciar_jogo()

        end


        y_antes =
            y_agora


        utils.game_over(

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
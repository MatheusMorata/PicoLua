local pico = dofile("../src/pico.lua")
local utils = dofile("utils.lua")

pico.init(true)

local nave = { x = 32, y = 42 } -- posição da nave (x = centro)
local tiro = nil                 -- { x, y } ou nil
local z_antes = false

-- limites: a nave tem largura de -3 a +3 em relação ao centro
local NAVE_MIN_X = 3
local NAVE_MAX_X = 64 - 1 - 3

utils.desenhar(pico, nave, tiro)

while true do

    -- MOVIMENTO
    if pico.get.key(pico.key.A) == 1 then
        nave.x = math.max(NAVE_MIN_X, nave.x - 1)
    end

    if pico.get.key(pico.key.D) == 1 then
        nave.x = math.min(NAVE_MAX_X, nave.x + 1)
    end

    -- DISPARO
    local z_agora = pico.get.key(pico.key.Z) == 1

    if z_agora and not z_antes and not tiro then
        tiro = {
            x = nave.x,
            y = nave.y - 1
        }
    end
    z_antes = z_agora

    if tiro then
        tiro.y = tiro.y - 2

        if tiro.y < 0 then
            tiro = nil
        end
    end

    utils.desenhar(pico, nave, tiro)
    pico.input.delay(16)
end

pico.init(false)
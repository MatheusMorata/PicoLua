-- IMPORTS
local SDL   = require "SDL"
local TTF   = require "SDL.ttf"
local MIXER = require "SDL.mixer"

-- TABLES
local pico = {
    set   = {},
    get   = {},
    input = {},
    output = {},
}

PICO_DIM = {}

function PICO_DIM.new(x, y)
    return { x = x, y = y }
end

local WIN, REN
local PICO_TITLE = 'pico-lua'
local PICO_DIM_PHY = PICO_DIM.new(640, 360)

function pico.init(on)
    if on then
        WIN = SDL.createWindow {
            title = PICO_TITLE,
            width = PICO_DIM_PHY.x,
            height = PICO_DIM_PHY.y,
            flags = {SDL.window.Shown}
        }

        SDL.createRenderer(WIN, -1, SDL.rendererFlags.Accelerated)
        REN:setDrawBlendMode(SDL.blendMode.Blend)
        TTF.init()
        MIXER.openAudio(22050, SDL.audioFormat.S16SYS, 2, 1024)
        
    end
end

return pico
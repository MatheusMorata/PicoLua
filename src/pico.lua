local SDL = require("SDL")

local pico = {}

local SDL  = require("SDL")
local TTF  = require("SDL.ttf")
local Mix  = require("SDL.mixer")

local pico = {}


function pico.iniciar(on)
    if on then
        SDL.init{ SDL.flags.Video }

        janela = SDL.createWindow{
            title  = "Pico Lua",
            width  = 800,
            height = 600,
            x      = SDL.window.centralized,
            y      = SDL.window.centralized,
            flags  = { SDL.window.Shown }
        }

        renderizador = SDL.createRenderer(janela, -1, SDL.rendererFlags.Accelerated)

        TTF.init()
        --Mix.openAudio(22050, Mix.audioFormat.S16SYS, 2, 1024)

    else
        if pico.font and pico.font.ttf then
            pico.font.ttf:close()
        end

        Mix.closeAudio()
        TTF.quit()

        if renderizador then renderizador:destroy() end
        if janela then janela:destroy() end

        SDL.quit()
    end
end

return pico
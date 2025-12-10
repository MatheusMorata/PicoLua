local pico = {}

local SDL  = require("SDL")
local TTF  = require("SDL.ttf")
local MIXER  = require("SDL.mixer")

function pico.limparTela()
    renderizador:setDrawColor({
        r = 0,
        g = 0,
        b = 0,
        a = 255
    })

    --if _noclip() then
        renderizador:clear()
    --else
        local r = renderizador:getClipRect()
        renderizador:fillRect(r)
    --end

    --renderizador:setDrawColor({
    --    r = 255,
    --    g = 255,
    --    b = 255,
    --    a = 255
    --})
end

function pico.iniciar(on)
    if on then
        assert(SDL.init{ SDL.flags.Video })

        janela = SDL.createWindow{
            title  = "Pico Lua",
            width  = 800,
            height = 600,
            x      = SDL.window.centralized,
            y      = SDL.window.centralized,
            flags  = { SDL.window.Shown, SDL.window.Resizable }
        }

        assert(janela)

        renderizador = SDL.createRenderer(janela, -1, SDL.rendererFlags.Accelerated)
        renderizador:setDrawBlendMode(SDL.blendMode.Blend)

        assert(renderizador)

        TTF.init()
        MIXER.openAudio(22050, SDL.audioFormat.S16, 2, 1024)

        pico.limparTela()
        SDL.pumpEvents()
        SDL.flushEvents(SDL.event.First, SDL.event.Last)
    else
        if pico.font and pico.font.ttf then
            pico.font.ttf:close()
        end

        MIXER.closeAudio()
        TTF.quit()

        if renderizador then renderizador:destroy() end
        if janela then janela:destroy() end
        SDL.quit()
    end
end

return pico
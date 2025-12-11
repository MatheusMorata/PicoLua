local pico = {}

local SDL  = require("SDL")
local TTF  = require("SDL.ttf")
local MIXER  = require("SDL.mixer")

local PICO_CLIP_RESET = {0, 0, 0, 0}

local S = {
    anchor = {
        pos = {PICO_CENTER, PICO_MIDDLE},
        rotate = {PICO_CENTER, PICO_MIDDLE}
    },
    angle = 0,
    clip = {0, 0, 0, 0},
    color = {
        clear = {0, 0, 0, 255},
        draw  = {255, 255, 255, 255}
    },
    crop = {0, 0, 0, 0},
    cursor = {
        x = 0,
        cur = {0,0}
    },
    dim = {
        window = PICO_DIM_WINDOW,
        world  = PICO_DIM_WORLD
    },
    expert = 0,
    flip = {0, 0},
    font = {ttf = nil, h = 0},
    fullscreen = 0,
    grid = 1,
    scroll = {0, 0},
    style = PICO_FILL,
    scale = {100, 100},
    zoom = {100, 100},
}

function pico.noclip()
    return (S.clip[3] == PICO_CLIP_RESET[3]) or
           (S.clip[4] == PICO_CLIP_RESET[4])
end

function pico.output_clear()
    
    renderer:setDrawColor({
        r = S.color.clear[1],
        g = S.color.clear[2],
        b = S.color.clear[3],
        a = S.color.clear[4]
    })

    if pico.noclip() then
        renderer:clear()
    else
        local r = SDL.Rect({
            w = 0,
            h = 0,
            x = 0,
            y = 0
        })
        renderer:getClipRect(r)
        renderer:fillRect(r)
    end

    renderer:setDrawColor({
        r = S.color.draw[1],
        g = S.color.draw[2],
        b = S.color.draw[3],
        a = S.color.draw[4]
    })
end

function pico.init(on)
    if on then
        assert(SDL.init{ SDL.flags.Video })

        window = SDL.createWindow{
            title  = "Pico Lua",
            width  = 800,
            height = 600,
            x      = SDL.window.centralized,
            y      = SDL.window.centralized,
            flags  = { SDL.window.Shown, SDL.window.Resizable }
        }

        assert(window)

        renderer = SDL.createRenderer(window, -1, SDL.rendererFlags.Accelerated)
        renderer:setDrawBlendMode(SDL.blendMode.Blend)

        assert(renderer)

        TTF.init()
        MIXER.openAudio(22050, SDL.audioFormat.S16, 2, 1024)

        pico.output_clear()
        SDL.pumpEvents()
        SDL.flushEvents(SDL.event.First, SDL.event.Last)
    else
        if S.font.ttf then
            S.font.ttf:close()
        end

        MIXER.closeAudio()
        TTF.quit()

        if renderer then renderer:destroy() end
        if window then window:destroy() end
        SDL.quit()
    end
end

return pico
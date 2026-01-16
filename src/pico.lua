local pico = {}

local SDL   = require("SDL")
local TTF   = require("SDL.ttf")
local MIXER = require("SDL.mixer")

local PICO_CLIP_RESET = {0, 0, 0, 0}
local DEFAULT_FONT = "tiny.ttf"

local S = {
    anchor = {
        pos = { x = PICO_CENTER or 0, y = PICO_MIDDLE or 0 },
        rotate = { x = PICO_CENTER or 0, y = PICO_MIDDLE or 0 }
    },

    angle = 0,

    clip = { x = 0, y = 0, w = 0, h = 0 },

    color = {
        clear = { r = 0, g = 0, b = 0, a = 255 },
        draw  = { r = 255, g = 255, b = 255, a = 255 }
    },

    crop = { x = 0, y = 0, w = 0, h = 0 },

    cursor = {
        x = 0,
        cur = { x = 0, y = 0 }
    },

    dim = {
        window = { x = 0, y = 0 },
        world  = { x = 0, y = 0 }
    },

    expert = 0,

    flip = { x = 0, y = 0 },

    font = { ttf = nil, h = 0 },

    fullscreen = 0,
    grid = 1,

    scroll = { x = 0, y = 0 },

    style = PICO_FILL or 0,

    scale = { x = 100, y = 100 },
    zoom  = { x = 100, y = 100 }
}

function pico.noclip()
    return (S.clip[3] == PICO_CLIP_RESET[3]) or
           (S.clip[4] == PICO_CLIP_RESET[4])
end

function pico.set_font(file, h)
    if not h or h == 0 then
        local wy =
            (S.dim.world  and S.dim.world.y)  or
            (S.dim.window and S.dim.window.y) or
            600
        h = math.max(8, math.floor(wy / 10))
    end

    S.font.h = h

    if S.font.ttf then
        S.font.ttf:close()
        S.font.ttf = nil
    end

    local font_file = file or DEFAULT_FONT
    local font, err = TTF.open(font_file, S.font.h)
    assert(font, err)

    S.font.ttf = font
end

function pico.output_clear()
    renderer:setDrawColor{
        r = S.color.clear[1],
        g = S.color.clear[2],
        b = S.color.clear[3],
        a = S.color.clear[4]
    }

    if pico.noclip() then
        renderer:clear()
    else
        local r = { x = 0, y = 0, w = 0, h = 0 }
        renderer:getClipRect(r)
        renderer:fillRect(r)
    end

    renderer:setDrawColor{
        r = S.color.draw[1],
        g = S.color.draw[2],
        b = S.color.draw[3],
        a = S.color.draw[4]
    }
end

function pico._zoom()
    return {
        x = S.dim.world.x * S.zoom.x / 100,
        y = S.dim.world.y * S.zoom.y / 100
    }
end

function pico.set_scroll(pos)
    S.scroll = pos;
end


function pico.set_zoom(pct)
    -- FUNÇÃO INCOMPLETA
    
    local old = pico._zoom()

    S.zoom.x = pct.x
    S.zoom.y = pct.y

    local new = pico._zoom()

    local dx = new.x - old.x
    local dy = new.y - old.y

    pico.set_scroll{
        x = S.scroll.x - (dx * S.anchor.pos.x / 100),
        y = S.scroll.y - (dy * S.anchor.pos.y / 100)
    }

    if TEX then
        TEX:destroy()
        TEX = nil
    end

    TEX = assert(
        renderer:createTexture(
            SDL.pixelFormat.RGBA32,
            SDL.textureAccess.Target,
            new.x,
            new.y
        )
    )

    renderer:setLogicalSize(new.x, new.y)
    renderer:setTarget(TEX)

    renderer:setClipRect{
        x = 0,
        y = 0,
        w = new.x,
        h = new.y
    }
end

function pico.init(on)
    if on then
        assert(SDL.init { SDL.flags.Video })

        window = assert(SDL.createWindow {
            title  = "Pico Lua",
            width  = 800,
            height = 600,
            x      = SDL.window.centralized,
            y      = SDL.window.centralized,
            flags  = { SDL.window.Shown, SDL.window.Resizable }
        })

        renderer = assert(SDL.createRenderer(
            window, -1, SDL.rendererFlags.Accelerated
        ))
        renderer:setDrawBlendMode(SDL.blendMode.Blend)

        TTF.init()
        MIXER.openAudio(22050, SDL.audioFormat.S16, 2, 1024)

        --pico.set_zoom(S.zoom)
        pico.set_font(nil, 0)
        pico.output_clear()

        SDL.pumpEvents()
        SDL.flushEvents(SDL.event.First, SDL.event.Last)
    else
        if S.font.ttf then
            S.font.ttf:close()
            S.font.ttf = nil
        end

        MIXER.closeAudio()
        TTF.quit()

        if renderer then renderer:destroy() end
        if window then window:destroy() end

        SDL.quit()
    end
end

return pico
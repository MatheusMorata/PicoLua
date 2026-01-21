local pico = {}

local SDL   = require "SDL"
local TTF   = require "SDL.ttf" 
local MIXER = require "SDL.mixer"
local TEX = nil
local CONFIG = dofile("../src/config.lua")
local PICO_CLIP_RESET = {0, 0, 0, 0}
local DEFAULT_FONT = "tiny.ttf"


local S = {
    clip = { x = 0, y = 0, w = 0, h = 0 },
    
    color = {
        clear = { r = 0, g = 0, b = 0, a = 255 },
        draw  = { r = 255, g = 255, b = 255, a = 255 }
    },

    expert = 0,

    view = {
        phy = CONFIG.Pico_Dim.new(500, 500),
        log = CONFIG.Pico_Dim.new(100, 100)
    },

    dim = {
        world  = { x = 0, y = 0 }
    },
    
    font = { ttf = nil, h = 0 },
    
    grid = 1,

    scroll = { x = 0, y = 0 },
    
    zoom  = { x = 100, y = 100 },

    size = { org = CONFIG.Pico_Dim.new(100, 100), cur = CONFIG.Pico_Dim.new(100, 100)}
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

function pico._output_clear()
    renderer:setDrawColor({
        r = S.color.clear[1],
        g = S.color.clear[2],
        b = S.color.clear[3],
        a = S.color.clear[4]
    })

    renderer:clear()

    renderer:setDrawColor({
        r = S.color.draw[1],
        g = S.color.draw[2],
        b = S.color.draw[3],
        a = S.color.draw[4]
    })
end

function pico.show_grid()
    if not S.grid then
        return
    end
    renderer:setDrawColor(0x77, 0x77, 0x77, 0x77)
    local phy = CONFIG.Pico_Dim.new(0,0)
    renderer:setLogicalSize(phy.w, phy.h)
    local step_x = phy.w / S.size.cur.x
    for i = 0, phy.w, step_x do
        renderer:drawLine(i, 0, i, phy.h)
    end
    local step_y = phy.h / S.size.cur.y
    for j = 0, phy.h, step_y do
        renderer:drawLine(0, j, phy.w, j)
    end
    renderer:setLogicalSize(S.size.cur.x, S.size.cur.y)
    renderer:setDrawColor({
        r = S.color.draw[1],
        g = S.color.draw[2],
        b = S.color.draw[3],
        a = S.color.draw[4]
    })
end


function pico._output_present(force)

    if S.expert and not force then
        return
    end
    renderer:setTarget(TEX)
    renderer:setDrawColor({
        r = 0x77,
        g = 0x77,
        b = 0x77,
        a = 0x77
    })
    renderer:clear()
    renderer:copy(TEX)
    show_grid()
    renderer:present()
    renderer:setDrawColor({
        r = S.color.draw[1],
        g = S.color.draw[2],
        b = S.color.draw[3],
        a = S.color.draw[4]
    })

    renderer:setTarget(TEX)
end


function pico.output_clear()
    pico._output_clear()
    pico._output_present(0)
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

function pico.init(on)
    if on then
        assert(SDL.init { SDL.flags.Video })

        window = assert(SDL.createWindow {
            title  = CONFIG.title,
            width  = CONFIG.undefined,
            height = CONFIG.undefined,
            x      = S.view.phy.w,
            y      = S.view.phy.h,
            flags  = { SDL.window.Shown }
        })

        renderer = assert(SDL.createRenderer(
            window, -1, SDL.rendererFlags.Accelerated
        ))

        renderer:setDrawBlendMode(SDL.blendMode.Blend)

        TTF.init()
        MIXER.openAudio(22050, SDL.audioFormat.S16, 2, 1024)

        --pico.set_size(CONFIG.PICO_DIM_PHY(), CONFIG.PICO_DIM_LOG())
        pico.set_font(nil, 0)
        pico.output_clear()

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
local pico = {}

local SDL   = require "SDL"
local TTF   = require "SDL.ttf" 
local MIXER = require "SDL.mixer"
local TEX = nil
local CONFIG = dofile("../src/config.lua")
local PICO_CLIP_RESET = {0, 0, 0, 0}
local DEFAULT_FONT = "tiny.ttf"


local S = {
    color = {
        clear = { 0, 0, 0, 255 },
        draw  = { 255, 255, 255, 255 }
    },

    expert = 0,

    view = {
        phy = CONFIG.Pico_Dim.new(500, 500)
    },

    dim = {
        world = { y = 0 }
    },

    font = {
        ttf = nil,
        h   = 0
    },

    grid = 1,

    size = {
        cur = CONFIG.Pico_Dim.new(100, 100),
        org = CONFIG.Pico_Dim.new(100, 100)
    }
}

function pico.get_size()
    return {PHY = CONFIG.PHY(window), S.size.org}
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

    local phy = CONFIG.PHY(window)

    renderer:setLogicalSize(phy.w, phy.h)

    local step_x = phy.w / S.size.cur.w
    for i = 0, phy.w, step_x do
        renderer:drawLine { i, 0, i, phy.h }
    end

    local step_y = phy.h / S.size.cur.h
    for j = 0, phy.h, step_y do
        renderer:drawLine { 0, j, phy.w, j }
    end

    renderer:setLogicalSize(S.size.cur.w, S.size.cur.h)

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
    pico.show_grid()
    renderer:present()
    renderer:setDrawColor({
        r = S.color.draw[1],
        g = S.color.draw[2],
        b = S.color.draw[3],
        a = S.color.draw[4]
    })

    renderer:setTarget(TEX)
end

function pico.output_present()
    pico._output_present(1)
end

function pico.output_clear()
    pico._output_clear()
    pico._output_present(0)
end

function pico.set_grid(on)
    S.grid = 0
    pico._output_present(0)
end

function pico._set_size(phy, log)
    local PICO_SIZE_KEEP = CONFIG.PICO_SIZE_KEEP()
    local PICO_SIZE_FULLSCREEN = CONFIG.PICO_SIZE_FULLSCREEN()
    local PHY = CONFIG.PHY(window)

    if phy.w ~= PICO_SIZE_KEEP.w or phy.h ~= PICO_SIZE_KEEP.h then
        if phy.w == PICO_SIZE_FULLSCREEN.w and phy.h == PICO_SIZE_FULLSCREEN.h then
            window:setSize(PHY.w, PHY.h)
        else
            window:setSize(phy.w, phy.h)
        end
    end

    if log.w ~= PICO_SIZE_KEEP.w or log.h ~= PICO_SIZE_KEEP.h then
        S.size.cur = log
        if TEX then renderer:destroyTexture(TEX) end
        TEX = renderer:createTexture(
            SDL.pixelFormat.RGBA8888,
            SDL.textureAccess.Target,
            S.size.cur.w,
            S.size.cur.h
        )
        renderer:setLogicalSize(S.size.cur.w, S.size.cur.h)
    end

    if PHY.w == S.size.cur.w or PHY.h == S.size.cur.h then
        S.grid = 0
    end

    pico._output_present(0)
end

function pico.set_size(phy, log)
    S.size.org = log
    pico._set_size(phy, log)
end

function pico.set_title(title)
    window:setTitle(title)
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

        pico.set_size(CONFIG.PICO_DIM_PHY(), CONFIG.PICO_DIM_LOG())
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
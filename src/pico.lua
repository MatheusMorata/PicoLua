local pico = {
    set   = {},
    get   = {},
    input = {},
    output = {},
    show = {}
}

local SDL   = require "SDL"
local TTF   = require "SDL.ttf"
local MIXER = require "SDL.mixer"

local TEX = nil
local title = "Titulo"
local undefined = "0x1FFF0000"
local DEFAULT_FONT = "tiny.ttf"
local PICO_LEFT   = 0
local PICO_CENTER = 50
local PICO_RIGHT  = 100
local PICO_TOP    = 0
local PICO_MIDDLE = 50
local PICO_BOTTOM = 100

local window, renderer

local function Pico_Dim(w, h)
    return { w = w or 0, h = h or 0 }
end

local function PICO_DIM_PHY()
    return Pico_Dim(500, 500)
end

local function PICO_DIM_LOG()
    return Pico_Dim(100, 100)
end

local function PICO_SIZE_KEEP()
    return Pico_Dim(0, 0)
end

local function PICO_SIZE_FULLSCREEN()
    return Pico_Dim(0, 1)
end

local function PHY(window)
    local w, h = window:getSize()
    return Pico_Dim(w, h)
end

local S = {
    anchor = {
        draw = { x = PICO_CENTER, y = PICO_MIDDLE },
        rotate = { x = PICO_CENTER, y = PICO_MIDDLE }
    },
    color = {
        clear = { r = 0, g = 0, b = 0, a = 255 },
        draw  = { r = 255, g = 255, b = 255, a = 255 }
    },
    expert = 0,
    view = {
        phy = Pico_Dim(500, 500)
    },
    dim = {
        world = { y = 0 }
    },
    font = {
        ttf = nil,
        h   = 0
    },
    grid = 1,
    angle = 0,
    size = {
        cur = Pico_Dim(100, 100),
        org = Pico_Dim(100, 100)
    },
    cursor = {
        x   = 0,
        cur = { x = 0, y = 0 }
    },
    flip = { x = 0, y = 0 },
    crop = { x = 0, y = 0, w = 0, h = 0 },
    scroll = { x = 0, y = 0 },
    zoom   = { x = 0, y = 0 }
}

local function output_clear()
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

local function output_present(force)
    if S.expert and not force then return end
    renderer:setTarget(TEX)
    renderer:setDrawColor(0x77, 0x77, 0x77, 0x77)
    renderer:clear()
    renderer:copy(TEX)
    pico.show.grid()
    renderer:present()
    renderer:setTarget(TEX)
end

local function set_size_internal(phy, log)
    local KEEP = PICO_SIZE_KEEP()
    local FULL = PICO_SIZE_FULLSCREEN()
    local CUR  = PHY(window)

    if phy.w ~= KEEP.w or phy.h ~= KEEP.h then
        if phy.w == FULL.w and phy.h == FULL.h then
            window:setSize(CUR.w, CUR.h)
        else
            window:setSize(phy.w, phy.h)
        end
    end

    if log.w ~= KEEP.w or log.h ~= KEEP.h then
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

    if CUR.w == S.size.cur.w or CUR.h == S.size.cur.h then
        S.grid = 0
    end

    output_present(0)
end

function pico.show.grid()
    if not S.grid then return end
    renderer:setDrawColor(0x77, 0x77, 0x77, 0x77)
    local phy = PHY(window)
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

function pico.set.anchor_draw(anchor)
    S.anchor.draw = anchor
end

function pico.set.anchor_rotate(rotate)
    S.anchor.rotate = rotate
end

function pico.set.color_clear(color)
    S.color.clear = color
end

function pico.set.color_draw(color)
    S.color.draw = color
    renderer:setDrawColor(color)
end

function pico.set.cursor(pos)
    S.cursor.cur = pos
    S.cursor.x = pos.x
end

function pico.set.expert(on)
    S.expert = on
end

function pico.set.flip(flip)
    S.flip = flip
end

function pico.set.crop(crop)
    S.crop = crop
end

function pico.set.rotate(angle)
    S.angle = angle
end

function pico.set.grid(on)
    S.grid = on and 1 or 0
    output_present(0)
end

function pico.set.scroll(pos)
    S.scroll = pos
end

function pico.set.zoom(zoom)
    S.zoom = zoom
    pico.set.scroll({
        x = S.scroll.x - (S.size.org.x - S.size.cur.x) / 2,
        y = S.scroll.y - (S.size.org.y - S.size.cur.y) / 2
    })
    set_size_internal(
        PICO_SIZE_KEEP(),
        {
            w = S.size.org.w * 100 / zoom.x,
            h = S.size.org.h * 100 / zoom.y
        }
    )
    pico.set.scroll({
        x = S.scroll.x + (S.size.org.x - S.size.cur.x) / 2,
        y = S.scroll.y + (S.size.org.y - S.size.cur.y) / 2
    })
end

function pico.set.font(file, h)
    if not h or h == 0 then
        local wy = (S.dim.world and S.dim.world.y) or 600
        h = math.max(8, math.floor(wy / 10))
    end
    S.font.h = h
    if S.font.ttf then
        S.font.ttf:close()
        S.font.ttf = nil
    end
    local font, err = TTF.open(file or DEFAULT_FONT, S.font.h)
    assert(font, err)
    S.font.ttf = font
end

function pico.set.size(phy, log)
    S.size.org = log
    set_size_internal(phy, log)
end

function pico.set.title(t)
    title = t
    if window then window:setTitle(t) end
end

function pico.get.size()
    return { phy = PHY(window), log = S.size.org }
end

function pico.input.event(evt, type)
    while true do
        local x = SDL.waitEvent()
        if event_from_sdl(x, type) then
            if evt ~= nil then
                for k, v in pairs(x) do
                    evt[k] = v
                end
            end
            return
        end
    end
end

function pico.input.delay(ms)
    while true do
        local old = SDL.getTicks()
        SDL.waitEvent(ms)
        local dt = SDL.getTicks() - old
        ms = ms - dt
        if ms <= 0 then return end
    end
end

function pico.output.clear()
    output_clear()
    output_present(0)
end

function pico.output.present()
    output_present(1)
end

function pico.init(on)
    if on then
        assert(SDL.init { SDL.flags.Video })
        window = assert(SDL.createWindow {
            title  = title,
            width  = undefined,
            height = undefined,
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
        pico.set.size(PICO_DIM_PHY(), PICO_DIM_LOG())
        pico.set.font(nil, 0)
        pico.output.clear()
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
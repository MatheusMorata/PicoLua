local pico = {
    set   = {},
    get   = {},
    input = {},
    output = {},
    show = {}
}

local SDL   = require("SDL")
local TTF   = require("SDL.ttf")
local MIXER = require("SDL.mixer")

local TEX = nil
local title = "Titulo"
local DEFAULT_FONT = "tiny.ttf"
local PICO_LEFT   = 0
local PICO_CENTER = 50
local PICO_RIGHT  = 100
local PICO_TOP    = 0
local PICO_MIDDLE = 50
local PICO_BOTTOM = 100
local SDL_ANY = -1

local window, renderer

local function Pico_Dim(w, h)
    return { w = w or 0, h = h or 0 }
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
    style = {
        fill = 0
    },
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
    zoom   = { x = 0, y = 0 },
    scale = {x = 100, y = 100}
}

-- LOCAL FUNCTIONS

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

local function hanchor(x, w)
    return x - (S.anchor.draw.x*w)/100
end 

local function vanchor(y, h)
    return y - (S.anchor.draw.y*h)/100
end

local function X(v, w)
    return hanchor(v, w) - S.scroll.x
end

local function Y(v, h)
    return vanchor(v, h) - S.scroll.y
end


local function set_size(phy, log)
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
        TEX = renderer:createTexture(
            SDL.pixelFormat.RGBA8888,
            SDL.textureAccess.Target,
            S.size.cur.w,
            S.size.cur.h
        )
        renderer:setLogicalSize(S.size.cur.w, S.size.cur.h)
        renderer:setTarget(TEX)
    end

    if CUR.w == S.size.cur.w or CUR.h == S.size.cur.h then
        S.grid = 0
    end

    output_present(0)
end

-- SETTERS
function pico.set.show(on)
    if on then
        window:show()
        output_present(0)
    else
        window:hide()
    end
end

function pico.set.style(style) 
    S.style = style
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

function pico.set.scale(scale)
    S.scale = scale     
end

function pico.set.zoom(zoom)
    S.zoom = zoom
    pico.set.scroll({
        x = S.scroll.x - (S.size.org.x - S.size.cur.x) / 2,
        y = S.scroll.y - (S.size.org.y - S.size.cur.y) / 2
    })
    set_size(
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
        S.font.ttf = nil
    end
    local font, err = TTF.open(file or DEFAULT_FONT, S.font.h)
    assert(font, err)
    S.font.ttf = font
end

function pico.set.size(phy, log)
    S.size.org = log
    set_size(phy, log)
end

function pico.set.title(t)
    title = t
    if window then window:setTitle(t) end
end

-- GETTERS

function pico.get.size()
    return { phy = PHY(window), log = S.size.org }
end

function pico.get.anchor_draw()
    return S.anchor.draw
end

function pico.get.anchor_rotate()
    return S.anchor.rotate
end

function pico.get.color_clear()
    return S.color.clear
end

function pico.get.cursor()
    return S.cursor.cur
end

function pico.get.expert()
    return S.expert
end

function pico.get.flip()
    return S.flip
end

function pico.get.grid()
    return S.grid
end

function pico.get.key(key)
    local keys = SDL.getKeyboardState()
    return keys[key]
end

function pico.get.mouse()
    local x, y = SDL.getMouseState()
    return { x = x, y = y}
end

function pico.get.crop()
    return S.crop
end

function pico.get.rotate()
    return S.angle
end

function pico.get.scale()
    return S.scale
end

function pico.get.scroll()
    return S.scroll
end

function pico.get.show()
    return (window:getFlags() & SDL.window.Shown) ~= 0
end

function pico.get.style()
    return S.style
end

function pico.get.ticks()
    return SDL.getTicks()
end

function pico.get.title()
    return window:getTitle()
end

function pico.get.zoom()
    return S.zoom
end

function pico.init(on)
    if on then
        SDL.init { SDL.flags.Video }
        window = SDL.createWindow {
            title  = title,
            width  = S.view.phy.w,
            height = S.view.phy.h,
            flags  = { SDL.window.Shown }
        }
        renderer = SDL.createRenderer(window, -1, SDL.rendererFlags.Accelerated)
        renderer:setDrawBlendMode(SDL.blendMode.Blend)
        TTF.init()
        MIXER.openAudio(22050, SDL.audioFormat.S16, 2, 1024)
        pico.set.size(PICO_DIM_PHY(), PICO_DIM_LOG())
        pico.output.clear()
    else
        MIXER.closeAudio()
        TTF.quit()
        SDL.quit()
    end
end

return pico
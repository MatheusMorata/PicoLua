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
    return y - (S.anchor.draw.x*h)/100
end

local function X(v, w)
    return hanchor(v, w) - S.scroll.x
end

local function Y(v, h)
    return vanchor(v, h) - S.scroll.y
end

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

local function show_grid()
    if not S.grid then return end
    renderer:setDrawColor({ r = 0x77, g = 0x77, b = 0x77, a = 0x77})
    local phy = PHY(window)
    renderer:setLogicalSize(phy.w, phy.h)
    local step_x = phy.w / S.size.cur.w
    for i = 0, phy.w, step_x do
        renderer:drawLine({ x1 = i, y1 = 0, x2 = i, y2 = phy.h })
    end
    local step_y = phy.h / S.size.cur.h
    for j = 0, phy.h, step_y do
        renderer:drawLine({ x1 = 0, y1 = j, x2 = phy.w, y2 = j })
    end
    renderer:setLogicalSize(S.size.cur.w, S.size.cur.h)
    renderer:setDrawColor {
        r = S.color.draw[1],
        g = S.color.draw[2],
        b = S.color.draw[3],
        a = S.color.draw[4]
    }
end

local function output_present(force)
    if S.expert and not force then return end
    renderer:setTarget(nil)
    renderer:setDrawColor({r = 0x77, g = 0x77, b = 0x77, a = 0x77})
    renderer:clear()
    renderer:copy(TEX)
    show_grid()
    renderer:present()
    renderer:setDrawColor({r = S.color.draw.r,
                           g = S.color.draw.g,
                           b = S.color.draw.b,
                           a = S.color.draw.a})
    renderer:setTarget(TEX)
end

local function output_draw_tex(pos, tex, size)

    -- tamanho original da textura
    local _, _, tw, th = TEX:query()

    local rct = { x = 0, y = 0, w = tw, h = th }

    -- crop
    local crp = {
        x = S.crop.x,
        y = S.crop.y,
        w = S.crop.w ~= 0 and S.crop.w or tw,
        h = S.crop.h ~= 0 and S.crop.h or th
    }

    -- sizing
    if size.x == 0 and size.y == 0 then
        rct.w = crp.w
        rct.h = crp.h

    elseif size.x == 0 then
        rct.w = rct.w * (size.y / rct.h)
        rct.h = size.y

    elseif size.y == 0 then
        rct.h = rct.h * (size.x / rct.w)
        rct.w = size.x

    else
        rct.w = size.x
        rct.h = size.y
    end

    -- SCALE
    rct.w = (S.scale.x * rct.w) / 100
    rct.h = (S.scale.y * rct.h) / 100

    -- posição final (anchor + scroll)
    rct.x = X(pos.x, rct.w)
    rct.y = Y(pos.y, rct.h)

    -- ponto de rotação
    local rot = {
        x = (S.anchor.rotate.x * rct.w) / 100,
        y = (S.anchor.rotate.y * rct.h) / 100
    }

    -- flip
    local flip = SDL.rendererFlip.None
    if S.flip.y then
        flip = SDL.rendererFlip.Vertical
    elseif S.flip.x then
        flip = SDL.rendererFlip.Horizontal
    end

    local angle = S.angle
    if S.flip.x and S.flip.y then
        angle = angle + 180
    end

    -- draw
    renderer:copyEx(
        tex,
        crp,
        rct,
        angle,
        rot,
        flip
    )

    output_present(0)
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

function pico.get_anchor_draw()
    return S.anchor.draw
end

function pico.get_anchor_rotate()
    return S.anchor.rotate
end

function pico.get_color_clear()
    return S.color.clear
end

function pico.get_cursor()
    return S.cursor.cur
end

function pico.get_expert()
    return S.expert
end

function pico.get_flip()
    return S.flip
end

function pico.get_grid()
    return S.grid
end

function pico.get_key(key)
    local keys = SDL.getKeyboardState()
    return keys[key]
end

function pico.get_mouse()
    local x, y = SDL.getMouseState()
    return { x = x, y = y}
end

function pico.get_crop()
    return S.crop
end

function pico.get_rotate()
    return S.angle
end

function pico.get_scale()
    return S.scale
end

function pico.get_scroll()
    return S.scroll
end

function pico.get_show()
    return (window:getFlags() & SDL.window.Shown) ~= 0
end

function pico.get_style()
    return S.style
end

function pico.get_ticks()
    return SDL.getTicks()
end

function pico.get_title()
    return window:getTitle()
end

function pico.get_zoom()
    return S.zoom
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

function pico.output.draw_line(p1, p2)
    
    local pos = {
        x = hanchor(math.min(p1.x, p2.x), 1),
        y = vanchor(math.min(p1.y, p2.y), 1)
    }
    
    local w = math.abs(p1.x - p2.x) + 1
    local h = math.abs(p1.y - p2.y) + 1

    local aux = renderer:createTexture(SDL.pixelFormat.RGBA8888, SDL.textureAccess.Target, w, h)
    
    aux:setBlendMode(SDL.blendMode.Blend)
    renderer:setTarget(aux)
    
    local clr = S.color.clear

    S.color.clear = { r = 0, g = 0, b = 0, a = 255 }
    output_clear()
    S.color.clear = clr
    renderer:drawLine(p1.x-pos.x,p1.y-pos.y, p2.x-pos.x,p2.y-pos.y)
    renderer:setTarget(TEX)
    
    local anc = S.anchor.draw

    S.anchor.draw = {x = PICO_LEFT, y = PICO_TOP }
    output_draw_tex(pos, aux, PICO_SIZE_KEEP())
    S.anchor.draw = anc;
    renderer:destroyTexture(aux)
end

function pico.output.draw_pixel(pos)
    renderer:drawPoint({
        x = X(pos.x, 1),
        y = Y(pos.y, 1)
    })
    output_present(0)
end

function pico.output.draw_pixels(apos, count)
    local vec = {}

    for i = 1, count do
        local p = apos[i]

        vec[#vec+1] = X(p.x, 1)
        vec[#vec+1] = Y(p.y, 1)
    end

    renderer:drawPoints(vec)
    output_present(0)
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
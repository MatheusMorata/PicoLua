-- IMPORTS
local SDL   = require "SDL"
local TTF   = require "SDL.ttf"
local IMG   = require "SDL.image"
local MIXER = require "SDL.mixer"

-- MODULES
local pico = {
    set   = {},
    get   = {},
    input = {},
    output = {},
}

-- VAR
PICO_LEFT =  0
PICO_CENTER = 50
PICO_RIGHT = 100
PICO_TOP = 0
PICO_MIDDLE = 50
PICO_BOTTOM = 100
local WIN
local REN
PICO_TITLE = 'PicoLua'

-- TYPES
local function Pico_Dim(x, y)
    return {
        x = x,
        y = y
    }
end

local function PHY()
    local w, h = WIN:getSize()
    return {
        x = w,
        y = h
    }
end

local function hanchor(x, w)
    return x - (S.anchor.draw.x * w) / 100
end

local function vanchor(y, h)
    return y - (S.anchor.draw.y * h) / 100
end

local function X(v, w)
    return hanchor(v, w) - S.scroll.x
end

local function Y(v, h)
    return vanchor(v, h) - S.scroll.y
end


local PICO_SIZE_KEEP = Pico_Dim(0, 0)
local PICO_SIZE_FULLSCREEN = Pico_Dim(0, 1)
local PICO_DIM_PHY = Pico_Dim(800, 600)
local PICO_DIM_LOG = Pico_Dim(64, 48)


S = {
    anchor = {
        draw   = { x = PICO_CENTER, y = PICO_MIDDLE },
        rotate = { x = PICO_CENTER, y = PICO_MIDDLE },
    },

    color = {
        clear = { r = 0,   g = 0,   b = 0,   a = 255 },
        draw  = { r = 255, g = 255, b = 255, a = 255 },
    },

    cursor = {
        x = 0,
        cur = { x = 0, y = 0 },
    },

    expert = false,

    font = {
        ttf = nil,
        h = 0,
    },

    grid = true,

    crop = {
        x = 0,
        y = 0,
        w = 0,
        h = 0,
    },

    scroll = {
        x = 0,
        y = 0,
    },

    size = {
        org = { x = 0, y = 0 },
        cur = { x = 0, y = 0 },
    },

    style = 'PICO_FILL',

    flip = {
        x = false,
        y = false,
    },

    angle = 0,

    zoom = {
        x = 100,
        y = 100,
    },

    scale = {
        x = 100,
        y = 100,
    },
}

-- SHOW GRID
local function show_grid()
    if not S.grid then return end

    REN:setDrawColor({ r = 119, g = 119, b = 119, a = 255 })

    local phy = PHY()
    REN:setLogicalSize(phy.x, phy.y)

    local stepX = math.max(1, math.floor(phy.x / S.size.cur.x))
    for i = 0, phy.x, stepX do
        REN:drawLine({
            x1 = i, y1 = 0,
            x2 = i, y2 = phy.y
        })
    end

    local stepY = math.max(1, math.floor(phy.y / S.size.cur.y))
    for j = 0, phy.y, stepY do
        REN:drawLine({
            x1 = 0, y1 = j,
            x2 = phy.x, y2 = j
        })
    end

    REN:setLogicalSize(S.size.cur.x, S.size.cur.y)
    REN:setDrawColor(S.color.draw)
end

-- LOCAL OUTPUT
local function output_present(force)
    if S.expert and not force then return end

    REN:setTarget()
    REN:setDrawColor({ r = 119, g = 119, b = 119, a = 119 })
    REN:clear()
    REN:copy(TEX)
    show_grid()
    REN:present()
    REN:setDrawColor(S.color.draw)
    REN:setTarget(TEX)
end

function output_draw_tex(pos, tex, size)

    local rct = {}

    local _, _, w, h = tex:query()

    rct.x = 0
    rct.y = 0
    rct.w = w
    rct.h = h


    local crp = {
        x = S.crop.x,
        y = S.crop.y,
        w = S.crop.w,
        h = S.crop.h
    }

    if S.crop.w == 0 then
        crp.w = rct.w
    end

    if S.crop.h == 0 then
        crp.h = rct.h
    end


    -- SIZE
    if size.x == 0 and size.y == 0 then
        -- tamanho normal da imagem
        rct.w = crp.w
        rct.h = crp.h

    elseif size.x == 0 then
        -- ajusta largura baseada na altura
        rct.w = rct.w * (size.y / rct.h)
        rct.h = size.y

    elseif size.y == 0 then
        -- ajusta altura baseada na largura
        rct.h = rct.h * (size.x / rct.w)
        rct.w = size.x

    else
        rct.w = size.x
        rct.h = size.y
    end


    -- SCALE
    rct.w = (S.scale.x * rct.w) / 100
    rct.h = (S.scale.y * rct.h) / 100


    -- ANCHOR / PAN
    rct.x = X(pos.x, rct.w)
    rct.y = Y(pos.y, rct.h)


    -- ROTATE
    local rot = {
        x = (S.anchor.rotate.x * rct.w) / 100,
        y = (S.anchor.rotate.y * rct.h) / 100
    }


    -- FLIP
    local flip

    if S.flip.x and S.flip.y then
        S.angle = S.angle + 180
    end

    if S.flip.y then
        flip = SDL.rendererFlip.Vertical

    elseif S.flip.x then
        flip = SDL.rendererFlip.Horizontal

    else
        flip = SDL.rendererFlip.None
    end


    REN:copyEx({
        texture = tex,
        source = crp,
        destination = rct,
        angle = S.angle,
        center = rot,
        flip = flip
    })


    output_present(0)
end


local function output_clear()
    REN:setDrawColor(S.color.clear)
    REN:clear()
    REN:setDrawColor(S.color.draw)
end


-- SET GRID
function pico.set.grid(on)
    S.grid = on
    output_present(true)
end


-- UTILS
function pico_dim_ext(pct, d)
    assert(pct.x >= 0 and pct.y >= 0, "negative dimensions")

    return {
        x = (pct.x * d.x) / 100,
        y = (pct.y * d.y) / 100
    }
end


function pico_pos_vs_rect(pt, r)
    return pico_pos_vs_rect_ext(
        pt,
        r,
        S.anchor.draw,
        S.anchor.draw
    )
end


function pico_pos_vs_rect_ext(pt, r, ap, ar)
    return pico_rect_vs_rect_ext(
        {
            x = pt.x,
            y = pt.y,
            w = 1,
            h = 1
        },
        r,
        ap,
        ar
    )
end


function pico.pos(pct)
    return pico_pos_ext(
        pct,
        {
            x = 0,
            y = 0,
            w = S.size.org.x,
            h = S.size.org.y
        },
        {
            x = PICO_LEFT,
            y = PICO_TOP
        }
    )
end


function pico_pos_ext(pct, r, anc)
    local old = S.anchor.draw

    S.anchor.draw = anc

    local pt = {
        x = hanchor(r.x, r.w) + (pct.x * r.w) / 100,
        y = vanchor(r.y, r.h) + (pct.y * r.h) / 100
    }

    S.anchor.draw = old

    return pt
end

-- LOCAL FUNCTION
local function event_from_sdl(e, xp)

    if e.type == SDL.event.Quit then

        if not S.expert then
            os.exit(0)
        end

    elseif e.type == SDL.event.KeyDown then

        local state = SDL.getKeyboardState()

        if not state[SDL.scancode.LCtrl] and
           not state[SDL.scancode.RCtrl] then
            goto check_event
        end

        local key = e.keysym.sym

        if key == SDL.key._0 then

            pico.set.zoom({
                x = 100,
                y = 100
            })

            pico.set.scroll({
                x = 0,
                y = 0
            })

        elseif key == SDL.key.Minus then

            pico.set.zoom({
                x = math.max(1, S.zoom.x - 10),
                y = math.max(1, S.zoom.y - 10)
            })

        elseif key == SDL.key.Equals then

            pico.set.zoom({
                x = S.zoom.x + 10,
                y = S.zoom.y + 10
            })

        elseif key == SDL.key.Left then

            pico.set.scroll({
                x = S.scroll.x - math.max(1, S.size.cur.x // 20),
                y = S.scroll.y
            })

        elseif key == SDL.key.Right then

            pico.set.scroll({
                x = S.scroll.x + math.max(1, S.size.cur.x // 20),
                y = S.scroll.y
            })

        elseif key == SDL.key.Up then

            pico.set.scroll({
                x = S.scroll.x,
                y = S.scroll.y - math.max(1, S.size.cur.y // 20)
            })

        elseif key == SDL.key.Down then

            pico.set.scroll({
                x = S.scroll.x,
                y = S.scroll.y + math.max(1, S.size.cur.y // 20)
            })

        elseif key == SDL.key.G then

            pico.set.grid(not S.grid)

        end
    end


    ::check_event::


    -- EVENT TYPE CHECK

    if xp == e.type then
        -- OK

    elseif xp == SDL.ANY then

        if e.type ~= SDL.event.KeyDown and
           e.type ~= SDL.event.KeyUp and
           e.type ~= SDL.event.MouseButtonDown and
           e.type ~= SDL.event.MouseButtonUp and
           e.type ~= SDL.event.MouseMotion and
           e.type ~= SDL.event.Quit then

            return false
        end

    else
        return false
    end


    -- SDL -> LOGICAL POSITION

    if e.type == SDL.event.MouseButtonDown or
       e.type == SDL.event.MouseButtonUp or
       e.type == SDL.event.MouseMotion then

        e.button.x = e.button.x + S.scroll.x
        e.button.y = e.button.y + S.scroll.y
    end

    return true
end

local function set_size(phy, log)

    -- Physical
    if phy.x == PICO_SIZE_KEEP.x and phy.y == PICO_SIZE_KEEP.y then
        -- keep

    elseif phy.x == PICO_SIZE_FULLSCREEN.x and phy.y == PICO_SIZE_FULLSCREEN.y then
        WIN:setFullscreen(SDL.window.Fullscreen)
        phy = PHY()

    else
        WIN:setFullscreen(0)
        WIN:setSize(phy.x, phy.y)
    end

    -- Logical
    if not (log.x == PICO_SIZE_KEEP.x and log.y == PICO_SIZE_KEEP.y) then
        S.size.cur = log

        if TEX then
            TEX = nil
        end

        TEX = REN:createTexture(
            SDL.pixelFormat.RGBA8888,
            SDL.textureAccess.Target,
            S.size.cur.x,
            S.size.cur.y
        )

        REN:setLogicalSize(S.size.cur.x, S.size.cur.y)
    end

    local w, h = WIN:getSize()
    if w == S.size.cur.x or h == S.size.cur.y then
        pico.set.grid(false)
    end

    output_present(false)
end


-- SETTERS
function pico.set.anchor_draw(anchor)
    S.anchor.draw = anchor
end

function pico.set.anchor_rotate(anchor)
    S.anchor.rotate = anchor
end

function pico.set.color_clear(color)
    S.color.clear = color
end

function pico.set.color_draw(color)
    S.color.draw = color
    REN:setDrawColor(color)
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

function pico.set.grid(on)
    S.grid = on
    output_present(false)
end

function pico.set.crop(crop) 
    S.crop = crop
end

function pico.set.rotate(angle)
    S.angle = angle
end

function pico.set.scale(scale)
    S.scale = scale
end

function pico.set.style(style)
    S.style = style
end

function pico.set.size(phy, log)
    S.size.org = log
    set_size(phy, log)
end

function pico.set.title(title)
    WIN:setTitle(title)
end

function pico.set.font(path, ptsize)
    if S.font.ttf then
        S.font.ttf:close()
    end

    ptsize = ptsize or 16

    if path == nil then
        S.font.ttf = nil
        S.font.h = ptsize
        return
    end

    S.font.ttf = TTF.open(path, ptsize)
    S.font.h = ptsize
end

function pico.set.scroll(pos)
    S.scroll = pos
end

function pico.set.zoom(zoom)
    S.zoom = {
        x = zoom.x,
        y = zoom.y
    }

    pico.set.scroll({
        x = S.scroll.x - (S.size.org.x - S.size.cur.x) // 2,
        y = S.scroll.y - (S.size.org.y - S.size.cur.y) // 2
    })

    set_size(
        PICO_SIZE_KEEP,
        {
            x = (S.size.org.x * 100) // S.zoom.x,
            y = (S.size.org.y * 100) // S.zoom.y
        }
    )

    pico.set.scroll({
        x = S.scroll.x + (S.size.org.x - S.size.cur.x) // 2,
        y = S.scroll.y + (S.size.org.y - S.size.cur.y) // 2
    })
end


-- INPUT
function pico.input.event_ask(evt, type)
    local has = SDL.pollEvent(evt)
    if not has then
        return 0
    end

    return event_from_sdl(evt, type)
end

function pico.input.delay(ms)
    while true do
        local old = SDL.getTicks()

        local event = SDL.waitEvent(ms)

        if event then
            event_from_sdl(event, "any")
        end

        local dt = SDL.getTicks() - old
        ms = ms - dt

        if ms <= 0 then
            return
        end
    end
end


-- OUTPUT
function pico.output.draw_tri(rect)

    local pos = {
        x = rect.x,
        y = rect.y
    }


    local aux = REN:createTexture(
        SDL.pixelFormat.RGBA8888,
        SDL.textureAccess.Target,
        rect.w,
        rect.h
    )


    REN:setDrawBlendMode(SDL.blendMode.Blend)
    REN:setTarget(aux)


    local clr = S.color.clear

    S.color.clear = {
        r = 0,
        g = 0,
        b = 0,
        a = 0
    }


    output_clear()


    S.color.clear = clr


    REN:setDrawColor(S.color.draw)


    if S.style == 'PICO_FILL' then

        for y = 0, rect.h - 1 do

            local largura = math.floor(
                (y / (rect.h - 1)) * rect.w
            )


            REN:fillRect({
                x = 0,
                y = y,
                w = largura,
                h = 1
            })

        end


    elseif S.style == 'PICO_STROKE' then

        REN:drawLine({
            x1 = 0,
            y1 = 0,
            x2 = 0,
            y2 = rect.h - 1
        })

        REN:drawLine({
            x1 = 0,
            y1 = rect.h - 1,
            x2 = rect.w - 1,
            y2 = rect.h - 1
        })

        REN:drawLine({
            x1 = 0,
            y1 = 0,
            x2 = rect.w - 1,
            y2 = rect.h - 1
        })

    end


    REN:setTarget(TEX)

    output_draw_tex(pos, aux, PICO_SIZE_KEEP)

    aux = nil
end

function pico.output.draw_rect(rect)

    local pos = {
        x = rect.x,
        y = rect.y
    }

    local aux = REN:createTexture(SDL.pixelFormat.RGBA8888, SDL.textureAccess.Target, rect.w, rect.h)

    REN:setDrawBlendMode(SDL.blendMode.Blend)

    REN:setTarget(aux)

    local clr = S.color.clear

    S.color.clear = {
        r = 0,
        g = 0,
        b = 0,
        a = 0
    }

    output_clear()

    S.color.clear = clr

    rect.x = 0
    rect.y = 0

    if S.style == 'PICO_FILL' then
        REN:fillRect(rect)

    elseif S.style == 'PICO_STROKE' then
        REN:drawRect(rect)
    end

    REN:setTarget(TEX)

    output_draw_tex(pos, aux, PICO_SIZE_KEEP)

    aux = nil
end

function pico.output.clear()
    output_clear()
    output_present(false)
end

-- INIT
function pico.init(on)
    if on then
        WIN = SDL.createWindow{
            title = PICO_TITLE,
            width = PICO_DIM_PHY.x,
            height = PICO_DIM_PHY.y,
            flags = {SDL.window.Shown}
        }

        REN = SDL.createRenderer(WIN, -1, SDL.rendererFlags.Accelerated)
        REN:setDrawBlendMode(SDL.blendMode.Blend)

        TTF.init()

        pico.set.size(PICO_DIM_PHY, PICO_DIM_LOG)
        pico.set.font(nil, 0)
        pico.output.clear()
    else
        if S.font.ttf then
            S.font.ttf:close()
        end
    end 
end

return pico
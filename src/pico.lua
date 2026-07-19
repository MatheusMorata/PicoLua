-- IMPORTS
local SDL   = require "SDL"
local TTF   = require "SDL.ttf"
local IMG   = require "SDL.image"
local MIXER = require "SDL.mixer"
 
-- TABLES
local pico = {
    set   = {},
    get   = {},
    input = {},
    output = {},
}
 
-- TYPES
PICO_DIM = {}
 
function PICO_DIM.new(w, h)
    return { x = w, y = h }
end
 
-- VARS
local WIN, REN, TEX
local PICO_TITLE   = 'pico-lua'
local PICO_DIM_PHY = PICO_DIM.new(640, 360)
local PICO_DIM_LOG = PICO_DIM.new(64, 36)
local PICO_FILL   = "fill"
local PICO_STROKE = "stroke"
local PICO_LEFT  = 0
local PICO_CENTER = 50
local PICO_RIGHT = 100
local PICO_TOP = 0
local PICO_MIDDLE = 50
local PICO_BOTTOM = 100
 
local S = {
    anchor = {
        draw = {
            x = PICO_CENTER,
            y = PICO_MIDDLE
        },
        rotate = {
            x = PICO_CENTER,
            y = PICO_MIDDLE
        }
    },

    color = {
        clear = {
            r = 0,
            g = 0,
            b = 0,
            a = 255
        },
        draw = {
            r = 255,
            g = 255,
            b = 255,
            a = 255
        }
    },

    cursor = {
        x = 0,
        cur = {
            x = 0,
            y = 0
        }
    },

    expert = false,

    font = {
        ttf = nil,
        h = 0
    },

    grid = true,

    crop = {
        x = 0,
        y = 0,
        w = 0,
        h = 0
    },

    scroll = {
        x = 0,
        y = 0
    },

    size = {
        org = {
            x = 0,
            y = 0
        },
        cur = {
            x = 0,
            y = 0
        }
    },

    style = PICO_FILL,

    flip = {
        x = 0,
        y = 0
    },

    angle = 0,

    zoom = {
        x = 100,
        y = 100
    },

    scale = {
        x = 100,
        y = 100
    }
}
 
PICO_SIZE_KEEP = { x = 0, y = 0 }
PICO_SIZE_FULLSCREEN = { x = 0, y = 1 }
 
local function PHY()
    local w, h = WIN:getSize()
    return { x = w, y = h }
end
 
function hanchor(x, w)
    return x - (S.anchor.draw.x * w) / 100
end
 
function vanchor(y, h)
    return y - (S.anchor.draw.y * h) / 100
end
 
local function X(v, w)
    return hanchor(v, w) - S.scroll.x
end
 
local function Y(v, h)
    return vanchor(v, h) - S.scroll.y
end
 
-- LOCAL FUNCTIONS
 
local function draw_polygon_stroke(ax, ay)
    local n = #ax
    for i = 1, n do
        local j = (i % n) + 1
        REN:drawLine({
            x1 = ax[i], y1 = ay[i],
            x2 = ax[j], y2 = ay[j]
        })
    end
end

local function draw_polygon_fill(ax, ay)
    local n = #ax
    local miny, maxy = math.maxinteger, math.mininteger
    for i = 1, n do
        miny = math.min(miny, ay[i])
        maxy = math.max(maxy, ay[i])
    end

    for y = miny, maxy do
        local intersections = {}
        for i = 1, n do
            local j = (i % n) + 1
            local yi, yj = ay[i], ay[j]
            if (yi <= y and yj > y) or (yj <= y and yi > y) then
                local t = (y - yi) / (yj - yi)
                table.insert(intersections, ax[i] + t * (ax[j] - ax[i]))
            end
        end
        table.sort(intersections)
        for i = 1, #intersections - 1, 2 do
            REN:drawLine({
                x1 = math.floor(intersections[i]),   y1 = y,
                x2 = math.floor(intersections[i+1]), y2 = y
            })
        end
    end
end

local function output_clear()
    REN:setDrawColor(S.color.clear)
    REN:clear()
    REN:setDrawColor(S.color.draw)
end
 
local function show_grid()
    if not S.grid then return end
 
    REN:setDrawColor({ r = 119, g = 119, b = 119, a = 119 })

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
 
local function output_present(force)
    if S.expert and not force then return end
 
    REN:setTarget()
    REN:setDrawColor({ r = 119, g = 119, b = 119, a = 119 })
    REN:clear()
    if TEX then
        REN:copy(TEX, nil, nil)
    end
    show_grid()
    REN:present()
    REN:setDrawColor(S.color.draw)
    REN:setTarget(TEX)
end
 
local function output_draw_tex(pos, tex, size)
    local _, _, tw, th = tex:query()

    local rct = {
        x = 0,
        y = 0,
        w = tw,
        h = th
    }

    local crp = {
        x = S.crop.x,
        y = S.crop.y,
        w = S.crop.w,
        h = S.crop.h
    }

    if crp.w == 0 then
        crp.w = tw
    end

    if crp.h == 0 then
        crp.h = th
    end

    if size.x == 0 and size.y == 0 then
        rct.w = crp.w
        rct.h = crp.h

    elseif size.x == 0 then
        rct.w = tw * (size.y / th)
        rct.h = size.y

    elseif size.y == 0 then
        rct.h = th * (size.x / tw)
        rct.w = size.x

    else
        rct.w = size.x
        rct.h = size.y
    end

    rct.w = rct.w * S.scale.x / 100
    rct.h = rct.h * S.scale.y / 100

    rct.x = X(pos.x, rct.w)
    rct.y = Y(pos.y, rct.h)

    local center = {
        x = rct.w * S.anchor.rotate.x / 100,
        y = rct.h * S.anchor.rotate.y / 100
    }

    local flip

    if S.flip.x and S.flip.y then
        flip = SDL.rendererFlip.Horizontal | SDL.rendererFlip.Vertical

    elseif S.flip.x then
        flip = SDL.rendererFlip.Horizontal

    elseif S.flip.y then
        flip = SDL.rendererFlip.Vertical

    else
        flip = SDL.rendererFlip.None
    end

    local angle = S.angle

    if S.flip.x and S.flip.y then
        angle = angle + 180
    end

    REN:copyEx{
        texture = tex,
        source = crp,
        destination = rct,
        angle = angle,
        center = center,
        flip = flip
    }

    output_present(false)
end

local function set_size(phy, log)
    -- PHYSICAL
    if phy.x == PICO_SIZE_KEEP.x and phy.y == PICO_SIZE_KEEP.y then
        -- keep
 
    elseif phy.x == PICO_SIZE_FULLSCREEN.x and phy.y == PICO_SIZE_FULLSCREEN.y then
        WIN:setFullscreen(SDL.window.FullscreenDesktop)
        phy = PHY()
 
    else
        WIN:setFullscreen(0)
        WIN:setSize(phy.x, phy.y)
    end
 
    -- LOGICAL
    if not (log.x == PICO_SIZE_KEEP.x and log.y == PICO_SIZE_KEEP.y) then
        S.size.cur = log
 
        TEX = REN:createTexture(
            SDL.pixelFormat.RGBA8888,
            SDL.textureAccess.Target,
            S.size.cur.x,
            S.size.cur.y
        )
 
        REN:setLogicalSize(S.size.cur.x, S.size.cur.y)
    end
 
    local phy_now = PHY()
    if phy_now.x == S.size.cur.x or phy_now.y == S.size.cur.y then
        pico.set.grid(false)
    end
 
    output_present(false)
end
  
local function has_ctrl()
    local state = SDL.getKeyboardState()
    return state[SDL.SCANCODE_LCTRL] or state[SDL.SCANCODE_RCTRL]
end

local function zoom_reset()
    pico.set.zoom({ x = 100, y = 100 })
    pico.set.scroll({ x = 0, y = 0 })
end

local function event_from_sdl(e, xp)
    if e.type == SDL.QUIT then
        if not S.expert then
            os.exit(0)
        end

    elseif e.type == SDL.KEYDOWN then
        local state = SDL.getKeyboardState()

        if state[SDL.SCANCODE_LCTRL] or state[SDL.SCANCODE_RCTRL] then
            local key = e.key.keysym.sym

            if key == SDL.K_0 then
                pico.set.zoom({ x = 100, y = 100 })
                pico.set.scroll({ x = 0, y = 0 })

            elseif key == SDL.K_MINUS then
                pico.set.zoom({
                    x = math.max(1, S.zoom.x - 10),
                    y = math.max(1, S.zoom.y - 10)
                })

            elseif key == SDL.K_EQUALS then
                pico.set.zoom({
                    x = S.zoom.x + 10,
                    y = S.zoom.y + 10
                })

            elseif key == SDL.K_LEFT then
                pico.set.scroll({
                    x = S.scroll.x - math.max(1, S.size.cur.x // 20),
                    y = S.scroll.y
                })

            elseif key == SDL.K_RIGHT then
                pico.set.scroll({
                    x = S.scroll.x + math.max(1, S.size.cur.x // 20),
                    y = S.scroll.y
                })

            elseif key == SDL.K_UP then
                pico.set.scroll({
                    x = S.scroll.x,
                    y = S.scroll.y - math.max(1, S.size.cur.y // 20)
                })

            elseif key == SDL.K_DOWN then
                pico.set.scroll({
                    x = S.scroll.x,
                    y = S.scroll.y + math.max(1, S.size.cur.y // 20)
                })

            elseif key == SDL.K_g then
                pico.set.grid(not S.grid)
            end
        end
    end

    if xp == e.type then
        -- ok

    elseif xp == SDL.ANY then
        if e.type ~= SDL.KEYDOWN
        and e.type ~= SDL.KEYUP
        and e.type ~= SDL.MOUSEBUTTONDOWN
        and e.type ~= SDL.MOUSEBUTTONUP
        and e.type ~= SDL.MOUSEMOTION
        and e.type ~= SDL.QUIT then
            return false
        end

    else
        return false
    end

    if e.type == SDL.MOUSEBUTTONDOWN
    or e.type == SDL.MOUSEBUTTONUP
    or e.type == SDL.MOUSEMOTION then
        e.button.x = e.button.x + S.scroll.x
        e.button.y = e.button.y + S.scroll.y
    end

    return true
end

-- INPUT
function pico.input.delay(ms)
    while true do
        local old = SDL.getTicks()
        local e = SDL.waitEvent(ms)
        if e then
            event_from_sdl(e, SDL.ANY)
        end
        local dt = SDL.getTicks() - old
        ms = ms - dt
        if ms <= 0 then
            return
        end
    end
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

    REN:setDrawColor({
        r = color.r,
        g = color.g,
        b = color.b,
        a = color.a or 255
    })
end

function pico.set.crop(rect)
    S.crop = {
        x = rect.x or 0,
        y = rect.y or 0,
        w = rect.w or 0,
        h = rect.h or 0
    }
end

function pico.set.cursor(pos)
    S.cursor.cur = {
        x = pos.x,
        y = pos.y
    }
end

function pico.set.expert(on)
    S.expert = on
end

function pico.set.flip(flip)
    S.flip = {
        x = flip.x or 0,
        y = flip.y or 0
    }
end

function pico.set.font(path, ptsize)
    if S.font.ttf then
        S.font.ttf:close()
    end

    ptsize = ptsize or 16

    S.font.ttf = TTF.open(path, ptsize)
    S.font.h = ptsize
end

function pico.set.grid(on)
    S.grid = on
    output_present(true)
end

function pico.set.rotate(angle)
    S.angle = angle or 0
end

function pico.set.scale(scale)
    S.scale = {
        x = scale.x or 100,
        y = scale.y or 100
    }
end

function pico.set.scroll(scroll)
    S.scroll = {
        x = scroll.x or 0,
        y = scroll.y or 0
    }
end

function pico.set.show(show)
    if show then
        WIN:show()
    else
        WIN:hide()
    end
end

function pico.set.size(phy, log)
    S.size.org = {
        x = log.x,
        y = log.y
    }

    set_size(phy, log)
end

function pico.set.style(style)
    S.style = style
end

function pico.set.title(title)
    PICO_TITLE = title
    WIN:setTitle(title)
end

function pico.set.zoom(zoom)

    S.zoom = {
        x = zoom.x or 100,
        y = zoom.y or 100
    }

    pico.set.scroll({
        x = S.scroll.x - (S.size.org.x - S.size.cur.x) / 2,
        y = S.scroll.y - (S.size.org.y - S.size.cur.y) / 2
    })

    set_size(
        PICO_SIZE_KEEP,
        {
            x = S.size.org.x * 100 / S.zoom.x,
            y = S.size.org.y * 100 / S.zoom.y
        }
    )

    pico.set.scroll({
        x = S.scroll.x + (S.size.org.x - S.size.cur.x) / 2,
        y = S.scroll.y + (S.size.org.y - S.size.cur.y) / 2
    })
end

-- GETTERS

function pico.get.anchor_draw()
    return S.anchor.draw
end

function pico.get.anchor_rotate()
    return S.anchor.rotate
end

function pico.get.color_clear()
    return S.color.clear
end

function pico.get.color_draw()
    return S.color.draw
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

function pico.get.font()
    if S.font.ttf then
        return S.font.ttf:faceFamilyName()
    end
    return nil
end

function pico.get.grid()
    return S.grid
end

function pico.get.key(scancode)
    local state = SDL.getKeyboardState()
    return state[scancode]
end

function pico.get.mouse()
    local _, x, y = SDL.getMouseState()
    return {
        x = x,
        y = y
    }
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

function pico.get.size()
    return {
        phy = PHY(),
        log = S.size.org
    }
end

function pico.get.size_image(path)
    local surface = IMG.load(path)
    if not surface then
        error("Unable to load image: "..path)
    end

    local w, h = surface.w, surface.h
    surface:free()

    return { x = w, y = h }
end

function pico.get.size_text(text)
    if text == "" then
        return { x = 0, y = 0 }
    end

    local w, h = S.font.ttf:sizeText(text)
    return { x = w, y = h }
end

function pico.get.show()
    local flags = WIN:getFlags()
    return flags.Shown
end

function pico.get.style()
    return S.style
end

function pico.get.ticks()
    return SDL.getTicks()
end

function pico.get.title()
    return WIN:getTitle()
end

function pico.get.zoom()
    return S.zoom
end
 
-- OUTPUT
function pico.output.draw_line(p1, p2)
    local pos = {
        x = hanchor(math.min(p1.x, p2.x), 1),
        y = vanchor(math.min(p1.y, p2.y), 1)
    }
    local aux = REN:createTexture(
        SDL.pixelFormat.RGBA8888,
        SDL.textureAccess.Target,
        math.abs(p1.x - p2.x) + 1,
        math.abs(p1.y - p2.y) + 1
    )
    aux:setBlendMode(SDL.blendMode.Blend)
    REN:setTarget(aux)
    local clr = S.color.clear
    S.color.clear = { r = 0, g = 0, b = 0, a = 0 }
    output_clear()
    S.color.clear = clr
    REN:drawLine({
        x1 = p1.x - pos.x, y1 = p1.y - pos.y,
        x2 = p2.x - pos.x, y2 = p2.y - pos.y
    })
    REN:setTarget(TEX)
    local anc = S.anchor.draw
    S.anchor.draw = { x = PICO_LEFT, y = PICO_TOP }
    output_draw_tex(pos, aux, PICO_SIZE_KEEP)
    S.anchor.draw = anc
end

function pico.output.clear()
    output_clear()
    output_present(false)
end

function pico.output.draw_image_ext(pos, path, size)
    local surface = IMG.load(path)
    local tex = REN:createTextureFromSurface(surface)
    output_draw_tex(pos, tex, size)
end

function pico.output.draw_image(pos, path)
    pico.output.draw_image_ext(pos, path, PICO_SIZE_KEEP)
end

function pico.output.draw_rect(rect)
    local pos = {x = rect.x, y = rect.y}

    local aux = REN:createTexture(
        SDL.pixelFormat.RGBA8888,
        SDL.textureAccess.Target,
        rect.w,
        rect.h
    )

    aux:setBlendMode(SDL.blendMode.Blend)

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

    if S.style == PICO_FILL then
        REN:fillRect(rect)
    elseif S.style == PICO_STROKE then
        REN:drawRect(rect)
    end

    REN:setTarget(TEX)

    output_draw_tex(pos, aux, PICO_SIZE_KEEP)

    aux:destroy()
end
 
function pico.output.draw_pixel(pos)
    REN:setTarget(TEX)
    REN:setDrawColor(S.color.draw)
    REN:drawPoint({x = math.floor(X(pos.x, 1)), y = math.floor(Y(pos.y, 1))})
    output_present(false)
end
 
function pico.output.draw_pixels(apos)
    local vec = {}
    for i, pos in ipairs(apos) do
        vec[i] = {
            x = math.floor(X(pos.x, 1)),
            y = math.floor(Y(pos.y, 1))
        }
    end
    REN:drawPoints(vec)
    output_present(false)
end

function pico.output.draw_poly(apos)
    local minx, maxx = math.maxinteger, math.mininteger
    local miny, maxy = math.maxinteger, math.mininteger

    for _, p in ipairs(apos) do
        minx = math.min(p.x, minx)
        maxx = math.max(p.x, maxx)
        miny = math.min(p.y, miny)
        maxy = math.max(p.y, maxy)
    end

    local ax, ay = {}, {}
    for i, p in ipairs(apos) do
        ax[i] = p.x - minx
        ay[i] = p.y - miny
    end

    local pos = {
        x = hanchor(minx, 1),
        y = vanchor(miny, 1)
    }

    local aux = REN:createTexture(
        SDL.pixelFormat.RGBA8888,
        SDL.textureAccess.Target,
        maxx - minx + 1,
        maxy - miny + 1
    )
    aux:setBlendMode(SDL.blendMode.Blend)
    REN:setTarget(aux)

    local clr = S.color.clear
    S.color.clear = { r = 0, g = 0, b = 0, a = 0 }
    output_clear()
    S.color.clear = clr

    local c = S.color.draw
    if S.style == PICO_FILL then
        draw_polygon_fill(ax, ay)
    elseif S.style == PICO_STROKE then
        draw_polygon_stroke(ax, ay)
    end

    REN:setTarget(TEX)
    local anc = S.anchor.draw
    S.anchor.draw = { x = PICO_LEFT, y = PICO_TOP }
    output_draw_tex(pos, aux, PICO_SIZE_KEEP)
    S.anchor.draw = anc
end

-- INIT
 
function pico.init(on)
    if on then
        WIN = SDL.createWindow {
            title = PICO_TITLE,
            width = PICO_DIM_PHY.x,
            height = PICO_DIM_PHY.y,
            flags = { SDL.window.Shown }
        }
 
        REN = SDL.createRenderer(WIN, -1, SDL.rendererFlags.Accelerated)
        REN:setDrawBlendMode(SDL.blendMode.Blend)
 
        TTF.init()
        MIXER.openAudio(22050, SDL.audioFormat.S16SYS, 2, 1024)
 
        pico.set.size(PICO_DIM_PHY, PICO_DIM_LOG)
        pico.output.clear()
 
    else
        MIXER.closeAudio()
        TTF.quit()
        SDL.quit()
    end
end
 
return pico
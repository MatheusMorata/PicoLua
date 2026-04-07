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
    grid = true,
    expert = false,
    style = PICO_FILL,
    angle = 0,
    size = {
        org = {x = 0, y = 0},
        cur = {x = 0, y = 0}
    },
    color = {
        clear = { r = 0, g = 0, b = 0, a = 255 },
        draw  = { r = 255, g = 255, b = 255, a = 255 }
    },
    anchor = {
        draw = { x = PICO_CENTER, y = PICO_MIDDLE },
        rotate = { x = PICO_CENTER, y = PICO_MIDDLE }
    },
    crop = { x = 0, y = 0, w = 0, h = 0 },
    scale = { x = 100, y = 100 },
    scroll = { x = 0, y = 0 },
    flip = { x = 0, y = 0 },
    zoom = { x = 0, y = 0}
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
    local rct = {x = 0, y = 0, w = 0, h = 0}
    _, _, rct.w, rct.h = tex:query()
    local crp = S.crop
    if S.crop.w == 0 then
        crp.w = rct.w
    end
    if S.crop.h == 0 then
        crp.h = rct.h
    end
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

    rct.w = (S.scale.x*rct.w)/100
    rct.h = (S.scale.y*rct.h)/100

    rct.x = X(pos.x, rct.w);
    rct.y = Y(pos.y, rct.h);

    local rot =  {
        w = (S.anchor.rotate.x*rct.w)/100,
        h = (S.anchor.rotate.y*rct.h)/100
    }

    REN:copyEx{
        texture = tex,
        source  = { x = 0, y = 0, w = 10, h = 20 },
        flip    = SDL.rendererFlip.Horizontal
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
  
function event_from_sdl(e, xp)
    if e.type == SDL.QUIT then
        if not S.expert then
            os.exit(0)
        end
 
    elseif e.type == SDL.KEYDOWN then
        local state = SDL.getKeyboardState()
 
        if not state[SDL.SCANCODE_LCTRL] and not state[SDL.SCANCODE_RCTRL] then
            return 0
        end
 
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
                x = S.scroll.x - math.max(1, S.size.cur.x / 20),
                y = S.scroll.y
            })
 
        elseif key == SDL.K_RIGHT then
            pico.set.scroll({
                x = S.scroll.x + math.max(1, S.size.cur.x / 20),
                y = S.scroll.y
            })
 
        elseif key == SDL.K_UP then
            pico.set.scroll({
                x = S.scroll.x,
                y = S.scroll.y - math.max(1, S.size.cur.y / 20)
            })
 
        elseif key == SDL.K_DOWN then
            pico.set.scroll({
                x = S.scroll.x,
                y = S.scroll.y + math.max(1, S.size.cur.y / 20)
            })
 
        elseif key == SDL.K_g then
            pico.set.grid(not S.grid)
        end
    end
 
    if xp == e.type then
    elseif xp == SDL.ANY then
        if not (
            e.type == SDL.KEYDOWN or
            e.type == SDL.KEYUP or
            e.type == SDL.MOUSEBUTTONDOWN or
            e.type == SDL.MOUSEBUTTONUP or
            e.type == SDL.MOUSEMOTION or
            e.type == SDL.QUIT
        ) then
            return false
        end
    else
        return false
    end
 
    if e.type == SDL.MOUSEBUTTONDOWN or
       e.type == SDL.MOUSEBUTTONUP or
       e.type == SDL.MOUSEMOTION then
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
 
function pico.set.scroll(pos)
    S.scroll = pos
end
 
function pico.set.zoom(zoom)
    S.zoom = zoom
 
    pico.set.scroll({
        x = S.scroll.x - (S.size.org.x - S.size.cur.x) / 2,
        y = S.scroll.y - (S.size.org.y - S.size.cur.y) / 2
    })
 
    set_size(
        PICO_SIZE_KEEP,
        {
            x = S.size.org.x * 100 / zoom.x,
            y = S.size.org.y * 100 / zoom.y
        }
    )
 
    pico.set.scroll({
        x = S.scroll.x + (S.size.org.x - S.size.cur.x) / 2,
        y = S.scroll.y + (S.size.org.y - S.size.cur.y) / 2
    })
end
 
function pico.set.grid(on)
    S.grid = on
    output_present(on)
end
 
function pico.set.size(phy, log)
    S.size.org = log
    set_size(phy, log)
end
 
function pico.set.color_clear(color)
    S.color.clear = color
end
 
function pico.set.color_draw(color)
    S.color.draw = color
    REN:setDrawColor({
        r = S.color.draw.r,
        g = S.color.draw.g,
        b = S.color.draw.b
    })
end
 
-- OUTPUT

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
    local aux = REN:createTexture(SDL.pixelFormat.RGBA8888, SDL.textureAccess.Target, rect.w, rect.h)
    REN:setDrawBlendMode(SDL.blendMode.Blend)
    REN:setTarget(aux)
    local clr = S.color.clear
    S.color.clear = {r = 0, g = 0, b = 0}
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
end
 
function pico.output.draw_pixel(pos)
    REN:setTarget(TEX)
    REN:setDrawColor(S.color.draw)
    REN:drawPoint({x = math.floor(X(pos.x, 1)), y = math.floor(Y(pos.y, 1))})
    output_present(false)
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
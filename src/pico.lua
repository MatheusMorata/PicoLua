-- IMPORTS
local SDL   = require "SDL"
local TTF   = require "SDL.ttf"
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

local S = {
    grid = true,
    expert = false,
    styel = PICO_FILL,
    size = {
        org = {x = 0, y = 0},
        cur = {x = 0, y = 0}
    },
    color = {
        clear = { r = 0, g = 0, b = 0, a = 255 },
        draw  = { r = 255, g = 255, b = 255, a = 255 }
    },
    crop = { x = 0, y = 0, w = 0, h = 0 }
}

PICO_SIZE_KEEP = { x = 0, y = 0 }
PICO_SIZE_FULLSCREEN = { x = 0, y = 1 }

local function PHY()
    local w, h = WIN:getSize()
    return { x = w, y = h }
end

-- LOCAL FUNCTION
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
            x1 = i,
            y1 = 0,
            x2 = i,
            y2 = phy.y
        })
    end

    local stepY = math.max(1, math.floor(phy.y / S.size.cur.y))
    for j = 0, phy.y, stepY do
        REN:drawLine({
            x1 = 0,
            y1 = j,
            x2 = phy.x,
            y2 = j
        })
    end

    REN:setLogicalSize(S.size.cur.x, S.size.cur.y)
    REN:setDrawColor(S.color.draw)
end

local function output_present(force)
    if S.expert and not force then return end

    REN:setTarget(nil)
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

local function output_draw_tex(pos, tex, size)
    local rct = {x = 0, y = 0, w = 0, h = 0}
    local format, access, rct.w, rct.h = tex:query()
    local crp = S.crop
    -- DESENVOLVENDO
end

-- SETTERS
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

function pico.output.draw_rect(rect) 
    local pos = {x = rect.x, y = rect.y}
    local aux = REN:createTexture(SDL.pixelFormat.RGBA8888, SDL.textureAccess.Target, rect.w, rect.h)
    REN:setDrawBlendMode(SDL.blendMode.Blend)
    REN:setTarget(aux)
    local clr = S.color.clear
    S.color.clear = {r = 0, g = 0, b = 0}
    output_clear()
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
        if TEX then TEX:destroy() end
        if REN then REN:destroy() end
        if WIN then WIN:destroy() end

        MIXER.closeAudio()
        TTF.quit()
        SDL.quit()
    end
end

return pico
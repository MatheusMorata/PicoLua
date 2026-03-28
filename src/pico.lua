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

PICO_DIM = {}

S = {
    grid = true,
    expert = false,
    size = {
        org = {x = 0, y = 0},
        cur = {x = 0, y = 0}
    },
    color = {
        clear = { r = 0,   g = 0,   b = 0},
        draw  = { r = 255, g = 255, b = 255}
    }
}

local function PICO_DIM.new(w, h)
    return { x = w, y = h }
end

local function PHY()
    local w, h = WIN:getSize()
    return { x = w, y = h }
end

-- VAR
local WIN, REN
local TEX = nil
local PICO_TITLE = 'pico-lua'
local PICO_DIM_PHY = PICO_DIM.new(640, 360)
local PICO_DIM_LOG = PICO_DIM.new(64, 36)
local PHY = PHY()

-- LOCAL FUNCTION
local function output_clear()

    REN:setDrawColor({
        r = S.color.clear.r,
        g = S.color.clear.g,
        b = S.color.clear.b
    })

    REN:clear()

    REN:setDrawColor({
        r = S.color.draw.r,
        g = S.color.draw.g,
        b = S.color.draw.b
    })
end

local function show_grid()
    if not S.grid then
        return
    end

    REN:setDrawColor({
        r = 119,
        g = 119,
        b = 119
    })

    local phy = PHY
    REN:setLogicalSize(phy.x, phy.y)

    local stepX = phy.x / S.size.cur.x
    for i = 0, phy.x, stepX do
        REN:drawLine(i, 0, i, phy.y)
    end

    local stepY = phy.y / S.size.cur.y

    for j = 0, phy.y, stepY do
        REN:drawLine(0, j, phy.x, j)
    end

    REN:setLogicalSize(S.size.cur.x, S.size.cur.y)

    REN:setDrawColor({
        r = S.color.draw.r,
        g = S.color.draw.g,
        b = S.color.draw.b
    })
end

local output_present(force)
    if S.expert and not force then
        return
    end

    REN:setTarget(nil)
    REN:setDrawColor({
        r = 119,
        g = 119,
        b = 119
    })
    REN:clear()
    REN:copy(TEX, nil, nil)
    show_grid()
    REN:present()
    REN:setDrawColor({
        r = S.color.draw.r,
        g = S.color.draw.g,
        b = S.color.draw.b
    })
    REN:setTarget(TEX)
end

local function set_size(phy, log)
    
    -- physical
    if phy.x == PICO_SIZE_KEEP.x and phy.y == PICO_SIZE_KEEP.y then
    -- keep
    elseif phy.x == PICO_SIZE_FULLSCREEN.x and phy.y == PICO_SIZE_FULLSCREEN.y then
        WIN:setFullscreen(SDL.window.Fullscreen)
        phy = PHY

    else
        WIN:setFullscreen(0)
        WIN:SetSize(phy.x, phy.y)
    end

    -- logical
    if log.x == PICO_SIZE_KEEP.x and log.y == PICO_SIZE_KEEP.y then
    -- keep
    else
        S.size.cur = log

        TEX = REN:createTexture(
            SDL.pixelFormat.RGBA8888,
            SDL.textureAccess.Target,
            S.size.cur.x,
            S.size.cur.y
        )

        REN:setLogicalSize(S.size.cur.x, S.size.cur.y)
    end
    
    if PHY.x == S.size.cur.x or PHY.y == S.size.cur.y then
        pico.set.grid(0)
    end

    output_present(0)
end

-- SETTERS
function pico.set.grid(on)
    S.grid = on
    output_present(o)
end

function pico.set.size(phy, log)
    S.size.org = log
    set_size(phy, log)
end

-- OUTPUT
function pico.output.clear() 
    output_clear();
    output_present(0);
end

function pico.init(on)
    if on then
        WIN = SDL.createWindow {
            title = PICO_TITLE,
            width = PICO_DIM_PHY.x,
            height = PICO_DIM_PHY.y,
            flags = {SDL.window.Shown}
        }

        SDL.createRenderer(WIN, -1, SDL.rendererFlags.Accelerated)
        REN:setDrawBlendMode(SDL.blendMode.Blend)
        TTF.init()
        MIXER.openAudio(22050, SDL.audioFormat.S16SYS, 2, 1024)
        pico.set.size(PICO_DIM_PHY, PICO_DIM_LOG)
        pico.output.clear()
    else
        SDL.quit()
    end
end

return pico
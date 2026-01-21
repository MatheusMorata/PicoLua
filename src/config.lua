local CONFIG = {}

CONFIG = {
    title = "PicoLua",

    undefined = "0x1FFF0000",

    Pico_Dim = {
        new = function(w, h)
            return {
                w = w or 0,
                h = h or 0
            }
        end
    },

    PICO_DIM_PHY = function()
        return CONFIG.Pico_Dim.new(500, 500)
    end,

    PICO_DIM_LOG = function()
        return CONFIG.Pico_Dim.new(100, 100)
    end,

    PICO_SIZE_KEEP = function()
        return CONFIG.Pico_Dim.new(0, 0)
    end,

    PICO_SIZE_FULLSCREEN = function()
        return CONFIG.Pico_Dim.new(0, 1)
    end
}

return CONFIG
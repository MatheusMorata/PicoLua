Pico_Dim = {}

function Pico_Dim.new(w, h)
    return {
        w = w or 0,
        h = h or 0
    }
end

local CONFIG = {
    title = "PicoLua",
    
    undefined = "0x1FFF0000",
    
    PICO_DIM_PHY = function()
        return Pico_Dim.new(500, 500)
    end,

    PICO_DIM_LOG = function()
        return Pico_Dim.new(100, 100)
    end
}
return CONFIG
local CONFIG = {
    title = "PicoLua",

    undefined = "0x1FFF0000",

    Pico_Dim = {
        new = function(w, h)
            return {
                w = w or 0,
                h = h or 0
            }
        end
    }
}

return CONFIG
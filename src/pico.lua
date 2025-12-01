local SDL = require("SDL")

local pico = {}

function pico.iniciar(on) 
    if on then 
        SDL.init{SDL.flags.Video} 
    
        janela = SDL.createWindow{
            title = 'Pico Lua', 
            width = 800, 
            height = 600,
            flags = {SDL.window.Resizable}, 
            x = SDL.window.centralized, 
            y = SDL.window.centralized, 
        }

        renderizador = SDL.createRenderer(janela, -1, SDL.rendererFlags.Accelerated)

    else 
        SDL.quit()
    end
    
end

return pico
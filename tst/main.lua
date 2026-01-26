local pico = dofile("../src/pico.lua")
local titulo = "Novo"


pico.init(true) -- Inicializa
pico.set.title(titulo) -- Define o título da janela
pico.input.delay(2000) -- Mantém a janela aberta no tempo de 2000 milisegundos
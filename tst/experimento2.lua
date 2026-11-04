local pico = dofile("../src/pico.lua")

local roxo   = { r = 70,  g = 60,  b = 170, a = 255 }
local branco = { r = 255, g = 255, b = 255, a = 255 }

pico.init(true)
pico.set.title("Experimento 2")
pico.set.size({ x = 800, y = 600 }, { x = 320, y = 240 })
pico.set.grid(false)
pico.set.font("tiny.ttf", 8)
pico.output.clear()

local world = pico.pos { x = 100, y = 100 }
local canto = pico.pos { x = 90,  y = 90 }

local dlg = pico_dim_ext({ x = 50, y = 33 }, world)
local btn = pico_dim_ext({ x = 25, y = 20 }, dlg)

local panel = { x = canto.x, y = canto.y, w = dlg.x, h = dlg.y }

local ANC_DLG = { x = "right", y = "bottom" }

local titulo = pico_pos_ext({ x = 50, y = 16 }, panel, ANC_DLG)
local btn1   = pico_pos_ext({ x = 25, y = 50 }, panel, ANC_DLG)
local btn2   = pico_pos_ext({ x = 75, y = 50 }, panel, ANC_DLG)

pico.set.anchor_draw(ANC_DLG)
pico.set.style("PICO_FILL")
pico.set.color_draw(branco)
pico.output.draw_rect(panel)

pico.set.style("PICO_STROKE")
pico.set.color_draw(roxo)
pico.output.draw_rect(panel)

pico.set.anchor_draw { x = "center", y = "middle" }
pico.output.draw_text(titulo, "Atualizacao")

pico.set.style("PICO_FILL")
pico.output.draw_rect { x = btn1.x, y = btn1.y, w = btn.x, h = btn.y }
pico.output.draw_rect { x = btn2.x, y = btn2.y, w = btn.x, h = btn.y }

pico.set.color_draw(branco)
pico.output.draw_text(btn1, "Depois")
pico.output.draw_text(btn2, "OK")

while true do
    pico.input.delay(100)
end
local pico = dofile("../src/pico.lua")

local roxo   = { r = 70,  g = 60,  b = 170, a = 255 }
local branco = { r = 255, g = 255, b = 255, a = 255 }
local fundo  = { r = 240, g = 238, b = 252, a = 255 }

pico.init(true)
pico.set.title("Experimento 2")
pico.set.size({ x = 800, y = 600 }, { x = 320, y = 240 })
pico.set.grid(false)
pico.set.font("tiny.ttf", 8)

local world  = pico.pos { x = 100, y = 100 }
local size   = pico.pos { x = 53,  y = 33 }
local margin = pico.pos { x = 10,  y = 10 }

local panel = {
    x = world.x - margin.x,
    y = world.y - margin.y,
    w = size.x,
    h = size.y,
}

local titulo = pico_pos_ext({ x = 50, y = 0 }, panel, { x = "right", y = "bottom" })

local btn_w = panel.w * 26 // 100
local btn_h = panel.h * 20 // 100
local btn1  = pico_pos_ext({ x = 33, y = 70 }, panel, { x = "right", y = "bottom" })
local btn2  = pico_pos_ext({ x = 67, y = 70 }, panel, { x = "right", y = "bottom" })

pico.set.style("PICO_FILL")
pico.set.color_draw(fundo)
pico.set.anchor_draw { x = "left", y = "top" }
pico.output.draw_rect { x = 0, y = 0, w = world.x, h = world.y }

pico.set.anchor_draw { x = "right", y = "bottom" }
pico.set.color_draw(branco)
pico.output.draw_rect { x = panel.x, y = panel.y, w = panel.w, h = panel.h }

pico.set.style("PICO_STROKE")
pico.set.color_draw(roxo)
pico.output.draw_rect { x = panel.x, y = panel.y, w = panel.w, h = panel.h }

pico.set.anchor_draw { x = "center", y = "top" }
pico.output.draw_text({ x = titulo.x, y = titulo.y + 8 }, "Atualizacao")

pico.set.anchor_draw { x = "center", y = "middle" }
pico.set.style("PICO_FILL")
pico.set.color_draw(roxo)
pico.output.draw_rect { x = btn1.x, y = btn1.y, w = btn_w, h = btn_h }
pico.output.draw_rect { x = btn2.x, y = btn2.y, w = btn_w, h = btn_h }

pico.set.color_draw(branco)
pico.output.draw_text(btn1, "Depois")
pico.output.draw_text(btn2, "OK")

while true do
    pico.input.delay(100)
end
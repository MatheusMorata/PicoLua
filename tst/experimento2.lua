local pico = dofile("../src/pico.lua")

pico.init(true)
pico.set.size({ x = 800, y = 600 }, { x = 320, y = 240 })
pico.set.grid(false)
pico.set.font("tiny.ttf", 8)

pico.set.anchor_draw{ x = "right", y = "bottom" }
pico.set.style("PICO_FILL")
pico.set.color_draw{ r = 240, g = 238, b = 252, a = 255 }
pico.output.draw_rect{ x = 296, y = 216, w = 170, h = 80 }


pico.set.style("PICO_STROKE")
pico.set.color_draw{ r = 70, g = 60, b = 170, a = 255 }
pico.output.draw_rect{ x = 296, y = 216, w = 170, h = 80 }

pico.set.anchor_draw{ x = "center", y = "top" }
pico.output.draw_text({ x = 211, y = 144 }, "Atualizacao")

pico.set.anchor_draw{ x = "center", y = "middle" }
pico.set.style("PICO_FILL")
pico.output.draw_rect{ x = 183, y = 192, w = 44, h = 16 }
pico.output.draw_rect{ x = 240, y = 192, w = 44, h = 16 }

pico.set.color_draw{ r = 255, g = 255, b = 255, a = 255 }
pico.output.draw_text({ x = 183, y = 192 }, "Depois")
pico.output.draw_text({ x = 240, y = 192 }, "OK")

while true do pico.input.delay(100) end
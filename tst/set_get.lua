local pico = dofile("../src/pico.lua")

pico.init(true)

local function ok(name)
    print("[ OK ] "..name)
end

local function fail(name,a,b)
    print("[FAIL] "..name)
    print(" expected:",a)
    print(" received:",b)
end

local function eq(name,a,b)
    if a==b then
        ok(name)
    else
        fail(name,a,b)
    end
end

local function eq2(name,a,b)
    if a.x==b.x and a.y==b.y then
        ok(name)
    else
        print("[FAIL] "..name)
        print(" expected",a.x,a.y)
        print(" received",b.x,b.y)
    end
end

local function eq4(name,a,b)
    if a.r==b.r and
       a.g==b.g and
       a.b==b.b and
       a.a==b.a then
        ok(name)
    else
        print("[FAIL] "..name)
    end
end

print("===== TESTE DOS SETTERS / GETTERS =====")

-------------------------------------------------
-- anchor draw
-------------------------------------------------

local v={x=10,y=20}
pico.set.anchor_draw(v)
eq2("anchor_draw",v,pico.get.anchor_draw())

-------------------------------------------------
-- anchor rotate
-------------------------------------------------

v={x=30,y=40}
pico.set.anchor_rotate(v)
eq2("anchor_rotate",v,pico.get.anchor_rotate())

-------------------------------------------------
-- clear color
-------------------------------------------------

local c={r=1,g=2,b=3,a=4}
pico.set.color_clear(c)
eq4("color_clear",c,pico.get.color_clear())

-------------------------------------------------
-- draw color
-------------------------------------------------

c={r=10,g=20,b=30,a=40}
pico.set.color_draw(c)
eq4("color_draw",c,pico.get.color_draw())

-------------------------------------------------
-- crop
-------------------------------------------------

local crop={
    x=1,
    y=2,
    w=3,
    h=4
}

pico.set.crop(crop)

local g=pico.get.crop()

eq("crop.x",crop.x,g.x)
eq("crop.y",crop.y,g.y)
eq("crop.w",crop.w,g.w)
eq("crop.h",crop.h,g.h)

-------------------------------------------------
-- expert
-------------------------------------------------

pico.set.expert(true)
eq("expert",true,pico.get.expert())

-------------------------------------------------
-- grid
-------------------------------------------------

pico.set.grid(false)
eq("grid",false,pico.get.grid())

-------------------------------------------------
-- rotate
-------------------------------------------------

pico.set.rotate(90)
eq("rotate",90,pico.get.rotate())

-------------------------------------------------
-- scale
-------------------------------------------------

v={x=200,y=150}
pico.set.scale(v)
eq2("scale",v,pico.get.scale())

-------------------------------------------------
-- scroll
-------------------------------------------------

v={x=12,y=34}
pico.set.scroll(v)
eq2("scroll",v,pico.get.scroll())

-------------------------------------------------
-- flip
-------------------------------------------------

v={x=1,y=0}
pico.set.flip(v)
eq2("flip",v,pico.get.flip())

-------------------------------------------------
-- zoom
-------------------------------------------------

v={x=100,y=100}
pico.set.zoom(v)
eq2("zoom",v,pico.get.zoom())

-------------------------------------------------
-- title
-------------------------------------------------

pico.set.title("Lua Test")
eq("title","Lua Test",pico.get.title())

-------------------------------------------------
-- style
-------------------------------------------------

pico.set.style("fill")
eq("style","fill",pico.get.style())

pico.set.style("stroke")
eq("style","stroke",pico.get.style())

-------------------------------------------------
-- size
-------------------------------------------------

pico.set.size(
    {x=640,y=360},
    {x=320,y=180}
)

local s=pico.get.size()

eq("logical width",320,s.log.x)
eq("logical height",180,s.log.y)

-------------------------------------------------

print()
print("===== GETTERS AUXILIARES =====")

print("ticks =",pico.get.ticks())

local m=pico.get.mouse()
print("mouse =",m.x,m.y)

local cur=pico.get.cursor()
print("cursor =",cur.x,cur.y)

print("font =",pico.get.font())
print("show =",tostring(pico.get.show()))

print()
print("===== FIM DOS TESTES =====")

pico.input.delay(3000)
pico.init(false)
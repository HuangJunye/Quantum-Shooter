pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- shift
--by kirais

t=0
function _init()
 ship = {sp=1,x=60,y=60}
 bullets = {}
 enemies = {}
 for i=1,10 do
 	add(enemies, {
 		sp=33,
 	 m_x=i*16,
 		m_y=60-i*8,
 		x=-32,
 		y=-32,
 		r=10
 		})
 end
end

function fire()
 local b = {
  sp=3,
  x=ship.x,
  y=ship.y,
  dx=0,
  dy=-3
 }
 add(bullets,b)
end

function _update()
 t=t+1
 -- move enemies
 for e in all(enemies) do
  e.x = e.r*sin(t/40) + e.m_x
  e.y = e.r*cos(t/40) + e.m_y
 end
 -- move bullets
 for b in all(bullets) do
  b.x+=b.dx
  b.y+=b.dy
  -- remove bullets out of screen
  if b.x < 0 or b.x > 128 or 
   b.y < 0 or b.y > 128 then
   del(bullets,b)
  end
 end
 
 if(t%8<4) then
  ship.sp=1
 else
  ship.sp=2
 end
 
 if btn(0) then ship.x-=2 end
 if btn(1) then ship.x+=2 end
 if btn(2) then ship.y-=2 end
 if btn(3) then ship.y+=2 end
 if btnp(4) then fire() end
end


function _draw()
 cls()
 -- draw ship
 spr(ship.sp,ship.x,ship.y)
 -- draw bullets
 for b in all(bullets) do
  spr(b.sp,b.x,b.y)
 end
 -- draw enemies
 for e in all(enemies) do
  spr(e.sp,e.x,e.y)
 end
end
__gfx__
00000000000900000009000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000900000009000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006160000061600000c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006660000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000066666000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700660a0660660a066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000060a0a06060a0a06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a00000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b777b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b777b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bb70b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b00b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b777b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b777b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bb70b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b00b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

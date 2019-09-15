pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- shift
--by kirais

timers = {}

function timer_start(id, time)
   timers[id] = { t = time }
end

function timer_check(id)
   return timers[id].t <= 0
end

function timers_tick()
   for timer in all(timers) do
      if timer.t > 0 then
         timer.t -= 0.01666666
      else
         timer.t = 0
      end
   end
end

function timers_clear()
   timers = {}
end

function _init()
 t=0
 cartdata(0)
 scene = "game"
 frames = 0

 ship = {
  sp=1,
  x=60,
  y=100,
  h_max=4,
  h=4,
  p=0,
  t=0,
  inv=false, -- invincibility
  box={x1=0,y1=0,x2=6,y2=6}
 }
 bullets = {}
 enemies = {}
 explosions = {}
 stars = {}
 shake_str = {x=0,y=0}
 progress=0

 -- generate stars in the bg
 for i=1,128 do
  add(stars,{
   x=rnd(128),
   y=rnd(128),
   s=rnd(2)+1
  })
 end

 -- start()
end

function shake()
 -- shake camera
 shake_str.x=2-rnd(4)
 shake_str.y=2-rnd(4)
 camera(shake_str.x,shake_str.y)
end

function enemy_base(x, y)
  local enemy = {}
  add(enemies, enemy)
  enemy.x = x
  enemy.y = y
  enemy.w = 1
  enemy.h = 1
  enemy.polarity = false
  enemy.movement = 0
  enemy.shotpattern = 0
  enemy.score = 1
  enemy.gunoffset = { x = 0, y = 0 }
  enemy.box={x1=0,y1=0,x2=6,y2=6}
  return enemy
end

function create_enemy_simple(x, y)
   local enemy = enemy_base(x, y)
   enemy.hp = 25
   enemy.sprite = 32
   enemy.speed = 0.5 + (progress * 0.02)
   return enemy
end

function update_enemy(e)
 if e.movement == 0 then
  -- move back and forth across the whole screen
  if e.polarity == false then e.x += e.speed
  elseif e.polarity == true then e.x -= e.speed end
  if e.x > 100 then e.polarity = true
  elseif e.x < 15 then e.polarity = false end
  e.y += 0.35
 end

 gun_x = e.x + e.w * 4 + e.gunoffset.x
 gun_y = e.y + e.h * 8 + e.gunoffset.y

 if e.shotpattern == 0 then
    -- simple shots going downwards
    if every(50) then
       add_e_projectile(gun_x, gun_y, e.polarity, 0, rnd(0.3) + 0.8)
    end
 end

 -- collision with ship
 if coll(ship,e) and not ship.inv then
   ship.inv = true
   ship.h -= 1
   if ship.h <= 0 then
    game_over()
   end
  end
end

enemies = {}
e_projectiles = {}
progress = 0

x_patterns = {
   { 32, 48, 64 },
   { 48, 64, 80 },
   { 32, 64, 96 },
}

function get_x_coord_pattern()
   return x_patterns[flr(rnd(#x_patterns)) + 1]
end

function get_x_coord_column()
   return (flr(rnd(12)) + 2) * 8
end

function spawn_enemy_wave_by_progress()
 -- limit number of enemies to less than 16
 if #enemies > 16 then
  return
 end

 progress += 1

 local randlimit = progress
 if randlimit > 35 then randlimit = 35 end
 local r = flr(rnd(randlimit))

 r = 3
 if r > 5 then
   -- add stronger enemy
 else
  for x in all(get_x_coord_pattern()) do
   create_enemy_simple(x, -8)
  end
 end
end

function lerp(a,b,t)
  return a + t*(b-a)
end

function every(duration,offset,period)
  local offset = offset or 0
  local period = period or 1
  local offset_frames = frames + offset
  return offset_frames % duration < period
end

function add_e_projectile(e_x,e_y, e_polarity, e_direction, e_velocity, e_size) --needs only an x,y
  e_direction = e_direction or 0
  e_velocity = e_velocity or 1
  e_polarity = e_polarity or false
  e_size = e_size or 1
  local projectile = {x = e_x,y = e_y, direction = e_direction, velocity = e_velocity, polarity = e_polarity, size = e_size}
  add(e_projectiles,projectile)
  print("add_e_projectile")
end

function pythagoras(ax,ay,bx,by)
  local x = ax-bx
  local y = ay-by
  return sqrt(x*x+y*y)
end

function update_e_projectiles()
  for p in all(e_projectiles) do
    if pythagoras(p.x,p.y,ship.x+3,ship.y+4) < 15 and p.polarity ~= polarity then
      p.x = lerp(p.x,ship.x+3,0.2)
      p.y = lerp(p.y,ship.y+6,0.2)
    else
      p.x = p.x+p.velocity*sin(p.direction)
      p.y = p.y+p.velocity*cos(p.direction)
    end
  end
  for p = #e_projectiles, 1, -1 do
    local x = e_projectiles[p].x
    local y = e_projectiles[p].y
    if x > 120 or x < 8 or y > 128 or y < 0 then del(e_projectiles,e_projectiles[p]) end
  end
end

function draw_e_projectiles()
  for p in all(e_projectiles) do
    if p.polarity == true then
      circfill(p.x,p.y,p.size+1,7)
      circfill(p.x,p.y,p.size,0)
      if polarity == true and every(4,0,2)
      then circfill(p.x,p.y,p.size,9) end
    else
      circfill(p.x,p.y,p.size+1,0)
      circfill(p.x,p.y,p.size,7)
      if polarity == false and every(4,0,2) then circfill(p.x,p.y,p.size,9) end
    end
  end
end

function start()
 _update = update_menu
 _draw = draw_menu
end

function update_menu()
 if btn(4) then
  _update=update_game
  _draw=draw_game
 end
end

function draw_menu()
 cls()
 print("ikaruga",30,50) -- title
 print("press 🅾️ to start",30,80)
 -- print high score from data
 print("high-score",40,100)
 print(dget(0),85,100)
end

function game_over()
 _update = update_over
 _draw = draw_over
 -- update high score
 if(dget(0)<ship.p) then
  dset(0,ship.p)
 end
end

function update_over()
end

function draw_over()
 cls()
 print("game over",50,50,4)
end

function abs_box(s)
 local box = {}
 box.x1 = s.box.x1 + s.x
 box.y1 = s.box.y1 + s.y
 box.x2 = s.box.x2 + s.x
 box.y2 = s.box.y2 + s.y
 return box
end

function coll(a,e)
 local box_a = abs_box(a)
 local box_e = abs_box(e)

 if box_a.x1 > box_e.x2 or
    box_a.y1 > box_e.y2 or
    box_a.x2 < box_e.x1 or
    box_a.y2 < box_e.y1 then
  return false
 end

 return true
end

function explode(x,y)
 add(explosions,{x=x,y=y,t=0})
end

function fire()
 local b = {
  sp=3,
  x=ship.x,
  y=ship.y,
  dx=0,
  dy=-3,
  box={x1=2,y1=0,x2=4,y2=2}
 }
 add(bullets,b)
end

function update_game()
 print("update game",80,80)
 t=t+1
 -- invincibility
 if ship.inv then
  ship.t += 1
  shake()
  if ship.t > 30 then
   camera(0,0)
   ship.inv = false
   ship.t = 0
  end
 end

 -- update stars
 for st in all(stars) do
  st.y += st.s
  if st.y >= 128 then
   st.y = 0
   st.x = rnd(128)
  end
 end

 -- explosions
 for ex in all(explosions) do
  ex.t+=1
  if ex.t==13 then
   del(explosions, ex)
  end
 end

 -- enemies
 local rate = 120 - (progress * 0.5)
 if rate < 60 then rate = 60 end

 if frames % rate == 0 then
    spawn_enemy_wave_by_progress()
 end

 for e in all(enemies) do
    update_enemy(e)
 end

 update_e_projectiles()

 -- move bullets
 for b in all(bullets) do
  b.x+=b.dx
  b.y+=b.dy
  -- remove bullets out of screen
  if b.x < 0 or b.x > 128 or
   b.y < 0 or b.y > 128 then
   del(bullets,b)
  end

  -- hit enemy and score
  for e in all(enemies) do
   if coll(b,e) then
    del(enemies,e)
    ship.p += 1
    explode(e.x,e.y)
   end
  end
 end

 if(t%8<4) then
  ship.sp=1
 else
  ship.sp=2
 end

 -- button control
 if btn(0) and ship.x>0 then
  ship.x-=2
 end

 if btn(1) and ship.x<120 then
  ship.x+=2
 end

 if btn(2) and ship.y>0 then
  ship.y-=2
 end

 if btn(3) and ship.y<120 then
  ship.y+=2
 end

 if btnp(4) then fire() end

end

function _update60 ()
 print("update60",50,50)
 timers_tick()
 frames += 1
 if scene == "game" then
   update_game()
 end
end

function _draw ()
 if scene == "game" then
  draw_game()
 end
end


function draw_game()
 cls()
 -- display point
 print(ship.p,0,0)

 -- draw health
 for i=1,ship.h_max do
  if i<=ship.h then
   spr(49,98+6*i,0)
  else
   spr(50,98+6*i,0)
  end
 end

 -- draw stars
 for st in all(stars) do
  pset(st.x,st.y,6)
 end

 -- invincibility
 if not ship.inv or t%8<4 then
  -- draw ship
  spr(ship.sp,ship.x,ship.y)
 end

 -- draw explosions
 for ex in all(explosions) do
  circ(ex.x,ex.y,ex.t/3,8+ex.t%3)
 end

 -- draw bullets
 for b in all(bullets) do
  spr(b.sp,b.x,b.y)
 end
 -- draw enemies
 for e in all(enemies) do
  spr(e.sp,e.x,e.y)
 end

 draw_e_projectiles()
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
00000000080800000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888880006666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088800000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013130000121200140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

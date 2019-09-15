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
 scene = "title"
 frames = 0

 ship = {
  sp=0,
  x=60,
  y=100,
  h_max=4,
  w=1,
  h=4,
  score=0,
  double=0,
  t=0,
  energy = 60,
  hit = 0,
  projectiles = {},
  highscore = false,
  combo = 1,
  inv=false, -- invincibility
  polarity=true,
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
  enemy.polarity = true
  enemy.movement = 0
  enemy.shotpattern = 0
  enemy.score = 1
  enemy.gunoffset = { x = 0, y = 0 }
  enemy.box={x1=0,y1=0,x2=6,y2=6}
  return enemy
end

function create_enemy_simple(x, y, polarity)
   local enemy = enemy_base(x, y)
   enemy.polarity = polarity
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
   ship.energy -= 10
   if ship.energy <= 0 then
    scene = "game_over"
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

 --r = 3
 if r > 5 then
   -- add stronger enemy
 else
  for x in all(get_x_coord_pattern()) do
   create_enemy_simple(x, -8, false)
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
end

function pythagoras(ax,ay,bx,by)
  local x = ax-bx
  local y = ay-by
  return sqrt(x*x+y*y)
end

function update_e_projectiles()
  for p in all(e_projectiles) do
    if pythagoras(p.x,p.y,ship.x+3,ship.y+4) < 15 and p.polarity == ship.polarity then
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
      circfill(p.x,p.y,p.size+1,12)
      circfill(p.x,p.y,p.size,0)
      if ship.polarity == true and every(4,0,2) then
       circfill(p.x,p.y,p.size,9) end
    else
      circfill(p.x,p.y,p.size+1,8)
      circfill(p.x,p.y,p.size,0)
      if ship.polarity == false and every(4,0,2) then
       circfill(p.x,p.y,p.size,9) end
    end
  end
end

function start()
 _update = update_menu
 _draw = draw_menu
end

function update_menu()
 if btn(4) then
  scene = "game"
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
 if(dget(0)<ship.score) then
  dset(0,ship.score)
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
  x=ship.x,
  y=ship.y,
  dx=0,
  dy=-3,
  box={x1=2,y1=0,x2=4,y2=2}
 }
 b.polarity = ship.polarity
 if b.polarity then
  b.sp = 2
 else
  b.sp = 2+16
 end
 add(bullets,b)
end

function inside(point, enemy)
  if point == nil then return false end
   local px = point.x
   local py = point.y
   return
      px > enemy.x and px < enemy.x + enemy.w * 8 and
      py > enemy.y and py < enemy.y + enemy.h * 8
end

function collisions()
   --laser collison
   local shiplaserdmg = 1
   if ship.energy <= 20 then
      shiplaserdmg = 2
   end
   for p = #ship.projectiles, 1, -1 do
      for e in all(enemies) do
         if inside(ship.projectiles[p], e) then
            e.hp -= shiplaserdmg
            e.hit = true
            if (every(4)) ship.score += 1  sfx(12,3)
            del(ship.projectiles,ship.projectiles[p])
         end
      end
   end
  -- enemy projectile collisions
  for p = #e_projectiles, 1, -1 do
      if inside(e_projectiles[p], ship) then
        if e_projectiles[p].polarity == ship.polarity then
         -- if enemy projectiles is the same as ship
         ship.energy += 3
         ship.score += ship.combo
         ship.combo += 1
        elseif e_projectiles[p].polarity ~= ship.polarity then
         -- if enemy projectiles is not the same as ship
         ship.inv = true
         ship.energy -= 12
         ship.hit += 2
         ship.combo = 1
         sfx(13,3)
        end
        del(e_projectiles,e_projectiles[p])
      end
  end
end

function update_game()
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
 collisions()  -- projectile collisions

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
   if coll(b,e) and (e.polarity ~= b.polarity) then
    del(enemies,e)
    ship.score += 1
    explode(e.x,e.y)
   end
  end
 end

 if(t%8<4) then
  ship.sp=0
 else
  ship.sp=1
 end

 player_control()
end

function player_control()
 -- directions control
 if btn(0) and ship.x>0 then ship.x-=2 end
 if btn(1) and ship.x<120 then ship.x+=2 end
 if btn(2) and ship.y>0 then ship.y-=2 end
 if btn(3) and ship.y<120 then ship.y+=2 end
 -- fire
 if btnp(4) then fire() end
 -- switch polarity
 if btnp(5) then
  if ship.polarity == true then
   ship.polarity = false
  else
   ship.polarity = true
  end
 end
end

function _update60 ()
 timers_tick()
 frames += 1
 if scene == "title" then
   update_menu()
   draw_menu()
 elseif scene == "game" then
   update_game()
 elseif scene == "game_over" then
   game_over()
 end
end

function _draw ()
 if scene == "game" then
  draw_game()
 end
end

function compile_score(score,double)
  local zeroes = ""
  score = "" .. score
  for x = 1, (8-#score) do
     zeroes = zeroes .. "0"
  end
  score = zeroes .. score
  local output = ""
  if double > 0 then
    local int = "00032000"
    local buffer = 0
    for n = 8,1,-1 do
      local s = 0 .. sub(score,n,n)
      local i = 0 .. sub(int,n,n)
      local o = s+(i*double)+buffer
      if o > 19 then o = 9 buffer = 2
      elseif o > 9 then o = 9 buffer = 1
      else buffer = 0 end
      output = o .. output
    end
  else
    for n = 1,8 do
      o = sub(score,n,n) or 0
      output = output .. o
    end
  end
  for n = 1,8 do
    if sub(output,1,1) == "0" then
      output = sub(output,2)
    end
  end
    return output
end

function draw_ui()
  local energy = flr(ship.energy)
  if energy >= 100 then energy = "max" end
  print(energy,1,121,0)
  print(energy,1,120,7)
  local length = 0
  if ship.combo > 9 then length = 4 end
  print("x" .. ship.combo,120-length,121,0)
  print("x" .. ship.combo,120-length,120,7)
  local energybar = 117
  local ragemode = 7
  if ship.energy < 20 and every(4,0,2) then
    ragemode = 9
  end
  if ship.polarity then color = 12 else color = 8 end
  rectfill(2,energybar+1-ship.energy,6,energybar+1,ragemode)
  rectfill(1,energybar-ship.energy,5,energybar,color)

  if ship.highscore and every (120,0,60) then
    print(ship.double, 80,120,9)
  end

  --
  ship.score = flr(ship.score)
  local length = compile_score(ship.score,ship.double)
  for n = 1,#length do
    local nr = sub(compile_score(ship.score,ship.double), n,n) or 0
    nr = "0" .. nr
    spr(134+nr,119,(n-1)*16,1,2)
  end
end

function draw_game()
 cls()
 -- display point
 print(ship.score,0,0)

 -- draw stars
 for st in all(stars) do
  pset(st.x,st.y,6)
 end

 -- invincibility
 if not ship.inv or t%8<4 then
  -- draw ship
  if ship.polarity then
   spr(ship.sp,ship.x,ship.y)
  else
   spr(ship.sp+16,ship.x,ship.y)
  end
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
  if e.polarity then
   e.sprite = 32
  else
   e.sprite = 32+16
  end
  spr(e.sprite,e.x,e.y)
 end

 draw_e_projectiles()
 draw_ui()
end
__gfx__
000900000009000000c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808000006060000
000900000009000000c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888800066666000
00c1c00000c1c00000c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888000006660000
00ccc00000ccc00000d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000600000
0ccccc000ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc909cc0cc909cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0a0a0c0c0a0a0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000a00000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000000200000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000000200000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00818000008180000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008880000088800000a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888800088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88909880889098800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80a0a08080a0a0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000a00000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ccc000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c777c00067776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c777c00067776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cc70c00066706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccc0666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00c00c0600600600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08777800057775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08777800057775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08870800055705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80080080500500500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

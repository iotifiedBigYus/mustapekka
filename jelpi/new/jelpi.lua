-- jelpi demo
-- by zep

level=2

num_players = 1
corrupt_mode = false
paint_mode = false
max_actors = 64
play_music = true

function make_actor(k,x,y,d)
	local a = {
		k=k,
		frame=0,
		frames=4,
		life = 1,
		hit_t=0,
		x=x,y=y,dx=0,dy=0,
		homex=x,homey=y,
		ddx = 0.02, -- acceleration
		ddy = 0.06, -- gravity
		w=3/8,h=0.5, -- half-width
		d=d or -1, -- direction
		bounce=0.8,
		friction=0.9,
		can_bump=true,
		dash=0,
		super=0,
		t=0,
		standing = false,
		draw=draw_actor,
		move=move_actor,
	}
	
	-- attributes by flag
	
	if (fget(k,6)) then
		a.is_pickup=true
	end
	
	if (fget(k,7)) then
		a.is_monster=true
		a.move=move_monster
	end
	
	if (fget(k,4)) then
		a.ddy = 0 -- zero gravity
	end
	
	-- attributes from actor_dat
	
	for k,v in pairs(actor_dat[k])
	do
		a[k]=v
	end
	
	if (#actor < max_actors) then
		add(actor, a)
	end
	
	return a
end

function make_sparkle(k,x,y,col)
	local s = {
		x=x,y=y,k=k,
		frames=1,
		col=col,
		t=0, max_t = 8+rnd(4),
		dx = 0, dy = 0,
		ddy = 0
	}
	if (#sparkle < 512) then
		add(sparkle,s)
	end
	return s
end

function make_player(k, x, y, d)

	local a = make_actor(k, x, y, d)
	
	a.is_player=true
	a.move=move_player

	a.score   = 0
	a.bounce  = 0
	a.delay   = 0
	a.id      = 0 -- player 1

	
	return a
end




-- called at start by pico-8
function _init()

	init_actor_data() 
	init_level(level)
	
	menuitem(1,
	"restart level",
	function()
		init_level(level)
	end)
		
end

-- clear_cel using neighbour val
-- prefer empty, then non-ground
-- then left neighbour

function clear_cel(x, y)
	local val0 = mget(x-1,y)
	local val1 = mget(x+1,y)
	if ((x>0 and val0 == 0) or 
					(x<127 and val1 == 0)) then
		mset(x,y,0)
	elseif (not fget(val1,1)) then
		mset(x,y,val1)
	elseif (not fget(val0,1)) then
		mset(x,y,val0)
	else
		mset(x,y,0)
	end
end


function move_spawns(x0, y0)

	x0=flr(x0)
	y0=flr(y0)
	
	-- spawn actors close to x0,y0

	for y=0,16 do
		for x=x0-10,max(16,x0+14) do
			local val = mget(x,y)
			
			-- actor
			if (fget(val, 5)) then    
				m = make_actor(val,x+0.5,y+1)
				clear_cel(x,y)
			end
			
		end
	end

end

-- test if a point is solid
function solid (x, y, ignore)

	if (x < 0 or x >= 128 ) then
		return true end
	
	local val = mget(x, y)
	
	-- flag 6: can jump up through
	-- (and only top half counts)	
	if (fget(val,6)) then
		if (ignore) return false
		-- bottom half: solid iff solid below
		if (y%1 > 0.5) return solid(x,y+1)
	end
	
	return fget(val, 1)
end

-- solidx: solid at 2 points
-- along x axis
local function solidx(x,y,w)
	return solid(x-w,y) or
		solid(x+w,y)
end


function move_player(pl)

	move_actor(pl)
	
	if (pl.y > 18) pl.life=0

	local b = pl.id

	if (pl.life <= 0) then
				
				for i=1,32 do
					s=make_sparkle(69,
						pl.x, pl.y-0.6)
					s.dx = cos(i/32)/2
					s.dy = sin(i/32)/2
					s.max_t = 30 
					s.ddy = 0.01
					s.frame=69+rnd(3)
					s.col = 7
				end
				
				sfx(17)
				pl.death_t=time()
				
				
		return
	end
	
	local accel = 0.05
	local q=0.7
	
	if (pl.dash > 10) then
		accel = 0.08
	end
	
	if (pl.super > 0) then 
		q*=1.5
		accel*=1.5
	end
	
	if (not pl.standing) then
		accel = accel / 2
	end
		
	-- player control
	if (btn(0,b)) then 
			pl.dx = pl.dx - accel; pl.d=-1 end
	if (btn(1,b)) then 
		pl.dx = pl.dx + accel; pl.d=1 end

	if ((btn(4,b)) and 
		pl.standing) then
		pl.dy = -0.7
		sfx(8)
	end

	-- charge

	if (btn(5,b) and pl.delay == 0)
	then
		pl.dash = 15
		pl.delay= 20
		-- charge in dir of buttons
		dx=0 dy=0
		if (btn(0,b)) dx-=1*q
		if (btn(1,b)) dx+=1*q
		
		-- keep controls to 4 btns
		if (btn(2,b)) dy-=1*q
		if (btn(3,b)) dy+=1*q
		
		if (dx==0 and dy==0) then
			pl.dx += pl.d * 0.4
		else
			local aa=atan2(dx,dy)
			pl.dx += cos(aa)/2
			pl.dy += sin(aa)/3
			
			pl.dy=max(-0.5,pl.dy)
		end
		
		-- tiny extra vertical boost
		if (not pl.standing) then
			pl.dy = pl.dy - 0.2
		end 
	
		sfx(11)
	
	end
	
	-- super: give more dash
	
	if (pl.super > 0) pl.dash=2
	
	-- dashing
	
	if pl.dash > 0 then
		
		if (abs(pl.dx) > 0.4 or
						abs(pl.dy) > 0.2
		) then
		
		for i=1,3 do
			local s = make_sparkle(
				69+rnd(3),
				pl.x+pl.dx*i/3, 
				pl.y+pl.dy*i/3 - 0.3,
				(pl.t*3+i)%9+7)
			if (rnd(2) < 1) then
				s.col = 7
			end
			s.dx = -pl.dx*0.1
			s.dy = -0.05*i/4
			s.x = s.x + rnd(0.6)-0.3
			s.y = s.y + rnd(0.6)-0.3
		end
		end
	end 
	
	pl.dash = max(0,pl.dash-1)
	pl.delay = max(0,pl.delay-1)
	pl.super = max(0, pl.super-1)
	
	-- frame	

	if (pl.standing) then
		pl.frame = (pl.frame+abs(pl.dx)*2) % pl.frames
	else
		pl.frame = (pl.frame+abs(pl.dx)/2) % pl.frames
	end
	
	if (abs(pl.dx) < 0.1) pl.frame = 0
	
end

function move_monster(m)
	
	move_actor(m)
	
	if (m.life<=0) then
		bang_puff(m.x,m.y-0.5,104)

		sfx(14)
		return
	end
	

	m.dx = m.dx + m.d * m.ddx

	m.frame = (m.frame+abs(m.dx)*3+4) % m.frames
	
	-- jump
	if (false and m.standing and rnd(10) < 1)
	then
		m.dy = -0.5
	end
	
	-- hit cooldown
	-- (can't get hit twice within
	--  half a second)
	if (m.hit_t>0) m.hit_t-=1

end


function smash(x,y,b)

		local val = mget(x, y, 0)
		if (not fget(val,4)) then
			-- not smashable
			-- -> pass on to solid()
			return solid(x,y,b)
		end    
		
		
		-- spawn
		if (val == 48) then
			local a=make_actor(
				loot[#loot],
				x+0.5,y-0.2)
			
			a.dy=-0.8
			a.d=flr(rnd(2))*2-1
			a.d=0.25 -- swirly
			loot[#loot]=nil
		end
		
				
		clear_cel(x,y)
		sfx(10)
			
		-- make debris
		
		for by=0,1 do
			for bx=0,1 do
				s=make_sparkle(22,
				0.25+flr(x) + bx*0.5, 
				0.25+flr(y) + by*0.5,
				0)
				s.dx = (bx-0.5)/4
				s.dy = (by-0.5)/4
				s.max_t = 30 
				s.ddy = 0.02
			end
		end

		return false -- not solid
end

function move_actor(a)

	if (a.life<=0) del(actor,a)
	
	a.standing=false
	
	-- when dashing, call smash()
	-- for any touched blocks
	-- (except for landing blocks)
	local ssolid=
		a.dash>0 and smash or solid 
	
	-- solid going down -- only
	-- smash when holding down
	local ssolidd=
		a.dash>0 and (btn(3,a.id))
		 and smash or solid 
		
	--ignore jump-up-through
	--blocks only when have gravity
	local ign=a.ddy > 0
	
	-- x movement 
	
	-- candidate position
	x1 = a.x + a.dx + sgn(a.dx)/4
	
	if not ssolid(x1,a.y-0.5,ign)
	then
		-- nothing in the way->move
		a.x += a.dx 
		
	else -- hit wall
	
		-- bounce
		if (a.dash > 0)sfx(12) 
		a.dx *= -1
		
		a.hit_wall=true
		
		-- monsters turn around
		if (a.is_monster) then
			a.d *= -1
			a.dx = 0
		end
		
	end
	
	-- y movement
	
	local fw=0.25

	if (a.dy < 0) then
		-- going up
		
		if (
		 ssolid(a.x-fw, a.y+a.dy-1,ign) or
		 ssolid(a.x+fw, a.y+a.dy-1,ign))
		then
			a.dy=0
			
			-- snap to roof
			a.y=flr(a.y+.5)
			
		else
			a.y += a.dy
		end

	else
		-- going down
	
		local y1=a.y+a.dy
		if ssolidd(a.x-fw,y1) or
		   ssolidd(a.x+fw,y1)
		then
		
			-- bounce
			if (a.bounce > 0 and 
			    a.dy > 0.2) 
			then
				a.dy = a.dy * -a.bounce
			else
			
			a.standing=true
			a.dy=0
			end
			
			-- snap to top of ground
			a.y=flr(a.y+0.75)	
			
		else
			a.y += a.dy  
		end
		-- pop up
		
		while solid(a.x,a.y-0.05) do
			a.y -= 0.125
		end

	end


	-- gravity and friction
	a.dy += a.ddy
	a.dy *= 0.95

	-- x friction

	a.dx *= a.friction
	if (a.standing) then
		a.dx *= a.friction
	end

--end
	
	-- counters
	a.t = a.t + 1
end


function monster_hit(m)
	if(m.hit_t>0) return
	
	m.life-=1
	m.hit_t=15
	m.dx/=4
	m.dy/=4
	-- survived: thunk sound
	if (m.life>0) sfx(21)
	
end

function player_hit(p)
		if (p.dash>0) return
		p.life-=1
end

function collide_event(a1, a2)

	if (a1.is_monster and
					a1.can_bump and
					a2.is_monster) then
					local d=sgn(a1.x-a2.x)
					if (a1.d!=d) then
						a1.dx=0
						a1.d=d
					end
	end
	
	-- bouncy mushroom
	if (a2.k==82) then
		if (a1.dy > 0 and 
		not a1.standing) then
			a1.dy=-1.1
			a2.active_t=6
			sfx(18)
		end
	end

	if(a1.is_player) then
		if(a2.is_pickup) then

			if (a2.k==64) then
				a1.super = 30*4
				--sfx(17)
				a1.dx = a1.dx * 2
				--a1.dy = a1.dy-0.1
				-- a1.standing = false
				sfx(13)
			end

			-- watermelon
			if (a2.k==80) then
				a1.score+=5
				sfx(9)
			end
			
			-- end level
			if (a2.k==65) then
				finished_t=1
				bang_puff(a2.x,a2.y-0.5,108)
				del(actor,pl[1])
				del(actor,pl[2])
				music(-1,500)
				sfx(24)
			end
			
			-- glitch mushroom
			if (a2.k==84) then
				glitch_mushroom = true
				sfx(29)
			end
			
			-- gem
			if (a2.k==67) then
				a1.score = a1.score + 1
				
				-- total gems between players
				gems+=1
				
			end
			
			-- bridge builder
			if (a2.k==99) then
				local x,y=flr(a2.x)+.5,flr(a2.y+0.5)
				for xx=-1,1 do
				if (mget(x+xx,y)==0) then
					local a=make_actor(53,x+xx,y+1)
					a.dx=xx/2
				end
				end
			end
			
			a2.life=0
			
			s=make_sparkle(85,a2.x,a2.y-.5)
			s.frames=3
			s.max_t=15
			sfx(9)
		end
		
		-- charge or dupe monster
		
		if(a2.is_monster) then -- monster
			
			if(
					(a1.dash > 0 or 
						a1.y < a2.y-a2.h/2)
					and a2.can_bump
				) then
				
				-- slow down player
				a1.dx *= 0.7
				a1.dy *= -0.7
				
				if (btn(🅾️,a1.id))a1.dy -= .5
				
				monster_hit(a2)
				
			else
				-- player death
				a1.life=0
				
			end
		end
			
	end
end

function move_sparkle(sp)
	if (sp.t > sp.max_t) then
		del(sparkle,sp)
	end
	
	sp.x = sp.x + sp.dx
	sp.y = sp.y + sp.dy
	sp.dy= sp.dy+ sp.ddy
	sp.t = sp.t + 1
end


function collide(a1, a2)
	if (not a1) return
	if (not a2) return
	
	if (a1==a2) then return end
	local dx = a1.x - a2.x
	local dy = a1.y - a2.y
	if (abs(dx) < a1.w+a2.w) then
		if (abs(dy) < a1.h+a2.h) then
			collide_event(a1, a2)
			collide_event(a2, a1)
		end
	end
end

function collisions()

	-- to do: optimize if too
	-- many actors

	for i=1,#actor do
		for j=i+1,#actor do
			collide(actor[i],actor[j])
		end
	end
	
end



function outgame_logic()

	if death_t==0 and
			not alive(pl[1]) and 
			not alive(pl[2]) then
			death_t=1
			music(-1)
			sfx(5)
			
	end

	if (finished_t > 0) then
	
		finished_t += 1
		
		if (finished_t > 60) then
			if (btnp(❎)) then
				fade_out()
				init_level(level+1)
			end
		end
	
	end

	if (death_t > 0) then
		death_t = death_t + 1
		if (death_t > 45 and 
			btn()>0)
		then 
				music(-1)
				sfx(-1)
				sfx(0)
				fade_out()
				
				
				-- restart cart end of slice
				init_level(level)
			end
	end
	
end

function _update() 
	
	for a in all(actor) do
		a:move()
	end
		
	foreach(sparkle, move_sparkle)
	collisions()
	
	for i=1,#pl do
		move_spawns(pl[i].x,0)
	end
	
	outgame_logic()
	update_camera()

	if (glitch_mushroom or corrupt_mode) then
		for i=1,4 do
			poke(rnd(0x8000),rnd(0x100))
		end
	end
	
	level_t += 1
end



function _draw()

	cls(12)
	
	-- view width
	local vw=split and 64 or 128

	cls()
	
	-- decide which side to draw
	-- player 1 view
	local view0_x = 0
	if (split and pl[1].x>pl[2].x)
	then view0_x = 64 end
	
	-- player 1 (or whole screen)
	draw_world(
		view0_x,0,vw,128,
		cam_x,cam_y)
	
	-- player 2 view if needed
	if (split) then
		cam_x = pl_camx(pl[2].x,64)
		draw_world(64-view0_x,0,vw,128,
			cam_x, cam_y)
	end
	
	camera()pal()clip()
	if (split) line(64,0,64,128,0)

	-- player score
	camera(0,0)
	color(7)
	
	if (death_t > 45) then
		print("❎ restart",
			44,10+1,14)
		print("❎ restart",
			44,10,7)
	end
	
	if (finished_t > 0) then
		draw_finished(finished_t)
	end
	
	if (paint_mode) apply_paint()

	draw_sign()
end


sign_str={
"",
[[
	this is an empty level!
	use the map editor to add
	some blocks and monsters.
	in the code editor you
	can also set level=2
	]],
"",
[[
	this is not a level!
	
	the bottom row of the map 
	in this cartridge is used
	for making backgrounds.
]]
}

function draw_sign()

if (mget(pl[1].x,pl[1].y-0.5)!=25) return

rectfill(8,6,120,46,0)
rect(8,6,120,46,7)

print(sign_str[level],12,12,6)


end


function fade_out()

	dpal={0,1,1, 2,1,13,6,
							4,4,9,3, 13,1,13,14}
	
	
					
	-- palette fade
	for i=0,40 do
		for j=1,15 do
			col = j
			for k=1,((i+(j%5))/4) do
				col=dpal[col]
			end
			pal(j,col,1)
		end
		flip()
	end
	
end
--actors
--3.4.2024


function init_actor_data()
	actor_data = {
	[SPR_PLAYER] = init_player_data(),
	[SPR_DOG] = init_dog_data(),
	[SPR_SOFA] = {
		w2 = 1,
		h  = 1,
		mass = 2,
		friction = 0.05,
		is_furniture = true,
		draw = draw_sofa
	}
	}
end


function make_actor(k,x,y,d)
	if (count(actors) >= MAX_ACTORS) then
		return
	end

	debug.actors_n = count(actors)

	local a = {}
	a.k = k --> sprite id of actor
	a.standing = true
	a.frame = 0
	a.t_frame = 0
	a.t = 0
	--motion
	a.x        = x
	a.y        = y
	a.dx       = 0
	a.dy       = 0
	a.ddy      = .02 -- gravity
	a.drag     = .02 --air drag
	a.friction = .9 -- exponential deacceleration
	a.traction = true
	a.d        = d or -1 --(looking direction)
	a.mass     = 1
	a.bounce   = 0
	--sprite
	a.cx  = 0
	a.w2  = .5
	a.h   = 1
	a.f_x = 0
	a.fade = 1
	--pushing
	a.pushing_actors = {}
	a.pushing_actor = nil
	a.pushed_by_actor = nil
	--methods
	a.update        = update_actor
	a.update_sprite = function() end
	a.draw          = function() end
	a.clear         = clear_cell

	for attr,v in pairs(actor_data[k]) do
		a[attr]=v
	end

	add(actors, a)

	return a
end



function spawn_actor(k,x,y,d)
	return make_actor(k,x,y,d)
end


function spawn_sofa(x,y)
	return make_actor(SPR_SOFA,x,y,1)
end


function update_actor(a)
	--first half of gravity
	a.dy += .5 * a.ddy

	-- x movement 
	collide_side(a)
	-- y movement
	if(a.dy < 0)collide_up(a)
	if(a.dy >= 0)collide_down(a)

	--jumping
	if(a.dy < 0) a.jumped = true

	--moving
	a.x += a.dx
	a.y += a.dy

	--snapping
	if(a.dx == 0)a.x = snap8(a.x,a.cx)
	if(a.dy == 0)a.y = snap8(a.y,0)

	--friction
	if (a.standing and a.traction) a.dx *= a.friction

	--air resistance
	a.dy -= sgn(a.dy) * a.dy * a.dy * a.drag

	--second half of gravity
	a.dy += .5 * a.ddy

	--timers
	a.t += 1
end



--[[

actor position is center bottom
.   _______
.  |       |
.  | (x,y) |
.  |___.___|

.    O       O       O       O    
. --@@@-- --@@@-- --@@@-- --@@@-- 
.   @@@\    @@@\   _@@@    _@@@  
.   |      /           \      |   

--]]


function draw_sofa(a)
	local x = 8*(a.x-1)+.5
	local y = 8*(a.y-1)+.5

	spr(a.k, x,   y)
	spr(a.k, x+8, y,1,1,true)
end


function draw_hitbox(a)
	rect(
		8*snap8(a.x-a.w2),
		8*snap8(a.y-a.h),
		8*(snap8(a.x+a.w2)-E),
		8*(snap8(a.y)-E),
		8
	)  
end
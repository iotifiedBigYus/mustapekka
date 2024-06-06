--dog
--sam westerlund
--6.6.24

function init_dog_data()
	local a = {}

	a.w2 = .375
	a.h  = .875
	a.eye_pos_x    =  .25
	a.eye_pos_y    = -.75
	a.eye_global_x = 0
	a.eye_global_y = 0
	a.walk_speed   = .1875
	a.traction     = false
	a.update        = update_dog
	a.update_sprite = update_dog_sprite
	a.draw          = draw_dog

	return a
end


function spawn_dog(x,y)
	return make_actor(SPR_DOG,x,y,1)
end


function update_dog(a)
	local strafing_x = 0
	if btn(0,1) then
		strafing_x = -1
	elseif btn(1,1) then
		strafing_x = 1
	end

	--strafing

	a.strafing = strafing_x != 0
	if(strafing_x != 0)a.d = strafing_x

	local accel = .1 --> airborn
	if abs(a.dx) > a.walk_speed and a.d == sgn(a.dx) then
		accel = .05 --> going too fast (probably wont happen)
	elseif a.standing then
		accel = .25 --> on ground
	elseif a.strafing and a.gliding then
		accel = .1 --> strafing while gliding
	elseif a.strafing then
		accel = .2 --> strafing while airborn
	elseif a.gliding then
		accel = 0 --> gliding
	end

	a.dx = approach(a.dx, strafing_x * a.walk_speed, accel * a.walk_speed)

	--> apply world collisions and velocities
	update_actor(a)

	--eye
	a.eye_global_x = a.x + a.d * a.eye_pos_x
	a.eye_global_y = a.y + a.eye_pos_y
end


function update_dog_sprite(a)
	--walking animation
	a.walking = (a.standing and (a.strafing or abs(a.dx) >= a.walk_speed or a.t_frame % 4 != 0))

	if a.walking then
		--if (a.t_frame % 4 == 3) sfx(SFX_STEP)
		local t = flr(a.t_frame)
		a.frame = 16+t
		a.t_frame = flr(3*a.t_frame+1.5)/3 % 4 -->four ticks per frame
	else
		--standing still
		a.frame = 0
	end
end


function draw_dog(a)
	local fr = a.k + a.frame

	local x = pos8(a.x-.5)--.5+8*(a.x-.5)
	local y = pos8(a.y-1)

	spr(fr, x, y,1,1,a.d<0)

	if( a.walking) spr(a.k+1, x+a.d, y+1,1,1,a.d<0)

	pset(pos8(a.eye_global_x), pos8(a.eye_global_y), 8)
end

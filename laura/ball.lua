--ball
--sam westerlund
--29.6.2024

function init_ball_data()
	local a = {}
	
	a.cx = 0
	a.w2 = 2/8 * .5
	a.h  = 2/8
	a.bounce = 0.75
	a.friction = 0.95
	a.min_bounce_speed = 0.08
	a.bounce_sfx = SFX_BALL_BOUNCE
	
	a.draw = draw_ball
	a.update = update_ball

	return a
end


function spawn_ball(x,y,dx,dy)
	a = make_actor(SPR_BALL, x, y, 1)

	a.x = x
	a.y = y
	a.speed_x = dx
	a.speed_y = dy

	return a
end


function update_ball(a)
	update_actor(a)

	if (a.t >= BALL_LIFETIME) delete_actor(a)
end

function draw_ball(a)
	local x = pos8(a.x-.5)--.5+8*(a.x-.5)
	local y = pos8(a.y-1)

	spr(a.k, x, y)
end
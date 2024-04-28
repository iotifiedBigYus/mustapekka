--drag test
--sam westerlund
--28.4.24



-- gravity
G = .02
-- drag coefficient
C = .01
-- umbrella drag coefficient
UC2 = 0.01
UC1 = 0.01

TV = 0.125
--UC1 = 1.2
--UC2 = 0
-- umbrella radius
UR = 2
-- dot radius (in pixels)
DR = 2

function _init()
	a = {
		x = 8,
		y = 8,
		dx = 0,
		dy = 0,
		cx = 0,
		cy = 0,
		a = 0
	}
end


function _update60()
	a.x += a.dx
	a.y += a.dy

	if btn(5) then
		if not umbrella then
			diff = a.dy - TV
			umbrella = true
		end
	else
		umbrella = false
	end

	if(a.x >= 16)a.x-=16
	if(a.x <   0)a.x+=16
	if(a.y >= 16)a.y-=16
	if(a.y <   0)a.y+=16


	if(btn(0))UC1 -= 0.01
	if(btn(1))UC1 += 0.01
	if(btn(2))UC2 -= 0.01
	if(btn(3))UC2 += 0.01

	a.dy += G
	a.dy -= sgn(a.dy) * C * a.dy * a.dy
	--a.dx -= sgn(a.dx) * C * a.dx * a.dx

	--umbrella
	if umbrella then
		--if(btn(⬅️) and not btn(➡️))then
		--	a.u_d = -1
		--elseif(btn(➡️) and not btn(⬅️))then
		--	a.u_d = 1
		--else
		--	a.u_d = 0
		--end

		--only apply drag when descending
		if(a.dy <= 0)return
	
		--player looks in the acceleration direction
		--if(a.u_d != 0)a.d = a.u_d
	
		--a.dx += a.u_ddx * a.u_d * r - sgn(a.dx) * a.dx * a.dx * a.u_drag_x
		--drag = a.dy * a.dy * UC1 + a.dy * UC2 --* r
		a.u_diff *= a.u_friction
		a.dy = a.u_term + a.u_diff
		--a.dy -= drag
	end
end


function _draw()
	cls()
	?a.dy
	?UC1
	?UC2
	?diff
	if umbrella then
		line(
			.5+8*(a.x+UR*sin(a.a+.125)),
			.5+8*(a.y-UR*cos(a.a+.125)),
			.5+8*(a.x+UR*sin(a.a-.125)),
			.5+8*(a.y-UR*cos(a.a-.125)),
			8
		)
	end
	color(7)
	circfill(.5+a.x*8,.5+a.y*8,DR)
end
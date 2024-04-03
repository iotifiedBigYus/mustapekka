function init_actor_data()
	actor_dat=
	{
		-- bridge builder
		[53]={
			ddy=0,
			friction=1,
			move=move_builder,
			draw=function() end
		},
		
		[64]={
			draw=draw_charge_powerup
		},
		
		[65]={
			draw=draw_exit
		},
		
		-- swirly
		[80]={
			life=2,
			frames=1,
			bounce=0,
			ddy=0, -- gravity
			move=move_swirly,
			draw=draw_swirly,
			can_bump=false,
			d=0.25,
			r=5 -- collisions
		},
		
		-- bouncy mushroom
		[82]={
			ddx=0,
			frames=1,
			active_t=0,
			move=move_mushroom
		},
		
		-- glitch mushroom
		[84]={
			draw=draw_glitch_mushroom
		},
		
		-- bird
		[93]={
			move=move_bird,
			draw=draw_bird,
			
			bounce=0,
			ddy=0.03,-- default:0.06
		},
		
		-- frog
		[96]={
			move=move_frog,
			draw=draw_frog,
			bounce=0,
			friction=1,
			tongue=0,
			tongue_t=0
		},
		
		[116]={
			draw=draw_tail
		}
	
	}
end
	
	
function move_builder(a)
	local x,y=a.x,a.y-0.5
	local val=mget(x,y)
	if val==0 then
		mset(x,y,53)
		sfx(19)
	elseif val!=53 then
		del(actor,a) --> remove itself
	end
	
	a.t += 1
	if (x<1 or x>126 or a.t > 30) then
		del(actor,a) --> remove itself
	end 
	
	for i=0,0.2,0.1 do
		local s=make_sparkle(104,a.x,a.y-0.5)   
		s.dx=cos(i+a.x/4)/8
		s.dy=sin(i+a.x/4)/8
		s.col=10
		s.max_t=10+rnd(10)
	end
	
	a.x+=a.dx
end

function move_frog(a)

	move_actor(a)
	
	if (a.life<=0) then
		bang_puff(a.x,a.y-0.5,104)
		sfx(26)
	end

	a.frame=0
	
	local p=closest_p(a,16)
	

	if (a.standing) then
		a.dy=0 a.dx=0
		
		-- jump
		
		if (rnd(20)<1 and
						a.tongue_t==0) then -- jump freq
			-- face player 2/3 times
			if rnd(3)<2 and p then
				a.d=sgn(p.x-a.x)
			end
			a.dy=-0.6-rnd(0.4)
			a.dx=a.d/4
			a.standing=false
			sfx(23)
		end
	else
		a.frame=1
	end
		
	-- move tongue
	
	-- stick tongue out when standing
	if a.tongue_t==0 and
				p and abs(a.x-p.x)<5 and
				rnd(20)<1 and
				a.standing then
		a.tongue_t=1
	end
	
	-- move active tongue
	if (a.tongue_t>0) then
		a.frame=2
		a.tongue_t = (a.tongue_t+1)%24
		local tlen = sin(a.tongue_t/48)*5
		a.tongue_x=a.x-tlen*a.d

		-- catch player
		
		if not a.ha and p then
			local dx=p.x-a.tongue_x
			local dy=p.y-a.y
			if (dx*dx+dy*dy<0.7^2)
			then a.ha=p sfx(22) end
		end
		
		-- skip to retracting
		if (solid(a.tongue_x,
						a.y-.5) and 
				a.tongue_t < 11) then
				a.tongue_t = 24-a.tongue_t
		end
	end
	
	-- move caught actor
	if (a.ha) then
		if (a.tongue_t>0) then
			a.ha.x = a.tongue_x
			a.ha.y = a.y
		else
			a.ha=nil
		end
	end
	
	--a.tongue=1 -- tiles
	
	a.t += 1
end


function draw_frog(a)
	draw_actor(a)
	
	local sx=a.x*8+a.d*4
	local sy=a.y*8-3
	local d=a.d
	
	
	if (a.tongue_t==0 or not a.tongue_t) return
	
	local sx2=a.tongue_x*8
	local sy2=(a.y+0.25)*8
	line(sx,sy,sx2,sy,8)
	rectfill(sx2,sy,sx2+d,sy-1,14)
end

function draw_charge_powerup(a)
	--pal(6,13+(a.t/4)%3)
	draw_actor(a)
	local sx=a.x*8
	local sy=a.y*8-4
	for i=0,5 do
		circfill(
			sx+cos(i/6+time()/2)*5.5,
			sy+sin(i/6+time()/2)*5.5,
			(i+time()*3)%1.5,7)
		end
		
end

function move_mushroom(a)
	a.frame=0
	if (a.active_t>0) then
		a.active_t-=1
		a.frame=1
	end
end

function draw_glitch_mushroom(a)
	local sx=a.x*8
	local sy=a.y*8-4
	
	draw_actor(a)


	dx=cos(time()*5)*3
	dy=sin(time()*3)*3
	
	for y=sy-12,sy+12 do
	for x=sx-12,sx+12 do
		local d=sqrt((y-sy)^2+(x-sx)^2)
		if (d<12 and 
			cos(d/5-time()*2)>.4) then
		pset(x,y,pget(x+dx,y+dy)
		+rnd(1.5))
--  pset(x,y,rnd(16))
		end
	end
	end
	
	pset(sx,sy,rnd(16))
	
	draw_actor(a)
end

function draw_exit(a)
	local sx=a.x*8
	local sy=a.y*8-4
	
	sy += cos(time()/2)*1.5
	
	circfill(sx-1+cos(time()*1.5),sy,3.5+cos(time()),8)
	circfill(sx+1+cos(time()*1.3),sy,3.5+cos(time()),12)
	circfill(sx,sy,3,7)
	
	for i=0,3 do
		circfill(
			sx+cos(i/8+time()*.6)*6,
			sy+sin(i/5+time()*.4)*6,
			1.5+cos(i/7+time()),
			8+i%5)
		circfill(
			sx+cos(.5+i/7+time()*.9)*5,
			sy+sin(.5+i/9+time()*.7)*5,
			.5+cos(.5+i/7+time()),
			14+i%2)
	end
	
end


function turn_to(a,ta,spd)
	
	a %=1 
	ta%=1
	
	while (ta < a-.5) ta += 1
	while (ta > a+.5) ta -= 1
	
	if (ta > a) then
		a = min(ta, a + spd)
	else
		a = max(ta, a - spd)
	end
	
	return a
end

function move_swirly(a)

	-- dying
	if (a.life==0 and a.t%4==0) then
		
		local tail=a.tail[1] 
		local s=tail[#tail]
		
		local cols= {7,15,14,15}
		-- reuse
		atomize_sprite(64,s.x-.5,s.y-.5,cols[1+#tail%#cols])
		del(tail,s) sfx(26)
		if (s==a) del(actor,a) sfx(27)
		
	end
	
	local ah=a.holding
	
	if (ah and a.tail and a.tail[1][15]) then
		ah.x=a.tail[1][15].x
		ah.y=a.tail[1][15].y
		
		ah.dy=-0.1 -- don't land
		if (a.standing) ah.x-=a.d/2
		if (ah.life==0) a.holding=nil
	end
	
	a.t += 1
	if (a.hit_t>0) a.hit_t-=1
	
	if (a.t < 20) then
		a.dx *=.95
		a.dy *=.95
	end
	
	a.x+=a.dx
	a.y+=a.dy
	a.dx *=.95
	a.dy *=.95
	
	local tx=a.homex
	local ty=a.homey
	local p=closest_p(a,200)
	if (p) tx,ty=p.x,p.y
	
	-- local variation
	-- tx += cos(a.t/60)*3	
	-- ty += sin(a.t/40)*3
	
	local turn_spd=1/60
	local accel = 1/64
		
	-- charge 3 seconds 
	-- swirl 3 seconds
	if ((a.t%360 < 180
					and a.life > 1) 
					or a.life==0) and
					abs(a.x-tx<12) then
		ty -= 6
	else
		-- heat-seeking
		-- instant turn, but inertia
		-- means still get swirls
		turn_spd=1/30
		accel=1/40
		if (abs(a.x-tx)>12)accel*=1.5
	end
	
	
	a.d=turn_to(a.d,
		atan2(tx-a.x,ty-a.y),
		turn_spd
	)
	

	a.dx += cos(a.d)*accel
	a.dy += sin(a.d)*accel
	
	-- spawn tail
	if (not a.tail) then
		a.tail={}
		for j=1,3 do
		
			a.tail[j]={}
			for i=1,15 do
				local r=5-i*4/15
				r=mid(1,r,4)
				local slen=r/9 + 0.3
				if (j>1) then
					r=r/3 slen=0.3
					--if (i==1) slen=0
				end
				
				local seg={
					x=a.x-cos(a.d)*i/8,
					y=a.y-sin(a.d)*i/8,
					r=r,slen=slen
				}
				
				add(a.tail[j],seg)
				
			end
			a.tail[j][0]=a
		end
		
	end
	
	-- move tail
	
	for j=1,3 do
	for i=1,#a.tail[j] do
		
		local s=a.tail[j][i]
		local h=a.tail[j][i-1]
		local slen=s.len
		local hx = h.x
		local hy = h.y
		
		if (i==1) then
			if (j==2) hx -=.5 --hy-=.7
			if (j==3) hx +=.5 --hy-=.7
		end
		
		local dx=hx-s.x
		local dy=hy-s.y
		
		local aa=atan2(dx,dy)
	
		if (j==2) aa=turn_to(aa,7/8,0.02)
		if (j==3) aa=turn_to(aa,3/8,0.02)
		s.x=hx-cos(aa)*s.slen
		s.y=hy-sin(aa)*s.slen
	end
	end
	
	-- players collide with tail
	
	for i=0,#a.tail[1] do
	for pi=1,#pl do
		local p=pl[pi]
		if (alive(p) and a.life>0 and 
			p.life>0) then
			s = a.tail[1][i]
			local r=s.r/8 -- from pixels
			local dx=p.x-s.x
			local dy=(p.y-0.5)-s.y
			local dd=sqrt(dx*dx+dy*dy)
			local rr=0.5+r
			if (dd<0.5+r) then
					// janky bounce away
					local aa=atan2(dx,dy)
					aa+=rnd(0.4)-rnd(0.4)
					p.dx=cos(aa)/2
					p.dy=sin(aa)/2
					if (p.is_standing) p.dy=min(p.dy,-0.2)
					sfx(19)
					
					if (p.dash>0) then
						if (i==0) monster_hit(a)
					else
						player_hit(p)
					end
					
			end
		end
		end
		end
		
	
end


function draw_swirly(a)

	if (not a.tail) return
	
	for j=1,3 do
	for i=#a.tail[j],1,-1 do
		seg=a.tail[j][i]
		local sx=seg.x*8
		local sy=seg.y*8
		
		cols =  {7,15,14,15,7,7}
		cols2 = {6,14,8,14,6,6}
		local q= a.life==1 and 4 or 6
		local c=1+flr(i-time()*16)%q
		
		if (j>1) then
			if (i%2==0) then
			circfill(sx,sy,1,8)
			else
			pset(sx,sy,10)
			end
		else
			local r=seg.r+cos(i/8-time())/2
			r=mid(1,r,5)
			r=seg.r
			circfill(sx,sy+r/2,r,cols2[c])
			circfill(sx,sy,r,cols[c])
		end
		
	end
	end
	
	local sx=a.x*8
	local sy=a.y*8-4
	--circ(sx,sy+4,5,rnd(16))
	
	-- mouth
	spr(81,sx-4,sy+5+
		flr(cos(a.t/30)))
	-- head
	spr(80,sx-8,sy)
	spr(80,sx+0,sy,1,1,true)
end

function alive(a)
	if (not a) return false
	if (a.life <=0 and (a.death_t and time() > a.death_t+0.5)) return false
	return true
end

-- ignore everything more than
-- 8 blocks away horizontally
function closest_a(a0,l,attr,maxdx)
	local best
	local best_d
	for i=1,#l do
		if not attr or l[i][attr] then
			local dx=l[i].x-a0.x
			local dy=l[i].y-a0.y
			local d=dx*dx+dy*dy
			if (not best or d<best_d)
			and l[i]!=a0
			and l[i].life > 0
			and (not maxdx or abs(dx)<maxdx)
			then
				best=l[i]
				best_d=d
			end
		end
	end

	return best
end

function closest_p(a,dd)
	return closest_a(a,pl,nil,dd)
end


--[[
	birb
	follow player while close
	
	collect 
	
]]
function move_bird(a)

--[[
	-- spawn with gem
	if (a.t==0) then
		gem=make_actor(67,a.x,a.y)
		a.holding=gem
	end
]]

	move_actor(a)
	
	local ah=a.holding
	
	if (ah) then
		ah.x=a.x
		ah.y=a.y+0x0.e
		ah.dy=0
		if (a.standing) ah.x-=a.d/2
		if (ah.life==0) then
			a.holding=nil 
			sfx(28) -- chirp
		end
	end
	
	local p=closest_p(a,12)
	
	dx=100 dy=100
	-- patrol home no target
	tx,ty=
		a.homex+cos(a.t/120)*6,
		a.homey+sin(a.t/160)*4
	
	if (p) tx,ty=p.x,p.y-3
	
	local a2
	
	if (not a.holding) then
		a2=closest_a(a,actor,"is_pickup")
		if a2 and abs(a2.x-a.x)<4 and
					abs(a2.y-a.y)<4 then
			p=nil -- ignore player
			tx,ty=a2.x,a2.y
			if (a.standing) a.dy=-0.1
		else
			a2=nil -- ignore if far
		end
	end

	-- debug
-- a.tx=tx
-- a.ty=ty

	local dx,dy=tx-a.x,ty-a.y 
	local dd=sqrt(dx*dx+dy*dy)
	
	-- pick up
	if (a2 and dd<1) then
		
		a.holding=a2
		sfx(28) -- chirp
	
	end
	
	-- uncomment: pick up player!
	--[[
	if (p) then
		if (dd<0.5) a.holding=p
		if (a.holding==p) then
			if (btn(4,p.id) or btn(5,p.id)) a.holding=nil
			a.d=p.d
		end
	end
	]]
	
	if (a.t%8==0) a.d=sgn(dx)
	
	if (a.standing) then
		a.frame=0
		
		-- jump to start flying
		if (not solid(a.x,a.y+.2))a.dy=-0.2
		if (p and dd<5) a.dy=-0.3
		
		a.dx=0
		
	else
		-- flying
		local tt=a.t%12
		a.frame=1+tt/6
		-- flap
		if (tt==6) then
			local mag=.3 -- slowly decend
			
			-- fly up
			if (dd<4 and a.y>ty) mag=.4
			
			-- wall: fly to top
			if (a.hit_wall)mag=.45
			
			-- player can shoo upwards
			if (p and a.y>ty and not ah) mag=.45
			
			a.hit_wall = false
			a.dy-=mag
		end
	
		
		if (a.dy<0.2) then
			a.dx+=a.d/64
		end
		
	end
	
	a.frame=a.standing and 0 or
			1+(a.t/4)%2

end


function draw_bird(a)
	local q=flr(a.t/8)
	if ((q^2)%11<1) pal(1,15)
	
	draw_actor(a)
	
	-- debug: show target
	--[[
	if (a.tx) then
		local sx=a.tx*8
		local sy=a.ty*8
		circfill(sx,sy,1,rnd(16))
	end
	]]
end
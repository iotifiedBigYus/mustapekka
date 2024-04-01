-- (camera y is lazy)
ccy_t=0
ccy  =0

-- splitscreen (multiplayer)
split=false

-- camera x for player i
function pl_camx(x,sw)
	return mid(0,x*8-sw/2,1024-sw)
end


function update_camera()

	local num=0
	if (alive(pl[1])) num+=1
	if (alive(pl[2])) num+=1
	
	split = num==2 and
		abs(pl_camx(pl[1].x,64) -
		    pl_camx(pl[2].x,64)) > 64
	
	-- camera y target changes
	-- when standing. quantize y
	-- into 2 blocks high so don't
	-- get small adjustments
	-- (should be in _update)
	
	if (num==2) then
		-- 2 active players: average y
		ccy_t=0
		for i=1,2 do
			ccy_t += (flr(pl[i].y/2+.5)*2-12)*3
		end
		ccy_t/=2
	else
	
		-- single: set target only
		-- when standing
		for i=1,#pl do
			if (alive(pl[i]) and
			    pl[i].standing) then
			    ccy_t=(
			     flr(pl[i].y/2+.5)*2-12
			    )*3
			end
		end
	end
	
	-- target always <= 0
	ccy_t=min(0,ccy_t)
	
	ccy = ccy*7/8+ccy_t*1/8
	cam_y = ccy
	
	local xx=0
	local qq=0
	for i=1,#pl do
			if (alive(pl[i])) then
				local q=1
				
				-- pan across when first
				-- player dies and not in
				-- split screen
				if (pl[i].life<=0 and pl[i].death_t) then
					q=time()-pl[i].death_t
					q=mid(0,1-q*2,1)
					q*=q
				end
				
				xx+=pl[i].x * q
				qq += q
			end
	end
	
	if (split) then
		cam_x = pl_camx(pl[1].x,64)
	elseif qq>0 then
		cam_x = pl_camx(xx/qq,128)
	end
	
end
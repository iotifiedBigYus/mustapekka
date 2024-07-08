--cat
--sam westerlund
--8.7.2024


function init_cat_data()
	local a = {}

	a.w2 = .375
	a.h  = .75
	a.update_sprite = update_cat_sprite
	a.draw          = draw_cat
	a.is_cat = true

	return a
end


function spawn_cat()
	local x, y = find_sprites(SPR_CAT, true)
	clear_cell(x,y)

	return make_actor(SPR_CAT, x+.5, y+1, -1)
end


function update_cat_sprite(a)
	a.frame = flr(a.t_frame)
	a.t_frame = (a.t_frame + .0625) % 4
end


function draw_cat(a)
	local fr = a.k + a.frame

	local x = pos8(a.x-.5)
	local y = pos8(a.y-1)

	spr(fr, x, y)
end
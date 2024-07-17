--input2
--sam westerlund
--29.4.24

--source: celeste 2

input2_x = 0
input2_up = false
input2_down = false
input2_jump = false
input2_jump_pressed = 0
input2_jump_grace = 0
input2_alt = false
input2_alt_pressed = 0
input2_alt_grace = 0
axis2_x_value = 0
axis2_x_turned = false

--⬅️➡️⬆️⬇️

function update_input2()
	local prev_x = axis2_x_value
	if btn(⬅️,1) then
		if btn(➡️,1) then
			if axis2_x_turned then
				axis2_x_value = prev_x
				input2_x = prev_x
			else
				axis2_x_turned = true
				axis2_x_value = -prev_x
				input2_x = -prev_x
			end
		else
			axis2_x_turned = false
			axis2_x_value = -1
			input2_x = -1
		end
	elseif btn(➡️,1) then
		axis2_x_turned = false
		axis2_x_value = 1
		input2_x = 1
	else
		axis2_x_turned = false
		axis2_x_value = 0
		input2_x = 0
	end

	-- up
	input2_up = btn(⬆️,1)

	-- down
	input2_down = btn(⬇️,1)

	-- jump
	local jump = btn(🅾️,1)
	input2_jump_grace = approach(input2_jump_grace)
	if jump and not input2_jump then		
		input2_jump_pressed += 1
		input2_jump_grace = JUMP_GRACE
	else
		input2_jump_pressed = 0
	end
	input2_jump = jump

	-- alternative
	local alt = btn(❎,1)
	input2_alt_grace = approach(input2_alt_grace)
	if alt then
		input2_alt_pressed += 1
		input2_alt_grace = ALT_GRACE
	else
		input2_alt_pressed = 0
	end
	input2_alt = alt
end
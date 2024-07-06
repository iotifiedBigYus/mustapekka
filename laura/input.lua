--input
--sam westerlund
--29.4.24

--source: celeste 2

input_x = 0
input_up = false
input_down = false
input_jump = false
input_jump_pressed = 0
input_jump_grace = 0
input_alt = false
input_alt_pressed = 0
input_alt_grace = 0
axis_x_value = 0
axis_x_turned = false

--⬅️➡️⬆️⬇️

function update_input()
	local prev_x = axis_x_value
	if btn(⬅️) then
		if btn(➡️) then
			if axis_x_turned then
				axis_x_value = prev_x
				input_x = prev_x
			else
				axis_x_turned = true
				axis_x_value = -prev_x
				input_x = -prev_x
			end
		else
			axis_x_turned = false
			axis_x_value = -1
			input_x = -1
		end
	elseif btn(➡️) then
		axis_x_turned = false
		axis_x_value = 1
		input_x = 1
	else
		axis_x_turned = false
		axis_x_value = 0
		input_x = 0
	end

	-- up
	input_up = btn(⬆️)

	-- down
	input_down = btn(⬇️)

	-- jump
	local jump = btn(🅾️)
	input_jump_grace = approach(input_jump_grace)
	if jump and not input_jump then		
		input_jump_pressed += 1
		input_jump_grace = JUMP_GRACE
	else
		input_jump_pressed = 0
	end
	input_jump = jump

	-- alternative
	local alt = btn(❎)
	input_alt_grace = approach(input_alt_grace)
	if alt then
		input_alt_pressed += 1
		input_alt_grace = ALT_GRACE
	else
		input_alt_pressed = 0
	end
	input_alt = alt
end


function consume_jump_press()
	local val = input_jump_pressed > 0
	input_jump_pressed = 0
	return val
end
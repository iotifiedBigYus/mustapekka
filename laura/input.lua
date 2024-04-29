--input
--sam westerlund
--29.4.24

--source: celeste 2

input_x = 0
input_jump = false
input_jump_pressed = 0
input_alt = false
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

	-- input_jump
	local jump = btn(🅾️)
	if jump and not input_jump then		
		input_jump_pressed = 4
	else
		input_jump_pressed = jump and max(0, input_jump_pressed - 1) or 0
	end
	input_jump = jump

	-- alternative
	input_alt = btn(❎)
end


function consume_jump_press()
	local val = input_jump_pressed > 0
	input_jump_pressed = 0
	return val
end
#!/usr/bin/env lua

local function cell_key(x, y)
	return x .. "," .. y
end

local function parse_key(key)
	local x, y = key:match("([^,]+),([^,]+)")
	return tonumber(x), tonumber(y)
end

local function neighbors(x, y)
	return {
		{ x - 1, y - 1 },
		{ x, y - 1 },
		{ x + 1, y - 1 },
		{ x - 1, y },
		{ x + 1, y },
		{ x - 1, y + 1 },
		{ x, y + 1 },
		{ x + 1, y + 1 },
	}
end

local function count_live_neighbors(grid, x, y)
	local count = 0
	for _, n in ipairs(neighbors(x, y)) do
		if grid[cell_key(n[1], n[2])] then
			count = count + 1
		end
	end
	return count
end

local function should_live(grid, x, y)
	local live_neighbors = count_live_neighbors(grid, x, y)
	local is_alive = grid[cell_key(x, y)]

	if is_alive and (live_neighbors == 2 or live_neighbors == 3) then
		return true
	elseif not is_alive and live_neighbors == 3 then
		return true
	else
		return false
	end
end

local function cells_to_check(grid)
	local to_check = {}

	for key in pairs(grid) do
		to_check[key] = true
		local x, y = parse_key(key)
		for _, n in ipairs(neighbors(x, y)) do
			to_check[cell_key(n[1], n[2])] = true
		end
	end

	return to_check
end

local function step(grid)
	local new_grid = {}

	for key in pairs(cells_to_check(grid)) do
		local x, y = parse_key(key)
		if should_live(grid, x, y) then
			new_grid[key] = true
		end
	end

	return new_grid
end

local function display_grid(width, height, grid)
	local output = {}

	for y = 0, height - 1 do
		local row = {}
		for x = 0, width - 1 do
			if grid[cell_key(x, y)] then
				table.insert(row, "#")
			else
				table.insert(row, ".")
			end
		end
		table.insert(output, table.concat(row))
	end

	return table.concat(output, "\n")
end

local function clear_screen()
	os.execute("clear || cls")
end

local function grid_size(grid)
	local count = 0
	for _ in pairs(grid) do
		count = count + 1
	end
	return count
end

local function copy_grid(grid)
	local new_grid = {}
	for key, value in pairs(grid) do
		new_grid[key] = value
	end
	return new_grid
end

local function run_game(width, height, generations, delay_ms, grid)
	local current_grid = copy_grid(grid)

	for gen = 0, generations - 1 do
		clear_screen()
		print(string.format("Generation: %d | Population: %d", gen, grid_size(current_grid)))
		print(display_grid(width, height, current_grid))

		-- Sleep (convert ms to seconds)
		os.execute("sleep " .. delay_ms / 1000)

		current_grid = step(current_grid)
	end
end

local function run_game_infinite(width, height, delay_ms, grid)
	local current_grid = copy_grid(grid)
	local gen = 0

	while true do
		clear_screen()
		print(string.format("Generation: %d | Population: %d", gen, grid_size(current_grid)))
		print(display_grid(width, height, current_grid))
		print("\n[Press Ctrl+C to stop]")

		os.execute("sleep " .. delay_ms / 1000)

		current_grid = step(current_grid)
		gen = gen + 1
	end
end

local function glider(x, y)
	local grid = {}
	grid[cell_key(x + 1, y)] = true
	grid[cell_key(x + 2, y + 1)] = true
	grid[cell_key(x, y + 2)] = true
	grid[cell_key(x + 1, y + 2)] = true
	grid[cell_key(x + 2, y + 2)] = true
	return grid
end

local function blinker(x, y)
	local grid = {}
	grid[cell_key(x, y)] = true
	grid[cell_key(x + 1, y)] = true
	grid[cell_key(x + 2, y)] = true
	return grid
end

local function block(x, y)
	local grid = {}
	grid[cell_key(x, y)] = true
	grid[cell_key(x + 1, y)] = true
	grid[cell_key(x, y + 1)] = true
	grid[cell_key(x + 1, y + 1)] = true
	return grid
end

local function toad(x, y)
	local grid = {}
	grid[cell_key(x + 1, y)] = true
	grid[cell_key(x + 2, y)] = true
	grid[cell_key(x + 3, y)] = true
	grid[cell_key(x, y + 1)] = true
	grid[cell_key(x + 1, y + 1)] = true
	grid[cell_key(x + 2, y + 1)] = true
	return grid
end

local function r_pentomino(x, y)
	local grid = {}
	grid[cell_key(x + 1, y)] = true
	grid[cell_key(x + 2, y)] = true
	grid[cell_key(x, y + 1)] = true
	grid[cell_key(x + 1, y + 1)] = true
	grid[cell_key(x + 1, y + 2)] = true
	return grid
end

local function gosper_glider_gun(x, y)
	local grid = {}

	local cells = {
		{ x, y + 4 },
		{ x, y + 5 },
		{ x + 1, y + 4 },
		{ x + 1, y + 5 },
	}

	local left_part = {
		{ x + 10, y + 4 },
		{ x + 10, y + 5 },
		{ x + 10, y + 6 },
		{ x + 11, y + 3 },
		{ x + 11, y + 7 },
		{ x + 12, y + 2 },
		{ x + 12, y + 8 },
		{ x + 13, y + 2 },
		{ x + 13, y + 8 },
		{ x + 14, y + 5 },
		{ x + 15, y + 3 },
		{ x + 15, y + 7 },
		{ x + 16, y + 4 },
		{ x + 16, y + 5 },
		{ x + 16, y + 6 },
		{ x + 17, y + 5 },
	}

	local right_part = {
		{ x + 20, y + 2 },
		{ x + 20, y + 3 },
		{ x + 20, y + 4 },
		{ x + 21, y + 2 },
		{ x + 21, y + 3 },
		{ x + 21, y + 4 },
		{ x + 22, y + 1 },
		{ x + 22, y + 5 },
		{ x + 24, y },
		{ x + 24, y + 1 },
		{ x + 24, y + 5 },
		{ x + 24, y + 6 },
	}

	local right_square = {
		{ x + 34, y + 2 },
		{ x + 34, y + 3 },
		{ x + 35, y + 2 },
		{ x + 35, y + 3 },
	}

	for _, c in ipairs(cells) do
		grid[cell_key(c[1], c[2])] = true
	end
	for _, c in ipairs(left_part) do
		grid[cell_key(c[1], c[2])] = true
	end
	for _, c in ipairs(right_part) do
		grid[cell_key(c[1], c[2])] = true
	end
	for _, c in ipairs(right_square) do
		grid[cell_key(c[1], c[2])] = true
	end

	return grid
end

local function merge_grids(...)
	local result = {}
	local grids = { ... }

	for _, grid in ipairs(grids) do
		for key, value in pairs(grid) do
			result[key] = value
		end
	end

	return result
end

local function get_user_input(prompt)
	io.write(prompt)
	io.flush()
	local input = io.read()
	return input and input:match("^%s*(.-)%s*$") or ""
end

local function get_speed_input(prompt, default, min_val, max_val)
	local input = get_user_input(prompt)

	if input == "" then
		return default
	end

	local speed = tonumber(input)
	if not speed then
		return default
	end

	if speed < min_val then
		return min_val
	elseif speed > max_val then
		return max_val
	else
		return speed
	end
end

local function get_pattern_config(choice)
	if choice == "1" then
		return {
			pattern = glider(5, 5),
			width = 50,
			height = 25,
			generations = 100,
		}
	elseif choice == "2" then
		return {
			pattern = merge_grids(blinker(10, 10), toad(20, 10)),
			width = 40,
			height = 20,
			generations = 50,
		}
	elseif choice == "3" then
		return {
			pattern = r_pentomino(30, 15),
			width = 60,
			height = 30,
			generations = 200,
		}
	elseif choice == "4" then
		return {
			pattern = gosper_glider_gun(5, 10),
			width = 80,
			height = 40,
			generations = 300,
		}
	elseif choice == "5" then
		return {
			pattern = merge_grids(glider(5, 5), blinker(25, 12), block(40, 18), toad(15, 20)),
			width = 50,
			height = 25,
			generations = 150,
		}
	else
		return {
			pattern = glider(5, 5),
			width = 50,
			height = 25,
			generations = 100,
		}
	end
end

local function print_menu()
	print("Conway's Game of Life")
	print("====================")
	print()
	print("Choose a demo:")
	print("1. Glider (moves across screen)")
	print("2. Oscillators (blinker and toad)")
	print("3. R-pentomino (chaotic growth)")
	print("4. Glider Gun (creates gliders) - INFINITE")
	print("5. Mixed patterns")
	print()
	print("Run mode:")
	print("a. Limited generations (stops automatically)")
	print("b. Infinite mode (run forever, press Ctrl+C to stop)")
	print()
end

local function main()
	print_menu()

	local pattern_choice = get_user_input("Enter pattern choice (1-5): ")
	local mode_choice = get_user_input("Enter mode (a/b): ")
	local speed = get_speed_input("Enter speed in ms (50-1000, default 200): ", 200, 50, 1000)

	local is_infinite = mode_choice:lower() == "b"
	local config = get_pattern_config(pattern_choice)

	if pattern_choice < "1" or pattern_choice > "5" then
		print("Invalid choice. Running glider demo...")
	end

	print("\nStarting simulation...\n")
	if is_infinite then
		print("INFINITE MODE - Press Ctrl+C to stop")
	else
		print("LIMITED MODE - Will stop automatically")
	end
	print(string.format("Speed: %dms per generation", speed))

	os.execute("sleep 1")

	if is_infinite then
		run_game_infinite(config.width, config.height, speed, config.pattern)
	else
		run_game(config.width, config.height, config.generations, speed, config.pattern)
	end

	print("\nSimulation complete!")
end

main()

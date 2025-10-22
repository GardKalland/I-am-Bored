import time
import os
from typing import Set, Tuple
from dataclasses import dataclass

Cell = Tuple[int, int]
Grid = Set[Cell]


@dataclass
class PatternConfig:
    pattern: Grid
    width: int
    height: int
    generations: int


def neighbors(x, y) -> list[Cell]:
    return [
        (x-1, y-1), (x, y-1), (x+1, y-1),
        (x-1, y),             (x+1, y),
        (x-1, y+1), (x, y+1), (x+1, y+1),
    ]


def count_live_neighbors(grid, cell) -> int:
    x, y = cell
    return sum(1 for n in neighbors(x, y) if n in grid)


def should_live(grid, cell) -> bool:
    live_neighbors = count_live_neighbors(grid, cell)
    is_alive = cell in grid
    
    if is_alive and live_neighbors in (2, 3):
        return True  
    elif not is_alive and live_neighbors == 3:
        return True  
    else:
        return False


def cells_to_check(grid) -> Grid:
    return grid | {n for cell in grid for n in neighbors(*cell)}


def step(grid) -> Grid:
    return {cell for cell in cells_to_check(grid) if should_live(grid, cell)}


def display_grid(width, height, grid) -> str:
    output = []
    for y in range(height):
        row = []
        for x in range(width):
            if (x, y) in grid:
                row.append('#')
            else:
                row.append('.')
        output.append(''.join(row))
    return '\n'.join(output)


def clear_screen():
    os.system('clear' if os.name != 'nt' else 'cls')


def run_game(width, height, generations, delay_ms, grid):
    current_grid = grid.copy()
    
    for gen in range(generations):
        clear_screen()
        print(f"Generation: {gen} | Population: {len(current_grid)}")
        print(display_grid(width, height, current_grid))
        time.sleep(delay_ms / 1000.0)
        current_grid = step(current_grid)


def run_game_infinite(width, height, delay_ms, grid):
    current_grid = grid.copy()
    gen = 0
    
    try:
        while True:
            clear_screen()
            print(f"Generation: {gen} | Population: {len(current_grid)}")
            print(display_grid(width, height, current_grid))
            print("\n[Press Ctrl+C to stop]")
            time.sleep(delay_ms / 1000.0)
            current_grid = step(current_grid)
            gen += 1
    except KeyboardInterrupt:
        print("\n\nStopped by user.")


def glider(x, y) -> Grid:
    return {
        (x+1, y), (x+2, y+1), (x, y+2), (x+1, y+2), (x+2, y+2)
    }


def blinker(x, y) -> Grid:
    return {(x, y), (x+1, y), (x+2, y)}


def block(x, y) -> Grid:
    return {(x, y), (x+1, y), (x, y+1), (x+1, y+1)}


def toad(x, y) -> Grid:
    return {
        (x+1, y), (x+2, y), (x+3, y),
        (x, y+1), (x+1, y+1), (x+2, y+1)
    }


def r_pentomino(x, y) -> Grid:
    return {
        (x+1, y), (x+2, y),
        (x, y+1), (x+1, y+1),
        (x+1, y+2)
    }


def gosper_glider_gun(x, y) -> Grid:
    cells = set()
    
    cells.update({(x, y+4), (x, y+5), (x+1, y+4), (x+1, y+5)})
    
    cells.update({
        (x+10, y+4), (x+10, y+5), (x+10, y+6),
        (x+11, y+3), (x+11, y+7),
        (x+12, y+2), (x+12, y+8),
        (x+13, y+2), (x+13, y+8),
        (x+14, y+5),
        (x+15, y+3), (x+15, y+7),
        (x+16, y+4), (x+16, y+5), (x+16, y+6),
        (x+17, y+5),
    })
    
    cells.update({
        (x+20, y+2), (x+20, y+3), (x+20, y+4),
        (x+21, y+2), (x+21, y+3), (x+21, y+4),
        (x+22, y+1), (x+22, y+5),
        (x+24, y), (x+24, y+1), (x+24, y+5), (x+24, y+6),
    })
    
    cells.update({(x+34, y+2), (x+34, y+3), (x+35, y+2), (x+35, y+3)})
    
    return cells


def get_speed_input(i, default = 200, min_val = 50, max_val = 1000) -> int:
    speed_input = get_user_input(i)
    if not speed_input:
        return default
    try:
        return max(min_val, min(max_val, int(speed_input)))
    except ValueError:
        return default


def get_user_input(i) -> str:
    return input(i).strip()


def get_pattern_config(choice) -> PatternConfig:
    match choice:
        case "1":
            return PatternConfig(glider(5, 5), 50, 25, 100)
        case "2":
            return PatternConfig(blinker(10, 10) | toad(20, 10), 40, 20, 50)
        case "3":
            return PatternConfig(r_pentomino(30, 15), 60, 30, 200)
        case "4":
            return PatternConfig(gosper_glider_gun(5, 10), 80, 40, 300)
        case "5":
            pattern = glider(5, 5) | blinker(25, 12) | block(40, 18) | toad(15, 20)
            return PatternConfig(pattern, 50, 25, 150)
        case _:
            return PatternConfig(glider(5, 5), 50, 25, 100)


def print_menu():
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


def main():
    print_menu()
    
    pattern_choice = get_user_input("Enter pattern choice (1-5): ")
    mode_choice = get_user_input("Enter mode (a/b): ")
    speed = get_speed_input("Enter speed in ms (50-1000, default 200): ")
    
    is_infinite = mode_choice.lower() == "b"
    config = get_pattern_config(pattern_choice)
    
    if pattern_choice not in "12345":
        print("Invalid choice. Running glider demo...")
    
    print("\nStarting simulation...\n")
    print("INFINITE MODE - Press Ctrl+C to stop" if is_infinite 
          else "LIMITED MODE - Will stop automatically")
    print(f"Speed: {speed}ms per generation")
    time.sleep(1)
    
    if is_infinite:
        run_game_infinite(config.width, config.height, speed, config.pattern)
    else:
        run_game(config.width, config.height, config.generations, speed, config.pattern)
    
    print("\nSimulation complete!")


if __name__ == "__main__":
    main()

use std::collections::HashSet;
use std::io::Write;
use std::io;
use std::thread;
use std::time::Duration;


type Cell = (i32, i32);
type Grid = HashSet<Cell>;


fn neighbors (x: i32, y: i32) -> Vec<Cell> {
    vec![
        (x-1, y-1), (x, y-1), (x+1, y-1),
        (x-1, y),             (x+1, y),
        (x-1, y+1), (x, y+1), (x+1, y+1),
    ]
}


fn count_live_neighbors(grid: &Grid, cell: &Cell) -> usize {
    neighbors(cell.0, cell.1)
        .iter()
        .filter(|n| grid.contains(n))
        .count()
}


fn should_live(grid: &Grid, cell: &Cell) -> bool {
    let live_neighbors = count_live_neighbors(grid, cell);
    let is_alive = grid.contains(cell);
    
    match (is_alive, live_neighbors) {
        (true, 2) | (true, 3)  => true,
        (false, 3) => true,
        _ => false

    }
}

fn cells_to_check(grid: &Grid) -> HashSet<Cell> {
    let mut check = grid.clone();

    for &cell in grid.iter(){
        for neigh in neighbors(cell.0, cell.1) {
            check.insert(neigh);
        }
    }
    check
}

fn step(grid: &Grid) -> Grid {
    cells_to_check(grid)
        .iter()
        .filter(|c| should_live(grid, c))
        .copied()
        .collect()
}

fn display_grid(width: i32, height: i32, grid: &Grid) -> String {
    let mut out = String::new();

    for y in 0..height {
        for x in 0..width {
            if grid.contains(&(x, y)) {
                out.push('#')
            }
            else {
                out.push('.')
            }
        }
        out.push('\n')
    }
    out
}


fn clear_screen() {
    print!("\x1B[2J\x1B[H");
    io::stdout().flush().unwrap();
}


fn run_game(width: i32, height: i32, generations: usize, delay_ms: u64, grid: &Grid) {
    let mut current_grid = grid.clone();


    for gen in 0..generations {
        clear_screen();
        println!("Generation: {} | Population: {}", gen, current_grid.len());
        println!("{}", display_grid(width, height, &current_grid));
        io::stdout().flush().unwrap();

        thread::sleep(Duration::from_millis(delay_ms));
        current_grid = step(&current_grid);
    }
}


fn run_game_infinite(width: i32, height: i32, delay_ms: u64, grid: &Grid) {
    let mut current_grid = grid.clone();
    let mut gen = 0;


    loop {
        clear_screen();
        println!("Generation: {} | Population: {}", gen, current_grid.len());
        println!("{}", display_grid(width, height, &current_grid));
        io::stdout().flush().unwrap();

        thread::sleep(Duration::from_millis(delay_ms));
        current_grid = step(&current_grid);
        gen += 1;

    }
}


fn glider(x: i32, y: i32) -> Grid {
    vec![
        (x+1, y), (x+2, y+1), (x, y+2), (x+1, y+2), (x+2, y+2)
    ].into_iter().collect()
}

fn blinker(x: i32, y: i32) -> Grid {
    vec![(x, y), (x+1, y), (x+2, y)].into_iter().collect()
}

fn block(x: i32, y: i32) -> Grid {
    vec![(x, y), (x+1, y), (x, y+1), (x+1, y+1)].into_iter().collect()
}

fn toad(x: i32, y: i32) -> Grid {
    vec![
        (x+1, y), (x+2, y), (x+3, y),
        (x, y+1), (x+1, y+1), (x+2, y+1)
    ].into_iter().collect()
}

fn r_pentomino(x: i32, y: i32) -> Grid {
    vec![
        (x+1, y), (x+2, y),
        (x, y+1), (x+1, y+1),
        (x+1, y+2)
    ].into_iter().collect()
}

fn gosper_glider_gun(x: i32, y: i32) -> Grid {
    let mut cells = Vec::new();
    
    cells.extend(vec![(x, y+4), (x, y+5), (x+1, y+4), (x+1, y+5)]);
    
    cells.extend(vec![
        (x+10, y+4), (x+10, y+5), (x+10, y+6),
        (x+11, y+3), (x+11, y+7),
        (x+12, y+2), (x+12, y+8),
        (x+13, y+2), (x+13, y+8),
        (x+14, y+5),
        (x+15, y+3), (x+15, y+7),
        (x+16, y+4), (x+16, y+5), (x+16, y+6),
        (x+17, y+5),
    ]);
    
    cells.extend(vec![
        (x+20, y+2), (x+20, y+3), (x+20, y+4),
        (x+21, y+2), (x+21, y+3), (x+21, y+4),
        (x+22, y+1), (x+22, y+5),
        (x+24, y), (x+24, y+1), (x+24, y+5), (x+24, y+6),
    ]);
    
    cells.extend(vec![(x+34, y+2), (x+34, y+3), (x+35, y+2), (x+35, y+3)]);
    
    cells.into_iter().collect()
}


fn get_user_input(prompt: &str) -> String {
    println!("{}", prompt);
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
    input.trim().to_string()
}

fn main() {
    println!("Conway's Game of Life");
    println!("====================");
    println!();
    println!("Choose a demo:");
    println!("1. Glider (moves across screen)");
    println!("2. Oscillators (blinker and toad)");
    println!("3. R-pentomino (chaotic growth)");
    println!("4. Glider Gun (creates gliders) - INFINITE");
    println!("5. Mixed patterns");
    println!();
    println!("Run mode:");
    println!("a. Limited generations (stops automatically)");
    println!("b. Infinite mode (run forever, press Ctrl+C to stop)");
    println!();



    let pattern_choice = get_user_input("Enter the pattern choice (1-5)");
    let mode_choice = get_user_input("Enter mode (a/b): ");
    let speed_input = get_user_input("Enter speed in ms (50-1000, default 200): ");


    let speed = if speed_input.is_empty() {
        200
    } else {
        speed_input.parse::<u64>().unwrap_or(200).clamp(50, 1000)
    };

    let is_infinite = mode_choice == "b";

    println!("\nStarting simulation...\n");

    if is_infinite {
        println!("INFINITE MODE - Press Ctrl+C to stop");
    } else {
        println!("LIMITED MODE - Will stop automatically");
    }

    println!("Speed: {}ms per generation", speed);
    thread::sleep(Duration::from_secs(1));


    match pattern_choice.as_str() {
        "1" => {
            let pattern = glider(5, 5);
            if is_infinite {
                run_game_infinite(50, 25, speed, &pattern);
            } else {
                run_game(50, 25, 100, speed, &pattern);
            }
        },
        "2" => {
            let mut pattern = blinker(10, 10);
            pattern.extend(toad(20, 10));
            if is_infinite {
                run_game_infinite(40, 20, speed, &pattern);
            } else {
                run_game(40, 20, 50, speed, &pattern);
            }
        },
        "3" => {
            let pattern = r_pentomino(30, 15);
            if is_infinite {
                run_game_infinite(60, 30, speed, &pattern);
            } else {
                run_game(60, 30, 200, speed, &pattern);
            }
        },
        "4" => {
            let pattern = gosper_glider_gun(5, 10);
            if is_infinite {
                run_game_infinite(80, 40, speed, &pattern);
            } else {
                run_game(80, 40, 300, speed, &pattern);
            }
        },
        "5" => {
            let mut pattern = glider(5, 5);
            pattern.extend(blinker(25, 12));
            pattern.extend(block(40, 18));
            pattern.extend(toad(15, 20));
            if is_infinite {
                run_game_infinite(50, 25, speed, &pattern);
            } else {
                run_game(50, 25, 150, speed, &pattern);
            }
        },
        _ => {
            println!("Invalid choice. Running glider demo...");
            let pattern = glider(5, 5);
            if is_infinite {
                run_game_infinite(50, 25, speed, &pattern);
            } else {
                run_game(50, 25, 100, speed, &pattern);
            }
        }
    }

    println!("\nSimulation complete!");
}





package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"
)

type Cell struct {
	X, Y int
}

type Grid map[Cell]bool

type PatternConfig struct {
	Pattern     Grid
	Width       int
	Height      int
	Generations int
}

func neighbors(x, y int) []Cell {
	return []Cell{
		{x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
		{x - 1, y}, {x + 1, y},
		{x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1},
	}
}

func countLiveNeighbors(grid Grid, cell Cell) int {
	count := 0
	for _, n := range neighbors(cell.X, cell.Y) {
		if grid[n] {
			count++
		}
	}
	return count
}

func shouldLive(grid Grid, cell Cell) bool {
	liveNeighbors := countLiveNeighbors(grid, cell)
	isAlive := grid[cell]
	if isAlive && (liveNeighbors == 2 || liveNeighbors == 3) {
		return true
	} else if !isAlive && liveNeighbors == 3 {
		return true
	} else {
		return false
	}
}

func cellsToCheck(grid Grid) Grid {
	check := make(Grid)
	for cell := range grid {
		check[cell] = true
		for _, n := range neighbors(cell.X, cell.Y) {
			check[n] = true
		}
	}
	return check
}

func step(grid Grid) Grid {
	newGrid := make(Grid)
	for cell := range cellsToCheck(grid) {
		if shouldLive(grid, cell) {
			newGrid[cell] = true
		}
	}
	return newGrid
}

func displayGrid(width, height int, grid Grid) string {
	var sb strings.Builder
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			if grid[Cell{x, y}] {
				sb.WriteString("#")
			} else {
				sb.WriteString(".")
			}
		}
		sb.WriteString("\n")
	}
	return sb.String()
}

func clearScreen() {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("cmd", "/c", "cls")
	} else {
		cmd = exec.Command("clear")
	}
	cmd.Stdout = os.Stdout
	cmd.Run()
}

func runGame(width, height, generations, delayMs int, grid Grid) {
	currentGrid := copyGrid(grid)
	for gen := 0; gen < generations; gen++ {
		clearScreen()
		fmt.Printf("Generation: %d | Population: %d\n", gen, len(currentGrid))
		fmt.Print(displayGrid(width, height, currentGrid))
		time.Sleep(time.Duration(delayMs) * time.Millisecond)
		currentGrid = step(currentGrid)
	}
}

func runGameInfinite(width, height, delayMs int, grid Grid) {
	currentGrid := copyGrid(grid)
	gen := 0
	for {
		clearScreen()
		fmt.Printf("Generation: %d | Population: %d\n", gen, len(currentGrid))
		fmt.Print(displayGrid(width, height, currentGrid))
		fmt.Println("\n[Press Ctrl+C to stop]")
		time.Sleep(time.Duration(delayMs) * time.Millisecond)
		currentGrid = step(currentGrid)
		gen++
	}
}

func copyGrid(grid Grid) Grid {
	newGrid := make(Grid)
	for cell := range grid {
		newGrid[cell] = true
	}
	return newGrid
}

func glider(x, y int) Grid {
	return Grid{
		{x + 1, y}:     true,
		{x + 2, y + 1}: true,
		{x, y + 2}:     true,
		{x + 1, y + 2}: true,
		{x + 2, y + 2}: true,
	}
}

func blinker(x, y int) Grid {
	return Grid{
		{x, y}:     true,
		{x + 1, y}: true,
		{x + 2, y}: true,
	}
}

func block(x, y int) Grid {
	return Grid{
		{x, y}:         true,
		{x + 1, y}:     true,
		{x, y + 1}:     true,
		{x + 1, y + 1}: true,
	}
}

func toad(x, y int) Grid {
	return Grid{
		{x + 1, y}:     true,
		{x + 2, y}:     true,
		{x + 3, y}:     true,
		{x, y + 1}:     true,
		{x + 1, y + 1}: true,
		{x + 2, y + 1}: true,
	}
}

func rPentomino(x, y int) Grid {
	return Grid{
		{x + 1, y}:     true,
		{x + 2, y}:     true,
		{x, y + 1}:     true,
		{x + 1, y + 1}: true,
		{x + 1, y + 2}: true,
	}
}

func gosperGliderGun(x, y int) Grid {
	grid := make(Grid)
	cells := []Cell{
		{x, y + 4}, {x, y + 5}, {x + 1, y + 4}, {x + 1, y + 5},
	}
	cells = append(cells,
		Cell{x + 10, y + 4}, Cell{x + 10, y + 5}, Cell{x + 10, y + 6},
		Cell{x + 11, y + 3}, Cell{x + 11, y + 7},
		Cell{x + 12, y + 2}, Cell{x + 12, y + 8},
		Cell{x + 13, y + 2}, Cell{x + 13, y + 8},
		Cell{x + 14, y + 5},
		Cell{x + 15, y + 3}, Cell{x + 15, y + 7},
		Cell{x + 16, y + 4}, Cell{x + 16, y + 5}, Cell{x + 16, y + 6},
		Cell{x + 17, y + 5},
	)
	cells = append(cells,
		Cell{x + 20, y + 2}, Cell{x + 20, y + 3}, Cell{x + 20, y + 4},
		Cell{x + 21, y + 2}, Cell{x + 21, y + 3}, Cell{x + 21, y + 4},
		Cell{x + 22, y + 1}, Cell{x + 22, y + 5},
		Cell{x + 24, y}, Cell{x + 24, y + 1}, Cell{x + 24, y + 5}, Cell{x + 24, y + 6},
	)
	cells = append(cells,
		Cell{x + 34, y + 2}, Cell{x + 34, y + 3}, Cell{x + 35, y + 2}, Cell{x + 35, y + 3},
	)
	for _, cell := range cells {
		grid[cell] = true
	}
	return grid
}

func mergeGrids(grids ...Grid) Grid {
	result := make(Grid)
	for _, grid := range grids {
		for cell := range grid {
			result[cell] = true
		}
	}
	return result
}

func getUserInput(prompt string) string {
	fmt.Print(prompt)
	reader := bufio.NewReader(os.Stdin)
	input, _ := reader.ReadString('\n')
	return strings.TrimSpace(input)
}

func getSpeedInput(prompt string, defaultVal, minVal, maxVal int) int {
	input := getUserInput(prompt)
	if input == "" {
		return defaultVal
	}
	speed, err := strconv.Atoi(input)
	if err != nil {
		return defaultVal
	}
	if speed < minVal {
		return minVal
	}
	if speed > maxVal {
		return maxVal
	}
	return speed
}

func getPatternConfig(choice string) PatternConfig {
	switch choice {
	case "1":
		return PatternConfig{glider(5, 5), 50, 25, 100}
	case "2":
		return PatternConfig{mergeGrids(blinker(10, 10), toad(20, 10)), 40, 20, 50}
	case "3":
		return PatternConfig{rPentomino(30, 15), 60, 30, 200}
	case "4":
		return PatternConfig{gosperGliderGun(5, 10), 80, 40, 300}
	case "5":
		return PatternConfig{
			mergeGrids(glider(5, 5), blinker(25, 12), block(40, 18), toad(15, 20)),
			50, 25, 150,
		}
	default:
		return PatternConfig{glider(5, 5), 50, 25, 100}
	}
}

func printMenu() {
	fmt.Println("Conway's Game of Life")
	fmt.Println("====================")
	fmt.Println()
	fmt.Println("Choose a demo:")
	fmt.Println("1. Glider (moves across screen)")
	fmt.Println("2. Oscillators (blinker and toad)")
	fmt.Println("3. R-pentomino (chaotic growth)")
	fmt.Println("4. Glider Gun (creates gliders) - INFINITE")
	fmt.Println("5. Mixed patterns")
	fmt.Println()
	fmt.Println("Run mode:")
	fmt.Println("a. Limited generations (stops automatically)")
	fmt.Println("b. Infinite mode (run forever, press Ctrl+C to stop)")
	fmt.Println()
}

func main() {
	printMenu()
	patternChoice := getUserInput("Enter pattern choice (1-5): ")
	modeChoice := getUserInput("Enter mode (a/b): ")
	speed := getSpeedInput("Enter speed in ms (50-1000, default 200): ", 200, 50, 1000)
	isInfinite := strings.ToLower(modeChoice) == "b"
	config := getPatternConfig(patternChoice)
	if patternChoice < "1" || patternChoice > "5" {
		fmt.Println("Invalid choice. Running glider demo...")
	}
	fmt.Println("\nStarting simulation...\n")
	if isInfinite {
		fmt.Println("INFINITE MODE - Press Ctrl+C to stop")
	} else {
		fmt.Println("LIMITED MODE - Will stop automatically")
	}
	fmt.Printf("Speed: %dms per generation\n", speed)
	time.Sleep(1 * time.Second)
	if isInfinite {
		runGameInfinite(config.Width, config.Height, speed, config.Pattern)
	} else {
		runGame(config.Width, config.Height, config.Generations, speed, config.Pattern)
	}
	fmt.Println("\nSimulation complete!")
}

import Data.Set (Set)
import qualified Data.Set as Set
import Control.Concurrent (threadDelay)
import System.IO (hFlush, stdout)

type Cell = (Int, Int)
type Grid = Set Cell

-- Core game logic
neighbors :: Cell -> [Cell]
neighbors (x, y) = 
    [(x-1, y-1), (x, y-1), (x+1, y-1),
     (x-1, y),             (x+1, y),
     (x-1, y+1), (x, y+1), (x+1, y+1)]

countLiveNeighbors :: Grid -> Cell -> Int
countLiveNeighbors grid cell = 
    length $ filter (`Set.member` grid) (neighbors cell)

shouldLive :: Grid -> Cell -> Bool
shouldLive grid cell =
    let liveNeighbors = countLiveNeighbors grid cell
        isAlive = cell `Set.member` grid
    in case (isAlive, liveNeighbors) of
        (True, 2)  -> True
        (True, 3)  -> True
        (False, 3) -> True
        _          -> False

cellsToCheck :: Grid -> Set Cell
cellsToCheck grid = 
    Set.unions (grid : map (Set.fromList . neighbors) (Set.toList grid))

step :: Grid -> Grid
step grid = Set.filter (shouldLive grid) (cellsToCheck grid)

-- Display
displayGrid :: Int -> Int -> Grid -> String
displayGrid width height grid =
    unlines [[if Set.member (x, y) grid then '#' else '.' 
             | x <- [0..width-1]] 
             | y <- [0..height-1]]

clearScreen :: IO ()
clearScreen = putStr "\ESC[2J\ESC[H"

runGame :: Int -> Int -> Int -> Int -> Grid -> IO ()
runGame width height generations delayMs grid = go 0 grid
  where
    go gen currentGrid
        | gen >= generations = return ()
        | otherwise = do
            clearScreen
            putStrLn $ "Generation: " ++ show gen ++ " | Population: " ++ show (Set.size currentGrid)
            putStrLn $ displayGrid width height currentGrid
            hFlush stdout
            threadDelay (delayMs * 1000)
            go (gen + 1) (step currentGrid)

-- Run game infinitely with controls
runGameInfinite :: Int -> Int -> Int -> Grid -> IO ()
runGameInfinite width height delayMs grid = go 0 grid
  where
    go gen currentGrid = do
        clearScreen
        putStrLn $ "Generation: " ++ show gen ++ " | Population: " ++ show (Set.size currentGrid)
        putStrLn $ displayGrid width height currentGrid
        putStrLn "\n[Press Ctrl+C to stop]"
        hFlush stdout
        threadDelay (delayMs * 1000)
        go (gen + 1) (step currentGrid)

-- Patterns
glider :: Cell -> Grid
glider (x, y) = Set.fromList
    [(x+1, y), (x+2, y+1), (x, y+2), (x+1, y+2), (x+2, y+2)]

blinker :: Cell -> Grid
blinker (x, y) = Set.fromList [(x, y), (x+1, y), (x+2, y)]

block :: Cell -> Grid
block (x, y) = Set.fromList [(x, y), (x+1, y), (x, y+1), (x+1, y+1)]

toad :: Cell -> Grid
toad (x, y) = Set.fromList 
    [(x+1, y), (x+2, y), (x+3, y), (x, y+1), (x+1, y+1), (x+2, y+1)]

rPentomino :: Cell -> Grid
rPentomino (x, y) = Set.fromList
    [(x+1, y), (x+2, y), (x, y+1), (x+1, y+1), (x+1, y+2)]

gosperGliderGun :: Cell -> Grid
gosperGliderGun (x, y) = Set.fromList $
    [(x, y+4), (x, y+5), (x+1, y+4), (x+1, y+5)] ++
    [(x+10, y+4), (x+10, y+5), (x+10, y+6),
     (x+11, y+3), (x+11, y+7),
     (x+12, y+2), (x+12, y+8),
     (x+13, y+2), (x+13, y+8),
     (x+14, y+5),
     (x+15, y+3), (x+15, y+7),
     (x+16, y+4), (x+16, y+5), (x+16, y+6),
     (x+17, y+5)] ++
    [(x+20, y+2), (x+20, y+3), (x+20, y+4),
     (x+21, y+2), (x+21, y+3), (x+21, y+4),
     (x+22, y+1), (x+22, y+5),
     (x+24, y), (x+24, y+1), (x+24, y+5), (x+24, y+6)] ++
    [(x+34, y+2), (x+34, y+3), (x+35, y+2), (x+35, y+3)]

-- Main program
main :: IO ()
main = do
    putStrLn "Conway's Game of Life"
    putStrLn "===================="
    putStrLn ""
    putStrLn "Choose a demo:"
    putStrLn "1. Glider (moves across screen)"
    putStrLn "2. Oscillators (blinker and toad)"
    putStrLn "3. R-pentomino (chaotic growth)"
    putStrLn "4. Glider Gun (creates gliders) - INFINITE"
    putStrLn "5. Mixed patterns"
    putStrLn ""
    putStrLn "Run mode:"
    putStrLn "a. Limited generations (stops automatically)"
    putStrLn "b. Infinite mode (run forever, press Ctrl+C to stop)"
    putStrLn ""
    putStr "Enter pattern choice (1-5): "
    hFlush stdout
    patternChoice <- getLine
    
    putStr "Enter mode (a/b): "
    hFlush stdout
    modeChoice <- getLine
    
    putStr "Enter speed in ms (50-1000, default 200): "
    hFlush stdout
    speedInput <- getLine
    let speed = if null speedInput then 200 else read speedInput :: Int
    let actualSpeed = max 50 (min 1000 speed)
    
    let isInfinite = modeChoice == "b"
    
    putStrLn "\nStarting simulation...\n"
    putStrLn $ if isInfinite 
               then "INFINITE MODE - Press Ctrl+C to stop"
               else "LIMITED MODE - Will stop automatically"
    putStrLn $ "Speed: " ++ show actualSpeed ++ "ms per generation"
    threadDelay 1000000
    
    let runPattern w h gens pat = 
            if isInfinite 
            then runGameInfinite w h actualSpeed pat 
            else runGame w h gens actualSpeed pat
    
    case patternChoice of
        "1" -> runPattern 50 25 100 (glider (5, 5))
        "2" -> runPattern 40 20 50 $ Set.unions [blinker (10, 10), toad (20, 10)]
        "3" -> runPattern 60 30 200 (rPentomino (30, 15))
        "4" -> runPattern 80 40 300 (gosperGliderGun (5, 10))
        "5" -> runPattern 50 25 150 $ Set.unions 
                [ glider (5, 5)
                , blinker (25, 12)
                , block (40, 18)
                , toad (15, 20)
                ]
        _   -> putStrLn "Invalid choice. Running glider demo..." >> 
               runPattern 50 25 100 (glider (5, 5))
    
    putStrLn "\nSimulation complete!"

import Data.List
import System.Random
import System.Environment (getArgs)

import qualified Data.Set as Set
import qualified Data.Map as Map

data Cell = Cell {
					bottom :: Bool,
					right :: Bool
				 } deriving (Eq,Ord)
instance Show Cell where
	show (Cell True False)	= "___"
	show (Cell True True)	= "__|"
	show (Cell False False)	= "   "
	show (Cell False True) 	= "  |"

data Row = Row	{
					randomList	::	[Bool],
					cellMap		::	Map.Map Int Cell,
					setMap		::	Map.Map Int (Set.Set Int)
				} deriving (Eq, Ord)
instance Show Row where
	show (Row _ r _) = "|" ++ concat (Map.elems (Map.map show r)) ++ "|"
	{-show r@(Row rl cells sets) = "|" ++ (Map.foldl (\acc c -> acc ++ (show c)) "" cells) ++ "|"-}
		{-++ "\n" ++ (showCells r) ++ "\n" ++ (showSets r) ++ "\n" ++ show rl-}

data Maze = Maze [Row]

instance Show Maze where
	show (Maze m@((Row {cellMap = cells} ):cx))
		= " " ++  replicate (Map.size cells * 3) '_' ++ "\n" ++
			foldl (\acc r -> acc ++ show r ++ "\n") "" m
lookupNotMaybe k m = 
	let 
		ret = Map.lookup k m
	in
		case ret of
			(Just r) -> r 
			Nothing	->
				error $ "key: " ++ show k ++ "; \n Map: \n\t" ++ show m

getSetKey :: Int -> Row -> Int
getSetKey n = 
	head . Map.keys . Map.filter id . Map.map (Set.member n) . setMap
getSet :: Int -> Row -> Set.Set Int
getSet n r@(Row _ cells sets) = 
	x
		where
			(Just x) = Map.lookup (getSetKey n r) sets

isSetSame :: Row -> Int -> Int -> Bool
isSetSame r n1 n2 = (==) (getSetKey n1 r) $ getSetKey n2 r

moveToSet :: Int -> Int -> Row -> Row
moveToSet nSet nCell r@(Row rl cells sets) = 
	Row 
		rl
		cells $
		Map.insert nSet (Set.insert nCell (safelyLookup nSet sets)) 
		$ Map.insert (getSetKey nCell r) (Set.delete nCell (getSet nCell r)) sets
			where 
				safelyLookup k m =
					let
						res = Map.lookup k m
					in
						case res of
							(Just r)	-> r
							Nothing		-> safelyLookup k $ setMap $ cleanSets $ Row rl cells m

mergeSets :: Row -> Int -> Int -> Row
mergeSets (Row rl cells sets) n1 n2 = 
	cleanSets $
	Row rl cells $ Map.insert n1 (s1 `Set.union` s2) $ Map.insert n2 Set.empty sets
	where
		(Just s1) = Map.lookup n1 sets
		(Just s2) = Map.lookup n2 sets

newRow :: Row -> Row
newRow = 
	createBottom . createRight . joinToUniqueSet . removeWalls 

removeWalls :: Row -> Row
removeWalls row@(Row _ cells _) = 
	Map.foldlWithKey f row cells
		where 
			f :: Row -> Int -> Cell -> Row
			f (Row rl cells' sets') key (Cell b _)
				| b			= moveToSet 0 key $ Row rl (Map.insert key (Cell False False) cells') sets'
				| otherwise	= Row rl (Map.insert key (Cell False False) cells') sets' 


joinToUniqueSet :: Row -> Row
joinToUniqueSet row@(Row _ cells _) = 
	foldl f row $ Map.keys cells 
		where 
			f :: Row -> Int -> Row
			f row'@(Row _ _ sets') key
				| (==) 0 $ getSetKey key row =
					moveToSet (getUniqueSet sets') key row'
				| otherwise = row' 

getUniqueSet :: Map.Map Int (Set.Set Int) -> Int
getUniqueSet = (+) 1 . maximum . Map.keys . Map.filter (not . Set.null)

createRight :: Row -> Row
createRight row@(Row _ cells sets) = 
	Map.foldlWithKey f row cells
		where
			cellsAmount = Map.size cells	
			f :: Row -> Int -> Cell -> Row
			f row'@(Row (rl:rls) cells' sets') n _ 
				| n >= (cellsAmount - 1) = row'
				| isSetSame row' n $ n + 1 =
					Row 
						rls
						(Map.insert n (Cell False True) cells')
						sets'
		
				| rl = --RANDOM!!
					Row 
						rls
						(Map.insert n (Cell False True) cells')
						sets'
				| otherwise = 
					mergeSets (Row rls cells' sets') (getSetKey n row') (getSetKey (n + 1) row')
createBottom :: Row -> Row
createBottom (Row rl cells sets) =
	Map.foldlWithKey f (Row rl cells sets) cells
		where
			f :: Row -> Int -> Cell -> Row
			f row'@(Row (rl:rls) cells' sets') n1 (Cell _ r1)
				| noWay = row'
				-- We can add one more bottom wall
				| rl = --RANDOM 1111!!!!!
					Row 
						rls
						(Map.insert n1 (Cell True r1) cells')
						sets'
				| otherwise =
					Row rls cells' sets'	
				where 
					noWay = (<= 1) . length . filter (not . bottom) . 
						map (`lookupNotMaybe` cells') . 
							Set.toList 
							$ getSet n1 row'

cleanSets :: Row -> Row
cleanSets (Row rl cells sets) = 
	Row
		rl
		cells $
		Map.insert (getUniqueSet sets') Set.empty sets'
			where
				sets' = Map.fromList $ zip [0..] $ snd $ unzip $ Map.toList $
					Map.filter (not . Set.null) sets

lastRow :: Row -> Row
lastRow (Row rl cells sets) = 
	Map.foldlWithKey helper (Row rl cells sets) cells
		where
			helper row@(Row _ cells' sets') key (Cell b1 r1)
				| key >= Map.size cells' - 1 =
					Row rl (Map.insert key (Cell True r1) cells') sets'
				| isSetSame row key (key + 1) =
					 Row rl (Map.insert key (Cell True r1) cells') sets' 
				| otherwise =
					mergeSets 
					(Row rl (Map.insert key (Cell True False) cells') sets')
					(getSetKey key row) (getSetKey (key + 1) row) 

makeRow :: Int -> StdGen -> Row
makeRow l gen =
		Row
			(randomRs (True,False) gen)
			(Map.fromList $
				zip [0 ..l]
					(replicate l (Cell False False)))
			$ Map.fromList $ zip [0 .. l]
				[
					Set.fromList [0 .. l]
				]

createMaze s gen =
	Maze $ 
		init maze1 ++ [lastRow $ last maze1]
			where 
				maze1 = foldl (\acc _ -> acc ++ newRow (last acc) : []) [newRow $ makeRow s gen] [0 .. s]

main = do
	args <- fmap (read . head) getArgs
	gen  <- getStdGen
	print $ createMaze args gen

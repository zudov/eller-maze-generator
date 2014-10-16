Eller's Algorithm for maze generation
=====================================
**WARNING**: THIS CODE IS HORRIBLE, H-O-R-R-I-B-L-E. I wrote it when I was a very newbie at haskell. Please, learn no Haskell from it. And please, do not judge my haskell/coding foo based on code in that repo. I gonna refactor^W rewrite that code soon, it's in my DO-SOME-OTHER-DAY list.

This is my implementation of algorythm which is described [here](http://www.neocomputer.org/projects/eller.html). It creates perfect mazes, here are few examples:

Small 5x5 maze:

	 _______________
	|___  |______   |
	|  |  |  |___   |
	|  |___   __|   |
	|  |  |___   ___|
	|___   __|      |
	|   __|_____|   |
	|_______________|

Bigger 10x10 maze:

	  ______________________________
	 |  |  |___   __|___  |___  |   |
	 |  |  |  |  |___   _____|  |   |
	 |  |  |  |        |______   ___|
	 |___   __|__|  |     |___  |   |
	 |  |  |______  |__|   _________|
	 |  |  |   __|___  |   ___  |   |
	 |  |  |  |  |     |  |  |__|   |
	 |_________  |__|__|     |  |   |
	 |      ______      __|___  |   |
	 |  |   _____|__|__|___  |__|   |
	 |  |  |  |  |        |   __|   |
	 |__|___________|__|____________|

To build it run "cabal install".

	╭─user@localhost  ~/haskell  
	╰─$ cd eller_maze_generator 
	╭─user@localhost  ~/haskell/eller_maze_generator  ‹master*› 
	╰─$ cabal install
	Resolving dependencies...
	Configuring mazeGen-0.1...
	Building mazeGen-0.1...
	Preprocessing executable 'mazeGen' for mazeGen-0.1...
	[1 of 1] Compiling Main ( mazeGen.hs, dist/build/mazeGen/mazeGen-tmp/Main.o )
	Linking dist/build/mazeGen/mazeGen ...
	Installing executable(s) in /home/user/.cabal/bin
	Installed mazeGen-0.1

mazeGen takes one argument which is size of algorythm.

	╭─user@localhost  ~/haskell/eller_maze_generator  ‹master*› 
	╰─$ ~/.cabal/bin/mazeGen 4
	  ____________
	 |  |  |  |   |
	 |  |  |  |   |
	 |   _____|   |
	 |   ___  |   |
	 |     |___   |
	 |__|_____|___|


# SUPER XO

#### Video Demo: <URL HERE>

## Description

Inspired by a [short](https://www.youtube.com/watch?v=_Na3a1ZrX7c) from the youtube channel Vsauce, the super mode of Tic Tac Toe adds an extra layer to an already very well known game, giving it enough complexity to finally encourage players to think before placing an X or O!

The layer in question? Instead of claiming one of the nine boxes on the board by simply placing an X or O, you now have to win a separate Tic Tac Toe game in each square to claim it!

Using LOVE 2D and Lua, <b>SUPER XO</b> provides textual indicators of the current active board to be played on, as well as the current player's turn and which board currently is being viewed on screen. Players are able to look at one of the nine grids by clicking on the corresponding box on the mini-grid on their screen.

Feeling like giving the complexity a rest and returning to simpler times? <b>SUPER XO</b> provides a STANDARD XO mode as well! Contaning the same helpful visual features of the SUPER mode but without the complexities. But what if there is no one to play the game with? <b>SUPER XO</b>'s very simple bot is here to help! Players are able to choose to play both modes either against a friend or a bot.

To start playing, click on <b>SUPERXO.love</b>!

## Rules

<b>SUPER XO</b> plays very similarly to its standard counterpart, there is simply a twist to every X or O you place on the board. The rules are as follows:
- Game starts on board 1, with player 1.
- A player wins the board by securing three blocks in a row in any direction.
- A player wins the game by securing three boards in a row in any direction or by winning most boards in case of a tie.
- When an X or O is placed, the next player must play at the board number corresponding to the block that the previous player played their X or O on.
(Ex: P1 plays block 5 on board 1, P2 must now play on board 5.)
- If a player places an X or O at block corresponding to a winning or tied board, then the next player can play their turn on any incomplete board.

## Project Files

### <b>main.lua</b>
The meat of the project, containing the key functions to load the initial variables when starting the game, displaying the visuals, and constant checks for the mouse position and presses. This is done through LOVE 2D's `love.[func]` multiple functions, including `love.load`, `love.draw` and `love.mousepressed`. The screen scaling is done using the library [resolution_solution.lua](#---external-libraries).

The file also contains the code for the custom cursor, custom font and custom functions that take care of the basic animation and sounds that are seen and heard in the game.

Initially every part of the game's code was going to be in this one file. However, as the code expanded and I gained experience, a decision was made to put most of the function definitons out in a separate file. Important objects also each got their own files, which will be dived into separately.

### <b>assets/Libraries</b>
This file contains all the different functions that have been taken out of main.lua for the sake of readability and organization.

### -- Block.lua
The Block object is the box in which X or O is placed when a mouse press is detected over it. It contains the function to ensure that the correct X or O is displayed on the block based on who clicked on the block as well as if the block is part of the winning three in a row.

### -- Button.lua
Since the functionality of blocks were very similar to that of a 'button', similar code has been implemented here from [Block.lua](#---blocklua).

The main differences here are that buttons are more customizable, with the ability to add text, have them run different functions and have them be different sizes.

### -- Game.lua
As the name implies, almost all of the functions that take care of how the game works are found in this file. Everything from restarting a game, going from menu to either super mode or standard mode, playing sound, checking if a player has won the game, the super mode's mini grid functionality as well as code behind the game's Bot.

### -- Grid.lua
The object that contains the nine [blocks](#---blocklua) necessary for a single grid of tic tac toe. In this file is where the size of each block and the spacing in the grid is being control, with the grid object doing the formatting for the grid as a 3x3 matrix all on its own.

### -- Palette.lua
This contains the greenish black and white color that is used throughout the whole game. This color pallette was chosen for the sake of giving the game a more retro feel, saving me a lot of brain power when it comes to the visuals of the game and helping me focus on the functionality instead. This single file is essentially what determined the art direction of the game.

### -- Settings.lua
Functions in this file take care of the single 'setting' in the game, that being audio control. It utilizes the [json](#---external-libraries) library to save and load data, then a function uses that saved data to adust the audio accordingly.

### -- SmallBtn.lua
Almost identical to [Button.lua](#---buttonlua) except these buttons have images instead of texts, with the button size depending on the image size. Used for Audio Control and Pause button to name a few.

### -- External Libraries
The goal throughout this project was to make my own code for most of the functions required for the project to work. However, for the sake of learning, some external libraries were used to assist with some functionalities.

First of which is resolution_solution.lua, which simply made sure that the scalings of everything on the game_screen were consistent when going full screen. Second is json.lua, used in [Settings.lua](#---settingslua) to convert between a json object and a lua table for the sake of saving and loading the audio levels.

### <b>assets/sounds, assets/sprites, assets/fonts</b>
These files contain the rest of what shapes SUPER XO to be the way it is. The font used for pixel text was found on [dafont.com](https://www.dafont.com/pixeltype.font), the arcade like sounds were downloaded from [freesound.org](https://freesound.org/) and [pixabay.com](https://pixabay.com/), while the sprites were all made by me using [Pixel Studio](https://store.steampowered.com/app/1204050/Pixel_Studio__pixel_art_editor/) on steam.
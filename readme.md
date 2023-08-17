# Science Randomizer
[![made-with-python](https://img.shields.io/badge/Made%20with-Lua-13008F.svg)](https://www.lua.org/)
 [![GitHub release](https://img.shields.io/github/release/Redart15/science-randomizer)](https://GitHub.com/Redart15/science-randomizer/releases/)\
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Redart15/science-randomizer/graphs/commit-activity)
[![GitHub latest commit](https://badgen.net/github/last-commit/Redart15/chemical-warfare)](https://GitHub.com/Redart15/science-randomizer/commit/)

## Introduction
This is a mod for the game [Factorio](https://store.steampowered.com/app/427520/Factorio/).\
Factorio is a real-time strategy game where players must build and manage complex automated factories.

## Features
Randomizes the recipe for the science packs.
The recipes only use item that can be unlock with thr previous tier of item, thus making the game always complitable.


## How it works
The mod calc order of packs(right now its static), than running through all tech its query its tier and the recipes and add
the item those unlock to its resperctve tier. Finaly it picks 2-5 random item for each tier and constructs the recipes.

## Structure
- Libs: contains libiaries used in the mod
- prototype/science-randomnizer: contains the actual modding files

## ToDo
- [ ] make it compatable with other mods
- [ ] add option to toggle wood/fish or others, this will require getting mods
- [ ] add tierless to allow complete randomness(still completable)
- [ ] add missing items such as barrels, fish, water and steam

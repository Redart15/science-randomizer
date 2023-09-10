# Science Randomizer
[![made-with-lua](https://img.shields.io/badge/Made%20with-Lua-13008F.svg)](https://www.lua.org/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Redart15/science-randomizer/graphs/commit-activity)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/Redart15/science-randomizer/master)


## Introduction
This is a mod for the game [Factorio](https://store.steampowered.com/app/427520/Factorio/).\
Factorio is a real-time strategy game where players must build and manage complex automated factories.

## Features
Randomizes the recipe for the science packs.
The recipes only use item that can be unlock with thr previous tier of item, thus making the game always complitable.


## How it works
The mod calc order of packs(right now its static), than running through all tech its query its tier and the recipes and add
the item those unlock to its resperctve tier. Finaly it picks 1-5 random item for each tier and constructs the recipes.



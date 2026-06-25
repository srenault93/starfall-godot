# Starfall

A small arcade dodge game built with the [Godot Engine](https://godotengine.org/) (4.x) and GDScript.

Move a ship left and right to dodge an accelerating stream of falling blocks.
Your score climbs with survival time, and the spawn rate and fall speed ramp up
the longer you last.

![Godot](https://img.shields.io/badge/Godot-4.7-blue)
![GDScript](https://img.shields.io/badge/GDScript-game-green)

## Run it

1. Install [Godot 4](https://godotengine.org/download).
2. Open the editor, import this folder (`project.godot`), and press **F5**.

## Controls

| Key            | Action          |
| -------------- | --------------- |
| Left / Right   | Move the ship   |
| Enter          | Start / restart |

## How it works

A single `Node2D` (`main.gd`) runs the whole game with a small state machine
(`menu` / `playing` / `gameover`). Each frame it reads input, advances the
falling blocks, ramps difficulty as a function of survival time, and resolves
collisions with `Rect2.intersects`. All rendering is done in `_draw()` with
immediate-mode rectangle and text calls — no external art assets.

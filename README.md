# Pulse Evade: Enhanced 2D Game (Godot Engine)

A simple yet fully playable 2D game built using the **Godot Engine**, originally based on the official [Godot "Dodge the Creeps" tutorial](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html).

---

## 🎮 Game Overview

You play as a character who must dodge endless mobs coming from all directions. As the game progresses, you earn points, pick up power-ups, and survive as long as possible.

This enhanced version includes several additional gameplay elements to make the experience more complete and engaging.

---

## ✨ Features Added

🛡️ **Health System**
- 5-heart display system  
- Taking damage removes hearts (1 hit = -1 heart)

💥 **Hit Damage Effects**
- Camera shake effect when colliding with mobs  
- Game over triggers after 5 hits

⚡ **Power-Ups**
- `Shield` – Grants temporary invincibility (5 seconds)  
- `Slowmo` – Slows all mobs for a short time (5 seconds) 
- `Score Boost` – Doubles score rate for a few seconds (5 seconds) 
- `Explode` – Instantly clears all mobs on screen

🧠 **Difficulty Levels**
- Choose between `Easy`, `Medium`, and `Hard` before starting the game  
- Each mode adjusts mob speed, spawn rate, and size

---

## ⚙️ Difficulty Stats

| Difficulty | Mob Speed | Mob Size | Spawn Rate | Lives |
|------------|-----------|----------|------------|--------|
| Easy       | 60%       | Small    | Slow       | 5 Hearts |
| Medium     | 80%       | Medium   | Moderate   | 5 Hearts |
| Hard       | 100%      | Full     | Fast       | 5 Hearts |

---

## 📚 Built With

- **Godot Engine** v4.x  
- GDScript  
- Original tutorial reference: [Godot Docs – First 2D Game](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html)

---

## 📂 Project Purpose

This project was developed as a **Midterm Lab Exam** for the course **COSC106**. While it began as a guided project, the additional systems and mechanics were independently implemented to demonstrate deeper understanding of the Godot engine and game design principles.

---

## 🔑 Credits

- Godot Official Documentation for the base project
- Assets: Free sprites and UI icons (self-assembled)
- Developed by: **Julius Raagas**

---

## 🚀 How to Run

1. Download [Godot Engine](https://godotengine.org/download)
2. Open the project folder in Godot
3. Press **F5** or click **Play** to run the game

---

Enjoy dodging!

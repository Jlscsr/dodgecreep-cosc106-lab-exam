# Pulse Evade — Enhanced 2D Game (Godot 4)

An expanded take on the classic **“Dodge the Creeps”** tutorial.  
Built in **Godot 4.x** with clean GDScript, it layers in health, power-ups, and dynamic difficulty for a polished, replayable mini-game.

---

## 🎮 Gameplay at a Glance
* Survive an endless onslaught of mobs.
* Collect power-ups to bend the odds in your favour.
* Out-last the difficulty curve and chase a high score.

---

## ✨ Key Features

| System            | What it Does | Where it Lives |
|-------------------|--------------|----------------|
| **5-Heart Health**| Lose one heart per hit; zero = game over.| `HUD`, `Player` signals |
| **Camera Shake**  | Screen jolt on damage for punchy feedback.| `Camera2D` |
| **Power-Ups**     | `Shield`, `Slow-Mo`, `Score Boost`, `Explode` (all ±5 s).| `PowerUpSpawner`, `PowerUp` |
| **Adaptive Difficulty** | `DifficultyTimer` gradually trims spawn delay & buffs mob speed.| `Main` |
| **Three Modes**   | Pick **Easy / Medium / Hard** up-front.| Title/HUD menu |
| **Clean Audio Mix** | Separate streams for BG-music, FX, death jingle.| `BGMmusic`, `DamageTaken`, `DeathSound` |

---

## ⚙️ Difficulty Matrix

| Mode   | Mob Speed | Spawn Rate | Mob Size | Lives |
|--------|-----------|-----------|----------|-------|
| Easy   | 60 %      | Slow      | Small    | 5 ♥ |
| Medium | 80 %      | Moderate  | Medium   | 5 ♥ |
| Hard   | 100 %     | Fast      | Full     | 5 ♥ |

---

## 📚 Tech Stack
* **Godot Engine 4.x**
* **GDScript** (idiomatic, signal-driven)
* Base tutorial: *First 2D Game* (Godot docs)

---

## 🎓 Project Purpose
Created for **COSC106 – Final Laboratory Exam**.  
Beyond replicating the tutorial, custom systems were designed and coded to showcase mastery of Godot’s node architecture, timers, signals, and scene organisation.

---

## 🛠 How to Run
1. Install **Godot 4** → <https://godotengine.org/download>  
2. Open the project folder.  
3. Press **F5** (Play) — enjoy!

---

## 🔑 Credits
* Godot Documentation & Community  
* Free/CC-0 sprites & UI icons (self-curated)  
* Code, design & polish — **Julius Raagas**

---

Happy dodging!

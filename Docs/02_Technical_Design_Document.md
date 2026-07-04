# Project Emberfall — Technical Design Document

Last Updated: 2026-07-04

Status: core stack decided (2026-07-04). Backend intentionally deferred. Coding standards partially defined — the logic/presentation separation rule is set; the rest fills in as implementation starts. Prototype-scope equipment and enemy data schemas defined (2026-07-04). Project scaffolded at the repo root (2026-07-04), verified opening cleanly in Godot 4.7. First real code landed (2026-07-04): the `game/` rules layer implements the Prototype's Core Attributes, Skill Gain (bucket system), Sword damage/crit math, Threat/Balance, Character Creation defaults, and a full real-time `CombatEncounter` loop (cooldown-gated player actions, passive skill-vs-skill defense via `DefenseRules`, independent enemy clock) — all pure GDScript with no scene/node dependencies, per the Architecture Rule below; the encounter exposes `advance_time(delta)` and the scene feeds it frame deltas. A presentation-layer scene exists: `scenes/combat/combat_screen.tscn` renders the encounter as a playable portrait combat screen (see `13_UI_UX.md` — Combat HUD); it is the project's main scene. Verified via `tests/run_tests.gd` (76 checks, run with `godot --headless --script res://tests/run_tests.gd`), which includes a smoke test that drives the combat screen's buttons through a full fight.

---

## Tech Stack

Decided 2026-07-04 (see `CHANGELOG.md`):

- **Engine:** Godot 4.x
- **Language:** GDScript
- **Saves (Prototype):** local JSON on device, behind a save-service abstraction
- **Backend:** none for the Prototype — see Backend Architecture below
- **Source control:** Git + GitHub
- **Distribution:** App Store / Play Store (Beta milestone onward; Prototype runs on personal devices only)

### Why Godot over Unity

- Emberfall is a UI-heavy 2D tactical RPG. Godot's 2D and UI systems are first-class; Unity's are layers on top of a 3D engine.
- GDScript is Python-like — the fastest ramp for a scripting background.
- Free, MIT-licensed, lightweight editor, fast iteration.

### Known tradeoffs accepted

- Smaller ecosystem than Unity (fewer genre-specific tutorials, fewer turnkey mobile SDKs for analytics/IAP/push — more community plugins).
- If the game ever needs something Godot lacks, migration is real work. Mitigation: the logic/presentation separation rule below keeps game rules engine-agnostic.

---

## Architecture Rule: Logic / Presentation Separation

**Game rules never call engine APIs.** Combat math, skill gain, Balance, Renown, save data structures, and all Balance Bible formulas live in plain GDScript classes with no scene, node, rendering, or input dependencies. Scenes and UI consume the rules layer; they never implement rules.

This buys:

- Headless testability — Balance Bible formulas (`11_Balance_Bible.md`) can be unit-tested without booting the engine.
- Engine insurance — if a migration is ever forced, the rules layer ports as plain code.

---

## Folder Structure

Lives at the repo root, alongside `Docs/`:

```
project.godot   # Godot project file
game/           # engine-agnostic rules layer: combat, skills, saves, formulas
scenes/         # Godot scenes (screens, combat view, Bastion view)
ui/             # reusable UI components, themes
assets/         # art, audio, fonts
data/           # item/enemy/skill definitions (resource files)
tests/          # headless tests for the rules layer
```

## Data Schemas

Status: Prototype-scope only (the Sword). Broader equipment (armor, additional weapons) extends this shape as needed. Represented as Godot `Resource` subclasses (`.tres` files) living in `data/` per the Folder Structure above — data-driven and editable without touching code.

### EquipmentSlot (enum)
- Weapon: RightHand, LeftHand, Ranged
- Armor: Chest, Legs, Hands, Head, Feet
- Adventuring: Back, Backpack, Ring1, Ring2, Necklace, Belt

(Design rationale for these slots: `09_Economy_And_Crafting.md`.)

### EquipmentData (base resource)
| Field | Type | Notes |
|---|---|---|
| `id` | String | unique key |
| `display_name` | String | |
| `slots_occupied` | Array[EquipmentSlot] | e.g. a Greatsword would be `[RightHand, LeftHand]` |
| `appearance` | AppearanceData | see below |
| `durability` | — | _TBD_ — not implemented for Prototype (see `09_Economy_And_Crafting.md`) |

### WeaponData (extends EquipmentData)
| Field | Type | Notes |
|---|---|---|
| `base_damage` | int | feeds the damage formula in `11_Balance_Bible.md` |
| `trained_skill` | Skill enum | which skill this weapon trains on use (see `05_Skills_And_Progression.md`) |
| `can_parry` | bool | whether Parry is available with this weapon equipped (see Weapon Feel, `04_Combat_Design.md`) |
| `stamina_cost_modifier` | float | multiplies the base action Stamina costs in `11_Balance_Bible.md`; the hook for future weapon-feel differentiation (e.g. a Great Axe costing more Stamina per swing) — unused for the Prototype's single weapon |

Concrete Prototype values (the Sword instance): `11_Balance_Bible.md`.

### ArmorData (extends EquipmentData)
Deferred — no armor exists in Prototype scope (see `14_Roadmap.md`). Fields TBD when armor is added.

### EnemyData (base resource)
Stats and timings only — the enemy's real-time state machine (circle → telegraph → strike → recover, with retreat/Howl at transitions) lives in `game/combat/combat_encounter.gd`; the pure, stateless checks live in `game/enemies/enemy_rules.gd`. The Wolf's "Emboldened" state is not yet implemented, since it depends on combat-loop state (has Balance returned to neutral since the last landed Bite?), not just the enemy's stat block.

| Field | Type | Notes |
|---|---|---|
| `id` | String | unique key |
| `display_name` | String | |
| `max_hp` | int | |
| `bite_damage_min` / `bite_damage_max` | int | |
| `evasion_chance` | float | chance to avoid an incoming player attack |
| `attack_skill` | int | checked against the defender's passive defense skills (DefenseRules) |
| `telegraph_seconds` | float | warning time before an attack lands |
| `attack_cooldown_seconds` | float | recovery after an attack resolves |
| `circling_seconds` | float | opening delay before the first attack; 0 = engages immediately |
| `retreat_hp_fraction` | float | HP fraction (0-1) that triggers retreat; 0 = never retreats |
| `retreat_seconds` | float | duration of the (single) retreat |
| `has_howl` | bool | Dire Wolf only |
| `howl_telegraph_seconds` | float | warning time before a Howl resolves |
| `enrage_hp_fraction` | float | HP fraction (0-1) that triggers Enrage; 0 = no Enrage |
| `enrage_damage_multiplier` | float | applied to bite damage while enraged |

Concrete Prototype values (Wolf, Dire Wolf): `11_Balance_Bible.md`.

### AppearanceData
| Field | Type | Notes |
|---|---|---|
| `equipment_type` | String | e.g. `"Sword"` |
| `material` | String | no material list defined yet — _TBD_ |
| `color_palette` | String/enum | no palette defined yet — _TBD_, see `12_Art_Direction.md` |
| `ornament_layer` | String | no ornament system defined yet — _TBD_ |

## Backend Architecture

**Deferred — deliberately.** The Prototype uses local saves only. A single persistent character will eventually want server-authoritative progression (anti-cheat, cross-device sync); that decision is blocked until a milestone actually needs it.

Open question, recorded so it isn't lost:

- **PlayFab** — game-shaped (inventory, economy, player data, LiveOps built in).
- **Firebase** — simpler and cheaper at small scale; general-purpose.
- **Supabase / custom** — maximum control, most work.

Areas to define when this is picked up: authentication, save-data schema and sync, server-authoritative validation, events, any async social features (`03_Game_Systems.md`).

## Coding Standards

Defined so far:

- Logic/presentation separation (see Architecture Rule above) — this is the load-bearing standard.
- GDScript conventions follow the official Godot style guide (snake_case members, PascalCase classes) unless a documented reason exists.

Still to define as implementation starts:

- Script organization and scene composition patterns
- Autoload/singleton rules
- Signal vs. direct-call conventions
- Test conventions for the rules layer

---

_This document is where implementation detail — algorithms, formulas, data structures — belongs once it exists. Keep it out of 01_Game_Design_Document.md._

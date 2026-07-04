# Project Emberfall — Balance Bible

Last Updated: 2026-07-04

Numbers only. This document will change hundreds of times during development — never mix it with design documents.

Status: Prototype-scope combat and skill-gain numbers drafted (2026-07-04), covering Sword vs. Wolf only (per `14_Roadmap.md`). All values below are first-pass and expected to change heavily after playtesting — treat every number on this page as a placeholder that happens to be internally consistent, not a final balance pass. Everything outside Prototype scope remains TBD.

---

## Core Attributes

Character creation doesn't exist yet, so the values below are a flat placeholder spread (not a point-buy result) used to unblock Prototype development. Real starting-value ranges/allocation are _TBD_ — see `05_Skills_And_Progression.md`.

| Attribute | Placeholder Starting Value | Governs | Pool Formula | Prototype Pool Size |
|---|---|---|---|---|
| Intellect | 10 | Skill bucket cap | `50 + (Intellect * 5)` | 100 |
| Vitality | 10 | Max HP, Max Stamina | `50 + (Vitality * 5)` | 100 / 100 |
| Willpower | 10 | Max Mana, Max Focus | `50 + (Willpower * 5)` | 100 / 100 (unused — no caster in Prototype) |

Using one shared formula shape across all three is a first-pass simplification for consistency, not a permanent constraint — nothing requires the three pools to scale identically once real balancing starts.

## Skills

### Skill Level Curve
XP required to go from skill level N to N+1: `round(20 * N^1.5)`. Grows with level so early skill-ups come fast and later ones take real investment. Skill cap: 100 (see `05_Skills_And_Progression.md` — not finalized).

### Skill Gain Bucket (see `03_Game_Systems.md` — Skill Gain)
- **Bucket cap** (per skill) = `50 + (Intellect * 5)` (see Core Attributes above). At placeholder Intellect 10, cap = 100.
- **Passive drain rate** (anywhere, always on): 1% of current bucket contents converted to skill XP per minute.
- **Bastion Rest drain rate**: 10% of current bucket contents per minute while resting (10x passive rate).
- A full bucket does not block further actions — actions still resolve normally, they just stop granting bucket XP until it drains some.
- Relative-difficulty scaling (harder actions/enemies grant proportionally more bucket XP) is deferred until a second enemy exists to calibrate against — see per-action values below for the Prototype's fixed case.

### Per-Action Bucket XP — Prototype (Sword vs. Wolf)
Difficulty multiplier fixed at 1.0 (single-enemy prototype; relative scaling TBD).

| Action | Skill Trained | Bucket XP |
|---|---|---|
| Successful Attack lands | Blades | +2 |
| Successful Heavy Attack lands | Blades | +4 |
| Successful Parry | Parry | +3 |
| Successful Dodge | Evasion | +2 |
| Successful Guard | Guard | +1 |

## Combat

### Player HP
- Max HP = `50 + (Vitality * 5)` (see Core Attributes above). At placeholder Vitality 10 = 100.

### Stamina
- Pool = `50 + (Vitality * 5)` (see Core Attributes above). At placeholder Vitality 10 = 100.
- Regen: +5 per turn by default; +10 per turn if the turn's action was Guard or Wait.
- Costs (finalized for Prototype; supersedes the directional examples previously in `04_Combat_Design.md`): Attack -10, Heavy Attack -20, Dodge -15, Parry -8, Reposition/Sprint -12.
- Low Stamina threshold: below 20, outgoing damage -25% and Guard/Parry effectiveness -25% (this is the "attacks become slower and defense weakens" pacing effect referenced in `04_Combat_Design.md`).

### Damage Formula (Prototype: Sword)
```
Attack Damage = (WeaponBaseDamage + floor(BladesSkill / 10)) x PositionModifier x VarianceRoll - EnemyDefense
```
- WeaponBaseDamage comes from the equipped weapon's data (see Equipment below); Sword = 10
- Blades skill contributes +1 flat damage per 10 skill levels (skill 100 -> +10)
- VarianceRoll: random between 0.85 and 1.15
- PositionModifier: Frontline x1.2, Balanced x1.0, Guarded x0.8, Flanking x1.1 (Flanking's main benefit is Crit Chance, not this modifier — see below)
- Heavy Attack: same formula, then x1.8 total; costs more Stamina and is more easily punished (see Wolf AI below)

### Critical Hits
- Base Crit Chance: 5%. +1% per 5 points of Precision skill.
- Flanking position: +10% Crit Chance on top of the above.
- Critical Hit: x2 damage.

### Threat and Initiative
- Threat generated per hit = `Damage Dealt x (1 + Presence/100)`. Enemies target whoever holds highest threat (single-target only until a second enemy/pack exists to matter).
- Initiative: +10 on landing a hit, +15 on a successful Parry, +5 on a successful Dodge, -15 when hit by an enemy attack. Range 0-100.
- At Initiative >= 50: player unlocks one free bonus action (a Heavy Attack with no Stamina cost and no telegraph) usable once before Initiative drops back below 50.

### Mana / Focus
_TBD — out of Prototype scope (no spellcasting weapon/enemy in the Prototype)._

### Defense Resolution (Prototype)
Not previously specified anywhere — added when implementing the combat encounter loop. Deterministic first pass: no separate success-chance roll, since the enemy telegraphs one round ahead specifically so a correctly-timed defensive choice should work.
- **Parry**: fully negates the incoming attack (0 damage) if the equipped weapon's `can_parry` is true; otherwise the attack lands in full.
- **Dodge**: fully negates the incoming attack (0 damage).
- **Guard**: reduces incoming damage by 50%, further reduced by the low-Stamina penalty (`x0.75`) when applicable.
- Choosing an offensive action (Attack/Heavy Attack) instead of a defensive one while an attack is resolving takes the full hit — trading blows is a valid, deliberate choice, not a mistake the game corrects for you.

## Equipment (Prototype)

Schema: `02_Technical_Design_Document.md` — Data Schemas.

### Sword (WeaponData instance)
- `base_damage`: 10
- `trained_skill`: Blades
- `can_parry`: true
- `stamina_cost_modifier`: 1.0 (baseline — no other weapon exists yet to compare against)
- `slots_occupied`: [RightHand]
- `appearance`: placeholder only — `equipment_type` = "Sword"; material/color_palette/ornament_layer undefined (`12_Art_Direction.md` is TBD)

## Enemies

### Wolf (Prototype enemy)
- HP: 60
- Bite (standard attack) damage: 8-14
- Behavior: circles for the first 2 rounds before engaging; telegraphs "Wolf lunges!" one round before a Bite; retreats below 25% HP for 3 rounds (first-pass number for "several rounds"), then re-engages regardless of HP — the encounter loop doesn't model a spatial/cornering system, so "re-engages if cornered" is simplified to "retreat always expires."
- Defense: high innate Evasion (~20% chance to avoid an incoming Attack), low Guard.
- On landing a Bite: Wolf becomes "Emboldened" (+25% Bite damage) until the player regains Initiative (see Threat and Initiative above).

### Dire Wolf (Prototype boss)
A boss version of the Wolf — same base template, one added ability, and a personality shift that makes it feel distinctly boss-tier rather than a reskinned trash mob.

- HP: 220 (vs. Wolf's 60)
- Bite damage: 16-24 (vs. Wolf's 8-14)
- Behavior: unlike the regular Wolf, does **not** circle at range or retreat at low HP — it stays aggressive at all times. Bite telegraphs the same way ("Dire Wolf lunges!").
- Defense: same baseline as Wolf (~20% innate Evasion, low Guard) — the fight is harder because of damage/HP/Howl, not because it's evasive.
- **Howl (new ability):** telegraphed one round ahead ("Dire Wolf throws back its head and howls!"). On resolving, Dire Wolf's Initiative is immediately set to 100, seizing full control of the fight (see Threat and Initiative above — this is the mechanical embodiment of "when enemies seize Initiative, they become more dangerous" from `04_Combat_Design.md`). Triggers once at the start of the fight and again the first time its HP drops below 50%.
- **Enrage (below 33% HP):** Bite damage +30%, permanently (no threshold to escape it by fleeing, since it never retreats).

## Economy
- Loot %: _TBD_
- Drop rates: _TBD_
- Crafting recipes: _TBD_

## Bastion
- Upgrade costs per tier: _TBD_

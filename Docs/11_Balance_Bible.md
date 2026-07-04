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
Difficulty multiplier fixed at 1.0 (single-enemy prototype; relative scaling TBD). Attack rows trigger on player actions; the defense rows trigger on successful *passive* defense checks (see Defense Resolution below).

| Trigger | Skill Trained | Bucket XP |
|---|---|---|
| Successful Attack lands | Blades | +2 |
| Successful Heavy Attack lands | Blades | +4 |
| Successful passive Parry | Parry | +3 |
| Successful passive Dodge | Evasion | +2 |
| Successful passive Block | Guard | +1 |

## Combat

Combat is real-time and cooldown-paced (2026-07-04 — see `CHANGELOG.md`); all durations below are in seconds.

### Player Action Cooldowns
One shared cooldown gate: using any action locks all actions for that action's duration.
- Attack: 2.0s
- Heavy Attack: 4.0s
- Stance change: 3.0s

### Player HP
- Max HP = `50 + (Vitality * 5)` (see Core Attributes above). At placeholder Vitality 10 = 100.

### Stamina
- Pool = `50 + (Vitality * 5)` (see Core Attributes above). At placeholder Vitality 10 = 100.
- Regen: 4/second; 6/second while in the Guarded stance.
- Action costs: Attack -10, Heavy Attack -20, Stance change -12. Passive defense costs on success: Parry -8, Dodge -15, Block 0.
- Low Stamina threshold: below 20, outgoing damage -25% and passive defense chances -25% (this is the "attacks become slower and defense weakens" pacing effect referenced in `04_Combat_Design.md`).

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

### Threat and Balance
- Threat generated per hit = `Damage Dealt x (1 + Presence/100)`. Enemies target whoever holds highest threat (single-target only until a second enemy/pack exists to matter).
- Balance (formerly "Initiative", renamed 2026-07-04): one shared meter per fight, range 0-100. 100 = player in full control, 0 = enemy in full control. **Every fight starts at 50 (neutral).**
- Balance deltas: +10 on landing a hit, +15 on a successful passive Parry, +5 on a successful passive Dodge, +3 on a successful passive Block, -15 when hit by an enemy attack.
- At Balance >= 75: player unlocks one free bonus action (a Heavy Attack with no Stamina cost and no telegraph) usable once before Balance drops back below 75. (Threshold raised from the old 50 when the neutral start moved to 50 — the reward should require earned advantage, not the opening bell. Not yet implemented in the encounter loop.)

### Mana / Focus
_TBD — out of Prototype scope (no spellcasting weapon/enemy in the Prototype)._

### Defense Resolution (Prototype — passive)
Reworked 2026-07-04: defense is no longer a player selection. When an enemy attack lands, checks run automatically in order **Parry → Dodge → Block**; the first success wins; all failing means a full hit.

Each check's chance:
```
chance = BaseChance
       + (DefenderSkill - AttackerSkill) x 0.5% per point
       + StanceModifier
       + (Balance - 50) x 0.2% per point
       [x 0.75 if defender is at low Stamina]
clamped to [0%, 60%]
```
- Base chances: Parry 20% (only if the equipped weapon's `can_parry` is true — otherwise skipped), Dodge 15%, Block 25%.
- Defender skills checked: Parry / Evasion / Guard respectively, vs. the enemy's `attack_skill`.
- Stance modifiers: Frontline -10%, Balanced 0%, Guarded +15%.
- Outcomes: Parry negates (Balance +15, Stamina -8, trains Parry), Dodge negates (Balance +5, Stamina -15, trains Evasion), Block halves damage (Balance +3, no Stamina cost, trains Guard), full hit (Balance -15).
- The 60% per-check cap is deliberate: even a master can be hit, and stacking all three checks still leaves real danger.

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
- Attack skill: 10 (checked against the player's passive defenses — see Defense Resolution)
- Timings: circles for 4.0s at the fight's start; Bite telegraph 1.5s; recovery between attacks 3.0s.
- Retreat: below 25% HP, backs off for 6.0s (once per fight), then re-engages regardless — no spatial/cornering system, so "re-engages if cornered" is simplified to "retreat expires."
- Defense: high innate Evasion (~20% chance to avoid an incoming Attack), low Guard.
- On landing a Bite: Wolf becomes "Emboldened" (+25% Bite damage) until Balance returns to 50 (neutral) or higher (see Threat and Balance above). _Not yet implemented._

### Dire Wolf (Prototype boss)
A boss version of the Wolf — same base template, one added ability, and a personality shift that makes it feel distinctly boss-tier rather than a reskinned trash mob.

- HP: 220 (vs. Wolf's 60)
- Bite damage: 16-24 (vs. Wolf's 8-14)
- Attack skill: 25 (vs. Wolf's 10) — noticeably harder to passively defend against
- Timings: no opening circling — engages immediately; Bite telegraph 1.2s (faster than the Wolf's 1.5s); recovery between attacks 2.5s.
- Behavior: unlike the regular Wolf, never retreats — it stays aggressive at all times.
- Defense: same baseline as Wolf (~20% innate Evasion, low Guard) — the fight is harder because of damage/HP/tempo/Howl, not because it's evasive.
- **Howl (new ability):** telegraphed 2.0s ahead ("Dire Wolf throws back its head..."). On resolving, Balance is immediately slammed to 0 — full enemy control (see Threat and Balance above — this is the mechanical embodiment of "when enemies seize Balance, they become more dangerous" from `04_Combat_Design.md`). Triggers once at the start of the fight and again the first time its HP drops below 50%.
- **Enrage (below 33% HP):** Bite damage +30%, permanently (no threshold to escape it by fleeing, since it never retreats).

## Economy
- Loot %: _TBD_
- Drop rates: _TBD_
- Crafting recipes: _TBD_

## Bastion
- Upgrade costs per tier: _TBD_

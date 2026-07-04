# Project Emberfall — Balance Bible

Last Updated: 2026-07-04

Numbers only. This document will change hundreds of times during development — never mix it with design documents.

Status: Prototype-scope combat and skill-gain numbers drafted (2026-07-04), covering Sword vs. Wolf only (per `14_Roadmap.md`). All values below are first-pass and expected to change heavily after playtesting — treat every number on this page as a placeholder that happens to be internally consistent, not a final balance pass. Everything outside Prototype scope remains TBD.

---

## Skills

### Skill Level Curve
XP required to go from skill level N to N+1: `round(20 * N^1.5)`. Grows with level so early skill-ups come fast and later ones take real investment. Skill cap: 100 (see `05_Skills_And_Progression.md` — not finalized).

### Skill Gain Bucket (see `03_Game_Systems.md` — Skill Gain)
- **Bucket cap** (per skill) = `50 + (Intellect * 5)`.
- **Intellect starting value**: 10 (flat for all new characters — no character-creation allocation yet). Starting bucket cap = 100.
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

### Stamina
- Pool: 100.
- Regen: +5 per turn by default; +10 per turn if the turn's action was Guard or Wait.
- Costs (finalized for Prototype; supersedes the directional examples previously in `04_Combat_Design.md`): Attack -10, Heavy Attack -20, Dodge -15, Parry -8, Reposition/Sprint -12.
- Low Stamina threshold: below 20, outgoing damage -25% and Guard/Parry effectiveness -25% (this is the "attacks become slower and defense weakens" pacing effect referenced in `04_Combat_Design.md`).

### Damage Formula (Prototype: Sword)
```
Attack Damage = (WeaponBaseDamage + floor(BladesSkill / 10)) x PositionModifier x VarianceRoll - EnemyDefense
```
- Sword WeaponBaseDamage: 10
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

## Enemies

### Wolf (Prototype enemy)
- HP: 60
- Bite (standard attack) damage: 8-14
- Behavior: circles for the first 2 rounds before engaging; telegraphs "Wolf lunges!" one round before a Bite; retreats below 25% HP for several rounds, re-engages if cornered (no retreat path available).
- Defense: high innate Evasion (~20% chance to avoid an incoming Attack), low Guard.
- On landing a Bite: Wolf becomes "Emboldened" (+25% Bite damage) until the player regains Initiative (see Threat and Initiative above).

### Boss (Prototype)
_Not yet chosen/statted — Roadmap calls for one boss in the Prototype; needs a specific enemy selected before it can be balanced._

## Economy
- Loot %: _TBD_
- Drop rates: _TBD_
- Crafting recipes: _TBD_

## Bastion
- Upgrade costs per tier: _TBD_

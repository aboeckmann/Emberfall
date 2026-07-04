# Project Emberfall — Skills and Progression

Last Updated: 2026-07-04

---

Skills are the primary progression system for every character. Characters become stronger by performing actions related to a skill.

Skills unlock:

- Guild membership
- Techniques
- Equipment effectiveness
- Crafting recipes
- Exploration opportunities
- Character identity

---

## Core Attributes

Unlike skills, core attributes are not trained by using them directly — they grow slowly in the background and modify how the skill system behaves rather than contributing combat power themselves. This keeps the "power comes from skills, not stats" pillar intact while still giving the skill-gain system (see `03_Game_Systems.md`) something to hang off of.

Three core attributes exist, each backing one side of the resource systems used elsewhere in the design:

### Intellect
Governs how much unconverted skill XP a character can hold before it needs to drain (see Skill Gain bucket mechanic, `03_Game_Systems.md`). Higher Intellect means longer productive play sessions before buckets fill up and stop earning.

### Vitality
Governs physical resilience: maximum HP and maximum Stamina (see `04_Combat_Design.md` — Resources). A more vital character can take more hits and act more before running out of Stamina.

### Willpower
Governs mental/magical resilience: maximum Mana and maximum Focus (see `04_Combat_Design.md` — Resources, Magic). Out of scope for the Prototype (no spellcasting weapon/enemy exists yet), but defined now so the attribute trio is consistent.

Starting values are assigned at character creation (see `03_Game_Systems.md` — Character Creation). The real assignment method (point-buy, rolled, archetype-based starting spreads, etc.) is _TBD_; the Prototype uses a fixed placeholder spread instead. Growth over time (how, or whether, these rise post-creation) is also _TBD_. First-pass starting values and the resulting pool sizes: `11_Balance_Bible.md`.

---

## Skill Categories

### Offense
Represents offensive combat ability.

**Weapon Skills:** Blades, Polearms, Axes, Bludgeons, Bows, Thrown Weapons, Unarmed, Arcane Focuses

**Combat Skills:** Precision, Presence (Threat Generation), Multi-Combat, Tempo, Tactics, Momentum

### Defense
Represents survivability and defensive combat.

**Armor Skills:** Cloth, Leather, Medium Armor, Heavy Armor, Shield Use

**Defensive Skills:** Evasion, Parry, Guard, Recovery, Composure, Obscurity (Threat Reduction)

### Survival
Represents travel and wilderness expertise.

**Travel Skills:** Navigation, Tracking, Climbing, Swimming, Mountsmanship

**Wilderness Skills:** Harvesting, Foraging, Camping, Perception, Endurance

### Magic
Magic consists of two independent systems.

**Magic Schools** (what the player can cast): Elemental, Vital, Spirit, Astral, Primal, Arcane

**Arcane Fundamentals** (how effectively the player manipulates magical energy): Attunement, Channeling, Control, Focus, Recovery, Resonance

A player's magical identity is determined by both their school proficiency and their arcane fundamentals.

### Tradecraft
Represents crafting and economic progression.

**Crafting:** Smithing, Woodcraft, Tailoring, Alchemy, Enchanting, Cooking

**Commerce:** Appraisal, Bartering, Mercantilism, Leadership, Logistics

---

## Techniques

Techniques are unlocked through combinations of skill progression and define a player's combat style and specialization. Full technique list and unlock logic: see `03_Game_Systems.md`.

---

## Systems To Define

- Skill caps (prototype assumes 0–100 per skill; not finalized)
- Mastery
- Attribute allocation method at character creation (see `03_Game_Systems.md` — Character Creation for the Prototype-minimal flow)
- Core attribute growth over time (post-creation)

Skill gain formula and the Practice system are now conceptually defined — see `03_Game_Systems.md` (Skill Gain, Practice, Rest). Numeric curves for the above belong in `11_Balance_Bible.md` once defined.

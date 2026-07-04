# Project Emberfall — Combat Design

Last Updated: 2026-07-04

---

## Combat Philosophy

Combat is designed around tactical decision making rather than fast reflexes. Players should win because they make better decisions, not because they tap faster.

Combat is a contest of positioning, timing, and momentum. Victory comes from reading the battlefield and making deliberate tactical decisions, not from rapid inputs or maximizing damage per second.

Combat Pillars:

- Positioning
- Timing
- Momentum
- Reading enemy behavior
- Resource management

Combat takes place on a small tactical battlefield rather than a large arena. The player is not running around constantly — they are managing position and making a meaningful decision every second or two, not pressing buttons 15 times per second.

---

## Positioning

The player occupies one of several positions relative to the enemy.

### Frontline
Closest.

Advantages: maximum melee damage, easier to intercept enemies, generates more threat.
Disadvantages: easier to hit, more exposed.

### Balanced
Default. Good at everything.

### Guarded
A half-step back.

Benefits: better defense, easier parries, better spell concentration.
Tradeoff: less melee damage.

### Flanking
Available against groups.

Benefits: better criticals, lower threat, better against ranged enemies.

### Rear
Only available in some encounters. Ideal for archers and casters.

---

## Combat Decisions

Every combat turn, the player makes a meaningful choice. Example prompt:

> Enemy preparing Heavy Swing...
> Options: Guard / Sidestep / Parry / Attack / Ability

Decision options include:

- Attack
- Heavy Attack
- Guard
- Parry
- Dodge
- Change Stance
- Technique
- Cast Spell

---

## Enemy Telegraphs

Enemies signal their next action instead of dealing random damage. Examples:

- "Bandit raises shield. Preparing Counterattack."
- "Ogre lifts club. Heavy Strike incoming."
- "Cultist begins chanting. Spell completes in 3 sec."

Combat becomes a loop of Observe → Respond. Players are rewarded for reacting intelligently. Telegraph types include heavy attacks, spell casting, defensive stances, and charge attacks.

---

## Weapon Feel

Different weapons change how combat feels, not just the numbers.

- **Sword** — Fast, reliable, can parry.
- **Great Axe** — Slow, massive stagger, poor defense.
- **Spear** — Keeps enemies farther away, excellent against charging foes.
- **Bow** — Cannot parry well, excellent opening attacks, needs space.

---

## Defense

Defense is a set of active choices, not a static stat. When an enemy attacks, the player chooses: Block, Parry, Dodge, or Brace. Each interacts differently with the incoming attack.

---

## Resources

### Stamina
Every physical action costs stamina — not huge amounts, just enough to matter.

Example costs:

- Attack: -10
- Heavy attack: -20
- Dodge: -15
- Parry: -8
- Sprint: -12

When stamina gets low, attacks become slower and defense weakens, which naturally paces the player.

Max HP and max Stamina are both derived from the Vitality core attribute — see `05_Skills_And_Progression.md` (Core Attributes) and `11_Balance_Bible.md` for the formula.

### Magic — Mana + Focus
Magic uses two resources instead of one, both derived from the Willpower core attribute (see `05_Skills_And_Progression.md`):

- **Mana** — the magical energy available.
- **Focus** — mental concentration.

Big spells require both. A wizard can't endlessly cast huge spells simply because their mana pool is full — if they've been interrupted, dodging, or taking hits, their Focus drops and they have to regain composure before attempting another major spell. This creates interesting decisions without copying DragonRealms' preparation mechanics.

Stamina costs/regeneration and the Sword damage formula are defined for the Prototype (Sword vs. Wolf) in `11_Balance_Bible.md`. Mana/Focus costs remain _TBD_ — no spellcasting weapon exists in Prototype scope.

---

## Balance

Balance is not "who goes first" — it's control of the fight, expressed as a single shared meter. 100 means the player is in full control, 0 means the enemy is, and every fight starts at 50: neutral, with neither side holding an advantage.

Landing attacks, parrying successfully, exploiting openings, and using smart positioning push Balance toward the player. As Balance rises, the player gains access to stronger techniques and tactical options. When enemies seize Balance (pushing it down), they become more dangerous, forcing the player onto the defensive until control is regained.

This creates a natural ebb and flow: early exchange → one side gains momentum → the other side recovers → battle swings back. It rewards skillful play rather than frantic tapping.

(This system was originally named "Initiative"; renamed 2026-07-04 — see `CHANGELOG.md`.)

---

## Enemy AI

Every enemy has a personality — a wolf shouldn't fight like a knight.

- **Wolf** — Circles, waits for openings, retreats when injured, hunts in packs.
- **Skeleton** — Never retreats, slow, predictable.
- **Duelist** — Parries often, punishes reckless attacks.
- **Ogre** — Slow, crushing attacks, breaks guard.

Players learn enemies instead of simply memorizing health bars. The Wolf is the Prototype's enemy and the Dire Wolf (a boss version of the Wolf) is the Prototype's boss (see `14_Roadmap.md`) — concrete stats and behavior for both are defined in `11_Balance_Bible.md`, and the turn-by-turn encounter loop (`game/combat/combat_encounter.gd`) implements the telegraph-then-resolve cadence described above. That implementation is a first pass: circling/retreating are plain round counters, not a spatial/cornering system, so "re-engages if cornered" is simplified to "retreat always expires," and the Wolf's Emboldened state (bonus damage after landing a Bite, until Balance returns to neutral or better) isn't implemented yet. Additional enemy personalities and full Boss AI design beyond the Dire Wolf: _TBD_.

---

## Threat

Threat generation (Presence skill) and threat reduction (Obscurity skill) exist as skill concepts — see `05_Skills_And_Progression.md`. The threat and Balance formulas are defined for the Prototype in `11_Balance_Bible.md`.

## Status Effects, Damage, Criticals, Animations

_Not yet defined._

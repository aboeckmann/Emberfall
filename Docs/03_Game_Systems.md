# Project Emberfall — Game Systems

Last Updated: 2026-07-04

Cross-cutting systems that connect the rest of the game together.

---

## Character Creation

Status: Prototype-minimal only. The full character creation experience — attribute allocation method and appearance customization — is undesigned, since both the real attribute-assignment method (`05_Skills_And_Progression.md`) and the visual style (`12_Art_Direction.md`) are still TBD. For the Prototype, creating a character involves no meaningful choices beyond naming:

1. **Name** — player enters a character name.
2. **Attributes** — fixed placeholder spread: Intellect 10, Vitality 10, Willpower 10 (see `11_Balance_Bible.md`). No allocation UI yet.
3. **Skills** — every skill starts at level 0 with an empty bucket (see Skill Gain below).
4. **Guild** — none. Guild membership requires minimum skill levels and an initiation quest (see `06_Guilds.md`), neither of which a new character can meet, so new characters start guildless and earn their first guild through play.
5. **Equipment** — auto-equipped with the Sword, the Prototype's only weapon (see `09_Economy_And_Crafting.md`). No loadout choice, since no alternative exists yet.
6. **Renown** — starts at 0.
7. **Starting location** — placed in the Bastion at its lowest tier, Ember/Campfire (see `08_Bastion_System.md`).

Future, non-Prototype: attribute allocation method (point-buy / rolled / archetype-based spreads), appearance customization, any starting narrative/tutorial framing.

## Renown

Renown represents a character's accomplishments and reputation throughout the world.

Renown unlocks:

- Guild eligibility
- New regions
- Story progression
- Bastion upgrades
- Advanced equipment

Formula/curve for how Renown is earned: _TBD — see 11_Balance_Bible.md._

---

## Techniques

Techniques are unlocked through combinations of skill progression. They define a player's combat style and specialization.

Examples:

- Blade + Tempo → Sweeping Assault
- Shield + Guard → Bastion Stance
- Elemental + Channeling → Convergent Flame
- Tracking + Precision → Hunter's Mark

Full technique list and unlock requirements: _TBD._

---

## Skill Gain

Every action relevant to a skill grants a small amount of XP, sized to the difficulty of the action. That XP does not apply to the skill directly — it fills a **skill-specific bucket**. The bucket has a maximum size, set by the character's Intellect (see `05_Skills_And_Progression.md` — Core Attributes). Bucket contents drain over time and convert into real skill XP; skill levels themselves require progressively more XP to reach (curve in `11_Balance_Bible.md`).

Why a bucket instead of direct XP: it decouples "doing the action" from "getting stronger from it," which creates the training rhythm the game is built around — go out and fight (fill buckets), then come home and rest (drain them faster) — without hard-capping how much a player can *do* in a session. A full bucket doesn't block further actions, it just stops earning until it drains some.

Bucket drain happens everywhere, slowly, at all times (see Rest below for the accelerated case). Concrete drain rates, bucket cap formula, and per-action XP values: `11_Balance_Bible.md`.

## Practice

Practice is the non-combat counterpart to the Skill Gain loop above: training dummies, sparring partners, and drills (typically found at the Bastion or with guild trainers) that fill a skill's bucket without the risk of real combat. It is intentionally the same bucket mechanism as combat — Practice just offers a safer, slower way to fill it. Available practice activities per skill/guild: _TBD._

## Rest

Resting — primarily at the Bastion (see `08_Bastion_System.md`) — accelerates bucket drain. Bucket XP converts to real skill XP everywhere, all the time, but resting at the Bastion multiplies that rate. This gives Rest a concrete mechanical payoff and reinforces the Bastion as the place players return to in order to lock in progress made out in the world. Exact drain multiplier: `11_Balance_Bible.md`.

## Persistence

_Not yet defined._ Save data architecture belongs in `02_Technical_Design_Document.md`.

## Unlock Systems

_Not yet defined._ (Renown- and skill-gated unlocks exist conceptually — see above and `05_Skills_And_Progression.md` — but no unified unlock framework has been designed.)

## Daily Resets

_Not yet defined._

## Fast Travel

_Not yet defined._ See `07_World_Design.md`.

## Death

_Not yet defined._

## Respawn

_Not yet defined._

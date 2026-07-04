# Project Emberfall — Game Design Document

Author: Adam Boeckmann
Date: May 22, 2026
Last Updated: 2026-07-04

This is the master/executive-summary document. It answers *why* each system exists. Implementation details, formulas, and numbers live in the linked documents, not here.

---

## Vision and Core Philosophy

A mobile-first fantasy RPG inspired by the feeling of old-school MUDs and classic RPG progression while embracing modern accessibility.

Players create a single persistent character that grows through actions, choices, training, and exploration.

This is not a hero collection game. This is not pay-to-win.

The goal is to create a world where players become emotionally invested in their character over months or years.

Full detail: `00_Project_Vision.md`

### Design Pillars

- One persistent character
- Train what you use
- Meaningful progression
- Deliberate tactical combat
- Exploration and discovery
- Player identity over character collection

---

## Character Progression (Overview)

Characters do not gain traditional levels as their primary source of power. Power comes from developing skills through use.

Examples:

- Fight with swords → improve sword skill
- Cast magic → improve magical abilities
- Explore the wilderness → improve survival skills
- Craft equipment → improve trade skills

Characters also earn **Renown**, representing their accomplishments and reputation throughout the world. Renown unlocks guild eligibility, new regions, story progression, Bastion upgrades, and advanced equipment.

Full detail: `05_Skills_And_Progression.md` (skills), `03_Game_Systems.md` (Renown)

---

## Equipment (Overview)

Equipment may occupy multiple slots (e.g., a Greatsword occupies Right Hand + Left Hand). Equipment has two independent components: Gameplay Data (stats, properties, bonuses, durability — TBD) and Appearance Data (equipment type, material, color palette, ornament layer), which allows thousands of visual combinations while keeping the art pipeline manageable.

Full detail: `09_Economy_And_Crafting.md`

---

## Skills (Overview)

Skills are the primary progression system for every character. Characters become stronger by performing actions related to a skill. Skills unlock guild membership, techniques, equipment effectiveness, crafting recipes, exploration opportunities, and character identity.

Categories: Offense, Defense, Survival, Magic, Tradecraft.

Full detail: `05_Skills_And_Progression.md`

---

## Guilds (Overview)

Players do not begin in a guild. Guilds represent long-term training philosophies rather than permanent character classes. Guilds require minimum skill levels and initiation quests. Players begin with one active guild; additional guilds may unlock later through progression.

Initial guild concepts: Ironbound, Wildpath, Dawnwardens, Veilcasters, Ashborn, Lantern Covenant, Stormkin, Silent Hand.

Full detail: `06_Guilds.md`

---

## Combat (Overview)

Combat is designed around tactical decision making rather than fast reflexes. Players should win because they make better decisions, not because they tap faster.

Combat pillars: Positioning, Timing, Momentum, Reading enemy behavior, Resource management.

> "Combat in Emberfall is a contest of positioning, timing, and momentum. Victory comes from reading the battlefield and making deliberate tactical decisions, not from rapid inputs or maximizing damage per second."

Full detail: `04_Combat_Design.md`

---

## Bastion (Overview)

Every player owns a personal Bastion — their home, which grows alongside the character. Players begin with almost nothing and progress from Ember (Campfire) up through Citadel. The Bastion provides resting, skill progression, crafting, storage, trophy displays, guild facilities, and future customization.

Full detail: `08_Bastion_System.md`

---

## World Structure (Overview)

The world consists of two connected components: the Personal Bastion (private progression space) and the Adventure World (shared regional world). Players travel between regions rather than freely exploring an open world. Regions contain towns, dungeons, bosses, hidden discoveries, guild halls, and quests.

Full detail: `07_World_Design.md`

---

## Open Systems Tracker

Systems referenced in design discussion but not yet fully defined. Tracked here so nothing gets lost; detail work happens in the linked doc, not in this file.

| System | Lives In | Status |
|---|---|---|
| Skill formulas, mastery, skill caps, practice system | 05_Skills_And_Progression.md / 11_Balance_Bible.md | Partial — bucket-based skill gain + Prototype curve defined; mastery/caps still TBD |
| Damage formulas, threat generation, criticals, status effects | 04_Combat_Design.md / 11_Balance_Bible.md | Partial — Sword vs. Wolf/Dire Wolf fully defined for Prototype; status effects still TBD |
| Enemy AI (beyond the four personality examples) | 04_Combat_Design.md | Partial — Wolf + Dire Wolf (boss) defined for Prototype |
| Character creation: attribute assignment method, attribute growth over time | 05_Skills_And_Progression.md | TBD — placeholder flat starting values in use for Prototype dev |
| Discovery, fast travel, hidden locations | 07_World_Design.md | TBD |
| Loot generation, vendors, crafting, trading | 09_Economy_And_Crafting.md | TBD |
| Async interactions, guild systems, social features | 03_Game_Systems.md | TBD |
| Tech stack, backend architecture, coding standards | 02_Technical_Design_Document.md | Partial — stack decided (Godot 4.x); backend deferred; standards partial |

## Appendix

Placeholder sections removed from original template: Origin of Birds, Example charts, Bibliography examples.

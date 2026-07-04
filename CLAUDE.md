# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

Emberfall is a mobile-first fantasy RPG. Design work happens in `Docs/`; the game itself is a **Godot 4.x** project scaffolded at the repo root (`project.godot`, `game/`, `scenes/`, `ui/`, `assets/`, `data/`, `tests/` — see `02_Technical_Design_Document.md` for what each folder is for). As of this scaffold there is no gameplay code yet, just the empty folder structure and a placeholder `scenes/Main.tscn`. Godot is not installed in this environment — there is no CLI build/lint/test command to run yet; opening/running the project requires the Godot 4.x editor.

**The load-bearing rule**: game rules (combat math, skill gain, saves — anything in `11_Balance_Bible.md`) must live in `game/` as engine-agnostic GDScript with no scene/node/rendering/input dependencies. Scenes (`scenes/`, `ui/`) consume that layer; they never implement rules. This is what keeps the Balance Bible's formulas testable headlessly and the engine swappable if Godot is ever outgrown.

Design documents in `Docs/` remain the source of truth for what to build — read the relevant doc(s) before implementing a system, since numbers live only in `11_Balance_Bible.md` and lore/content only in `10_Content_Bible.md` (see Document Architecture below).

## Document Architecture

The docs form a deliberately layered system — each doc has a specific altitude, and content should stay at the altitude it belongs to rather than sprawl into neighboring docs:

- **`00_Project_Vision.md`** — top-level philosophy and pillars. Should change rarely; if you're editing it often, the change belongs in `01_Game_Design_Document.md` instead.
- **`01_Game_Design_Document.md`** — master/executive-summary doc. Explains *why* each system exists in a few paragraphs and links out to the detail doc. Implementation details, formulas, and numbers do NOT belong here. It also carries the "Open Systems Tracker" table, which is the source of truth for what's designed vs. still TBD and which doc owns each undesigned system.
- **`02_Technical_Design_Document.md`** — where implementation detail (algorithms, formulas, data structures, tech stack, coding standards) belongs once it exists. Currently a skeleton.
- **`03_Game_Systems.md`** — cross-cutting systems that connect other systems together (Renown, Techniques, Practice, Rest, Persistence, Unlocks, Death, etc.).
- **`04_Combat_Design.md`** through **`09_Economy_And_Crafting.md`** — detailed design for one subsystem each (Combat, Skills/Progression, Guilds, World, Bastion, Economy/Crafting).
- **`10_Content_Bible.md`** — the world's encyclopedia: NPCs, enemies, bosses, regions, lore, factions, quests, dialogue. Content, not systems.
- **`11_Balance_Bible.md`** — **numbers only**. This doc is expected to change constantly during development and must never be mixed with design prose in the other docs. Any stamina cost, XP curve, drop rate, or similar numeric value that shows up in a design doc as an example should be flagged `TBD` there and the real value tracked here.
- **`12_Art_Direction.md`**, **`13_UI_UX.md`** — visual style and interface design. Not yet started.
- **`14_Roadmap.md`** — milestone definitions (Prototype → Vertical Slice → Alpha → Beta → 1.0 → Post-Launch). New feature ideas should be evaluated against the current milestone rather than added speculatively.
- **`CHANGELOG.md`** — every major *design decision* (not code change) gets recorded here with a reason, most recent first.

### Conventions to follow when editing docs

- **Numbers live only in `11_Balance_Bible.md`.** If a design doc needs an illustrative number, mark it clearly as a directional example (see the stamina cost note in `04_Combat_Design.md`) and leave the authoritative value TBD, tracked in the Balance Bible.
- **Content (lore, NPCs, bestiary entries) lives only in `10_Content_Bible.md`**, even if a system doc references the concept (e.g., `04_Combat_Design.md` defines enemy AI archetypes like Wolf/Skeleton/Duelist/Ogre, but their lore/names belong in the Content Bible).
- **Cross-reference instead of duplicating.** Docs consistently link to each other with backtick-quoted filenames (e.g., "Full detail: `05_Skills_And_Progression.md`") rather than repeating content. Follow this pattern when adding overview material that has a fuller home elsewhere.
- **Undesignated systems are marked `_Not yet defined._` or `_TBD_`**, often with a one-line note on which doc will eventually own them. When fleshing out a system, replace the placeholder in place rather than leaving stale TBD markers, and update the Open Systems Tracker table in `01_Game_Design_Document.md` if the system is listed there.
- **Record design decisions in `CHANGELOG.md`** when they represent a meaningful direction change (e.g., "changed combat from free movement to tactical positioning"), with a brief Reason line — not routine typo/wording fixes.
- Every doc carries a `Last Updated:` date near the top — update it when making substantive edits to that doc.

## Core Design Pillars (for consistency when extending design docs)

These are established and should anchor any new design content:

- One persistent character (no hero-collection/gacha mechanics, no pay-to-win)
- Skills grow through use ("train what you use"), not through a leveling timer
- Deliberate, tactical combat: positioning/timing/momentum over fast reflexes or DPS-maximizing
- Renown (accomplishment/reputation) gates guilds, regions, story, Bastion upgrades, and equipment
- Guilds are training philosophies players opt into after meeting skill + quest requirements, not fixed starting classes
- The world is split into the private, progressing Bastion (player home, Ember → Citadel tiers) and the shared Adventure World (region-to-region travel, not open-world)
- Equipment separates Gameplay Data (stats) from Appearance Data (type/material/palette/ornament), enabling large visual variety from a small asset pipeline

# Project Emberfall — UI/UX

Last Updated: 2026-07-04

Status: a functional (deliberately unstyled) Combat HUD exists for the Prototype — see below. Everything else is a placeholder. No UI *design* work has happened; the existing screen is a functional scaffold awaiting Art Direction (`12_Art_Direction.md`) and a real UI/UX pass.

---

## Menus
_Not yet defined._

## HUD
_Not yet defined._

## Inventory
_Not yet defined._

## Combat HUD
A functional first version exists (`scenes/combat/combat_screen.tscn` + `.gd`): portrait 720x1280, Container-based layout, default Godot theme. It surfaces enemy name/HP/telegraph, a scrolling combat log, player HP/Stamina bars plus the shared Balance meter (starts at 50/neutral; labeled with who holds the advantage), position buttons (Frontline/Balanced/Guarded only — Flanking needs groups and Rear is encounter-specific, neither of which exists in the single-enemy Prototype), and the five action buttons (Attack/Heavy/Guard/Parry/Dodge). Mana/Focus are not shown — no caster exists in Prototype scope. This is a scaffold to playtest the combat loop, not a designed HUD; visual design is TBD pending `12_Art_Direction.md`.

## Skill Tree
_Not yet defined._

## Guild Screen
_Not yet defined._

## Map
_Not yet defined._

## Settings
_Not yet defined._

## Wireframes
_Not yet defined._

## Navigation Flow
_Not yet defined._

## Accessibility
_Not yet defined._

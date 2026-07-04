# Project Emberfall — Economy and Crafting

Last Updated: 2026-07-04

---

## Equipment

Equipment may occupy multiple slots.

Examples:

- Greatsword → Right Hand + Left Hand
- Full Plate Armor → Chest + Legs

Equipment contains two independent components:

### Gameplay Data
- Stats
- Properties
- Bonuses
- Durability (TBD)

Concrete schema (field names/types) and the Prototype's Sword instance: `02_Technical_Design_Document.md` (Data Schemas) and `11_Balance_Bible.md`.

### Appearance Data
Appearance is generated from reusable visual templates, consisting of:

- Equipment Type
- Material
- Color Palette
- Ornament Layer

This allows thousands of visual combinations while keeping the art pipeline manageable. Visual style rules: see `12_Art_Direction.md`. Schema: `02_Technical_Design_Document.md` (Data Schemas) — currently just Equipment Type is populated for the Prototype's Sword; Material/Color Palette/Ornament Layer await Art Direction.

### Equipment Slots

**Weapon Slots:** Right Hand, Left Hand, Ranged

**Armor Slots:** Chest, Legs, Hands, Head, Feet

**Adventuring Slots:** Back, Backpack, Ring 1, Ring 2, Necklace, Belt

Weapons and armor contain gameplay properties that determine combat effectiveness (see `04_Combat_Design.md`).

---

## Backpack

Backpack inventory system: _details TBD._

---

## Systems To Define

- Currencies
- Loot
- Drops
- Crafting (recipes tie to Tradecraft skills — see `05_Skills_And_Progression.md`)
- Resources
- Gathering
- Merchants
- Repair
- Durability
- Trading
- Marketplace
- Premium Store

Numeric values (drop rates, costs, recipe requirements) belong in `11_Balance_Bible.md` once defined, not here.

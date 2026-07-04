# Project Emberfall — Changelog

Every major design decision gets recorded here.

---

## 2026-07-04

**Chose the tech stack: Godot 4.x + GDScript, local JSON saves for the Prototype, backend deferred.**
Reason: Emberfall is a UI-heavy 2D tactical RPG and Godot's 2D/UI tooling is first-class; GDScript is the fastest ramp for a scripting background; free and lightweight. Unity's advantages (3D pipeline, mobile LiveOps ecosystem) aren't needed yet. Backend (PlayFab vs Firebase vs custom) is deliberately deferred until a milestone needs server-authoritative progression. Adopted a standing architecture rule: game rules never call engine APIs, keeping formulas headless-testable and the engine swappable. See `02_Technical_Design_Document.md`.

**Changed combat from free movement to tactical positioning.**
Reason: Better supports deliberate gameplay — players win by making better decisions, not by moving/tapping faster.

**Split the single GDD into a modular `/Docs` structure (00–14 + Changelog).**
Reason: The master document was becoming unwieldy — it mixed stable vision content with fast-changing balance numbers and unwritten content/tech sections. Splitting keeps `01_Game_Design_Document.md` stable while `11_Balance_Bible.md` and `10_Content_Bible.md` can change constantly without touching the rest.

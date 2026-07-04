class_name EnemyIntent
extends RefCounted
## The enemy's telegraphed intent for the current round. TELEGRAPHING_* states
## resolve into their real counterpart (BITE/HOWL) exactly one round later --
## see Docs/04_Combat_Design.md's "Observe -> Respond" telegraph loop and
## Docs/11_Balance_Bible.md ("telegraphed one round ahead").

enum Intent { CIRCLING, TELEGRAPHING_BITE, BITE, RETREATING, TELEGRAPHING_HOWL, HOWL }

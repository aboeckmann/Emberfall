class_name EquipmentData
extends Resource
## Base equipment record. See Docs/09_Economy_And_Crafting.md, 02_Technical_Design_Document.md.
## Durability is TBD -- not implemented for the Prototype.

@export var id: String = ""
@export var display_name: String = ""
@export var slots_occupied: PackedInt32Array = PackedInt32Array()  # EquipmentSlot.Slot values
@export var appearance: AppearanceData

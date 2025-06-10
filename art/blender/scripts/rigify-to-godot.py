# Rename Mixamo action groups and curves to Rigify deform bones (DEF-xxx) format.
import bpy
import re

REPARENT_BONE_MAP = {
    "DEF-breast.L": "DEF-spine.003",
    "DEF-breast.R": "DEF-spine.003",
    "DEF-shoulder.L": "DEF-spine.003",
    "DEF-shoulder.R": "DEF-spine.003",
    "DEF-upper_arm.L": "DEF-shoulder.L",
    "DEF-upper_arm.R": "DEF-shoulder.R",
    "DEF-pelvis.L": "DEF-spine",
    "DEF-pelvis.R": "DEF-spine",
    "DEF-thigh.L": "DEF-spine",
    "DEF-thigh.R": "DEF-spine",
}

RENAME_BONE_MAP = {
    "DEF-spine": "Hips",
    "DEF-spine.001": "Spine",
    "DEF-spine.002": "Chest",
    "DEF-spine.003": "UpperChest",
    "DEF-spine.004": "Neck",
    "DEF-spine.006": "Head",
    "DEF-shoulder.L": "LeftShoulder",
    "DEF-upper_arm.L": "LeftUpperArm",
    "DEF-forearm.L": "LeftLowerArm",
    "DEF-hand.L": "LeftHand",
    "DEF-shoulder.R": "RightShoulder",
    "DEF-upper_arm.R": "RightUpperArm",
    "DEF-forearm.R": "RightLowerArm",
    "DEF-hand.R": "RightHand",
    "DEF-thigh.L": "LeftUpperLeg",
    "DEF-shin.L": "LeftLowerLeg",
    "DEF-foot.L": "LeftFoot",
    "DEF-toe.L": "LeftToes",
    "DEF-thigh.R": "RightUpperLeg",
    "DEF-shin.R": "RightLowerLeg",
    "DEF-foot.R": "RightFoot",
    "DEF-toe.R": "RightToes",
}

def adjust_bones(armature) -> None:
    bpy.ops.object.mode_set(mode='EDIT')
    edit_bones = armature.data.edit_bones

    # Set parents
    for bone_name, parent_name in REPARENT_BONE_MAP.items():
        if bone_name in edit_bones and parent_name in edit_bones:
            print(f"Set parent: {bone_name} -> {parent_name}")
            # edit_bones[bone_name].parent = edit_bones[parent_name]

    # Rename bones
    for bone_name, new_name in RENAME_BONE_MAP.items():
        if bone_name in edit_bones:
            print(f"Renamed: {bone_name} -> {new_name}")
            # edit_bones[bone_name].name = new_name

def main():
    print("Rigify to Godot")

    armature = bpy.context.active_object

    if not armature or armature.type != 'ARMATURE':
        print("No armature selected or active object is not an armature.")
        return

    adjust_bones(armature)

main()
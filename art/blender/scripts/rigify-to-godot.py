# Rename Mixamo action groups and curves to Rigify deform bones (DEF-xxx) format.
import bpy
import re
from bpy.types import Armature, BoneCollection

REPARENT_BONE_MAP = {
    "TGT-breast.L": "TGT-spine.003",
    "TGT-breast.R": "TGT-spine.003",
    "TGT-shoulder.L": "TGT-spine.003",
    "TGT-shoulder.R": "TGT-spine.003",
    "TGT-upper_arm.L": "TGT-shoulder.L",
    "TGT-upper_arm.R": "TGT-shoulder.R",
    "TGT-pelvis.L": "TGT-spine",
    "TGT-pelvis.R": "TGT-spine",
    "TGT-thigh.L": "TGT-spine",
    "TGT-thigh.R": "TGT-spine",
}

COPY_BONE_MAP = {
    "DEF-spine.007": "TGT-spine",
    "DEF-spine.008": "TGT-spine.001",
    "DEF-spine.009": "TGT-spine.002",
    "DEF-spine.010": "TGT-spine.003",
    "DEF-spine.011": "TGT-spine.004",
    "DEF-spine.012": "TGT-spine.005",
    "DEF-spine.013": "TGT-spine.006",
    "DEF-pelvis.L.001": "TGT-pelvis.L",
    "DEF-pelvis.R.001": "TGT-pelvis.R",
    "DEF-thigh.L.002": "TGT-thigh.L",
    "DEF-thigh.L.003": "TGT-thigh.L.001",
    "DEF-shin.L.002": "TGT-shin.L",
    "DEF-shin.L.003": "TGT-shin.L.001",
    "DEF-foot.L.001": "TGT-foot.L",
    "DEF-toe.L.001": "TGT-toe.L",
    "DEF-thigh.R.002": "TGT-thigh.R",
    "DEF-thigh.R.003": "TGT-thigh.R.001",
    "DEF-shin.R.002": "TGT-shin.R",
    "DEF-shin.R.003": "TGT-shin.R.001",
    "DEF-foot.R.001": "TGT-foot.R",
    "DEF-toe.R.001": "TGT-toe.R",
    "DEF-shoulder.L.001": "TGT-shoulder.L01",
    "DEF-upper_arm.L.002": "TGT-upper_arm.L",
    "DEF-upper_arm.L.003": "TGT-upper_arm.L.001",
    "DEF-forearm.L.002": "TGT-forearm.L",
    "DEF-forearm.L.003": "TGT-forearm.L.001",
    "DEF-hand.L.001": "TGT-hand.L",
    "DEF-shoulder.R.001": "TGT-shoulder.R",
    "DEF-upper_arm.R.002": "TGT-upper_arm.R",
    "DEF-upper_arm.R.003": "TGT-upper_arm.R.001",
    "DEF-forearm.R.002": "TGT-forearm.R",
    "DEF-forearm.R.003": "TGT-forearm.R.001",
    "DEF-hand.R.001": "TGT-hand.R",
    "DEF-breast.L.001": "TGT-breast.L",
    "DEF-breast.R.001": "TGT-breast.R"
}

RENAME_BONE_MAP = {
    "TGT-spine": "Hips",
    "TGT-spine.001": "Spine",
    "TGT-spine.002": "Chest",
    "TGT-spine.003": "UpperChest",
    "TGT-spine.004": "Neck",
    "TGT-spine.006": "Head",
    "TGT-shoulder.L": "LeftShoulder",
    "TGT-upper_arm.L": "LeftUpperArm",
    "TGT-forearm.L": "LeftLowerArm",
    "TGT-hand.L": "LeftHand",
    "TGT-shoulder.R": "RightShoulder",
    "TGT-upper_arm.R": "RightUpperArm",
    "TGT-forearm.R": "RightLowerArm",
    "TGT-hand.R": "RightHand",
    "TGT-thigh.L": "LeftUpperLeg",
    "TGT-shin.L": "LeftLowerLeg",
    "TGT-foot.L": "LeftFoot",
    "TGT-toe.L": "LeftToes",
    "TGT-thigh.R": "RightUpperLeg",
    "TGT-shin.R": "RightLowerLeg",
    "TGT-foot.R": "RightFoot",
    "TGT-toe.R": "RightToes",
}

def deselect_all_bones(armature_data: Armature) -> None:
    bpy.ops.object.mode_set(mode="OBJECT")

    for bone in armature_data.bones:
        bone.select = False
        bone.select_head = False
        bone.select_tail = False

    bpy.ops.object.mode_set(mode="EDIT")

    for edit_bone in armature_data.edit_bones:
        edit_bone.select = False
        edit_bone.select_head = False
        edit_bone.select_tail = False

def prepare_groups(armature_data: Armature) -> tuple[BoneCollection, BoneCollection]:
    deselect_all_bones(armature_data)

    bpy.ops.object.mode_set(mode="OBJECT")

    def_group = None
    tgt_group = None

    # Find existing DEF and TGT groups
    for group in armature_data.collections:
        if group.name == "DEF":
            def_group = group
        elif group.name == "TGT":
            tgt_group = group

    if def_group is None:
        assert isinstance(def_group, BoneCollection), "No DEF bone collection found"

    if tgt_group is None:
        print("Creating TGT group.")
        tgt_group = armature_data.collections.new("TGT")

    for bone in tgt_group.bones:
        print(f"Removing bone from TGT group: {bone.name}")
        bone.select = True

    bpy.ops.object.mode_set(mode="EDIT")

    # Remove any existing TGT bones
    bpy.ops.armature.delete()

    return def_group, tgt_group

def create_tgt_bones(armature_data: Armature, def_group: BoneCollection, tgt_group: BoneCollection) -> None:
    bpy.ops.object.mode_set(mode="OBJECT")

    # Copy bones since we can't access group.bones once we switch to edit mode
    def_bones = [b for b in def_group.bones]
    for bone in def_bones:
        print(f"Bone: {bone.name}")
        bone.select = True

    bpy.ops.object.mode_set(mode="EDIT")

    bpy.ops.armature.duplicate()

    edit_bones = armature_data.edit_bones

    # Only new bones should remain selected after duplication.
    # Adjust names to match the TGT naming convention.
    for bone in [b for b in edit_bones if b.select and b.name in COPY_BONE_MAP]:
        bone.name = COPY_BONE_MAP[bone.name]
        tgt_group.assign(bone)
        print("Created TGT bone: ", bone.name)

    # Not all of the original DEF- bones are properly parented in Rigify, so fix
    # the TGT versions.
    for bone_name, parent_name in REPARENT_BONE_MAP.items():
        if bone_name in edit_bones and parent_name in edit_bones:
            print(f"Set parent: {bone_name} -> {parent_name}")
            edit_bones[bone_name].parent = edit_bones[parent_name]

def adjust_bones(armature) -> None:
    def_group, tgt_group = prepare_groups(armature.data)
    create_tgt_bones(armature.data, def_group, tgt_group)

    # Rename bones (TBD if I want to do this for Godot)
    # for bone_name, new_name in RENAME_BONE_MAP.items():
    #     if bone_name in edit_bones:
    #         print(f"Renamed: {bone_name} -> {new_name}")
    #         # edit_bones[bone_name].name = new_name

def main():
    print("Rigify to Godot")

    armature = bpy.context.active_object

    if not armature or armature.type != "ARMATURE":
        print("No armature selected or active object is not an armature.")
        return

    adjust_bones(armature)

main()
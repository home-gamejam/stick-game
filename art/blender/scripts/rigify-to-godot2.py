# Rename Mixamo action groups and curves to Rigify deform bones (DEF-xxx) format.
import bpy
import re
from bpy.types import Armature, BoneCollection, Pose

REPARENT_BONE_MAP = {
    "LeftBreast": "UpperChest",
    "RightBreast": "UpperChest",
    "LeftShoulder": "UpperChest",
    "RightShoulder": "UpperChest",
    "LeftUpperArm": "LeftShoulder",
    "RightUpperArm": "RightShoulder",
    "LeftPelvis": "Hips",
    "RightPelvis": "Hips",
    "LeftUpperLeg": "Hips",
    "RightUpperLeg": "Hips",
}

RENAME_BONE_MAP = {
    "DEF-spine": "Hips",
    "DEF-spine.001": "Spine",
    "DEF-spine.002": "Chest",
    "DEF-spine.003": "UpperChest",
    "DEF-spine.004": "Neck",
    "DEF-spine.005": "Neck2",
    "DEF-spine.006": "Head",
    # Left arm
    "DEF-shoulder.L": "LeftShoulder",
    "DEF-upper_arm.L": "LeftUpperArm",
    "DEF-upper_arm.L.001": "LeftUpperArm2",
    "DEF-forearm.L": "LeftLowerArm",
    "DEF-forearm.L.001": "LeftLowerArm2",
    "DEF-hand.L": "LeftHand",
    # Right arm
    "DEF-shoulder.R": "RightShoulder",
    "DEF-upper_arm.R": "RightUpperArm",
    "DEF-upper_arm.R.001": "RightUpperArm2",
    "DEF-forearm.R": "RightLowerArm",
    "DEF-forearm.R.001": "RightLowerArm2",
    "DEF-hand.R": "RightHand",
    # Breasts
    "DEF-breast.L": "LeftBreast",
    "DEF-breast.R": "RightBreast",
    # Pelvis
    "DEF-pelvis.L": "LeftPelvis",
    "DEF-pelvis.R": "RightPelvis",
    # Left leg
    "DEF-thigh.L": "LeftUpperLeg",
    "DEF-thigh.L.001": "LeftUpperLeg2",
    "DEF-shin.L": "LeftLowerLeg",
    "DEF-shin.L.001": "LeftLowerLeg2",
    "DEF-foot.L": "LeftFoot",
    "DEF-toe.L": "LeftToes",
    # Right leg
    "DEF-thigh.R": "RightUpperLeg",
    "DEF-thigh.R.001": "RightUpperLeg2",
    "DEF-shin.R": "RightLowerLeg",
    "DEF-shin.R.001": "RightLowerLeg2",
    "DEF-foot.R": "RightFoot",
    "DEF-toe.R": "RightToes",
}

def main():
    print("Rigify to Godot")

    armature = bpy.context.active_object

    if not armature or armature.type != "ARMATURE" or not isinstance(armature.data, Armature):
        print("No armature selected or active object is not an armature.")
        return

    assert bpy.context.collection is not None, "No active collection found."

    bpy.ops.object.mode_set(mode="OBJECT")

    # Create a new target armature
    target_armature_data = bpy.data.armatures.new(f"{armature.data.name}.target")
    target_armature = bpy.data.objects.new(f"{armature.name}.target", target_armature_data)
    bpy.context.collection.objects.link(target_armature)

    # Extract names while in OBJECT mode since collection bones are not
    # accessible in EDIT mode
    def_names = [b.name for b in armature.data.collections["DEF"].bones]

    # Select the object
    bpy.ops.object.select_all(action='DESELECT')
    target_armature.select_set(True)

    bpy.ops.object.mode_set(mode="EDIT")

    def_bones = [b for b in armature.data.edit_bones if b.name in def_names]

    tgt_edit_bones = target_armature_data.edit_bones

    for def_bone in def_bones:
        new_name = RENAME_BONE_MAP[def_bone.name] if def_bone.name in RENAME_BONE_MAP else def_bone.name
        print("TGT bone: ", new_name)
        tgt_bone = tgt_edit_bones.new(new_name)
        tgt_bone.head = def_bone.head
        tgt_bone.tail = def_bone.tail
        tgt_bone.roll = def_bone.roll

    # Not all of the original DEF- bones are properly parented in Rigify, so fix
    # the TGT versions.
    for bone_name, parent_name in REPARENT_BONE_MAP.items():
        if bone_name in tgt_edit_bones and parent_name in tgt_edit_bones:
            print(f"Set parent: {bone_name} -> {parent_name}")
            tgt_edit_bones[bone_name].parent = tgt_edit_bones[parent_name]

    bpy.ops.object.mode_set(mode="OBJECT")

main()
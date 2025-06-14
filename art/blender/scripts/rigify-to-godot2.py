# Rename Mixamo action groups and curves to Rigify deform bones (DEF-xxx) format.
import bpy
import re
from bpy.types import Armature, BoneCollection, Pose

RENAME_BONE_MAP = {
    "root": "Root",

    # Spine
    "DEF-spine": "Hips",
    "DEF-spine.001": "Spine",
    "DEF-spine.002": "Chest",
    "DEF-spine.003": "UpperChest",
    "DEF-spine.004": "Neck",
    "DEF-spine.005": "Neck2",
    "DEF-spine.006": "Head",

    # Breasts
    "DEF-breast.L": "LeftBreast",
    "DEF-breast.R": "RightBreast",

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

PARENT_BONE_MAP = {
    # Spine chain
    "Hips": "Root",
    "Spine": "Hips",
    "Chest": "Spine",
    "UpperChest": "Chest",
    "Neck": "UpperChest",
    "Neck2": "Neck",
    "Head": "Neck2",

    # Breasts
    "LeftBreast": "UpperChest",
    "RightBreast": "UpperChest",

    # Arms
    "LeftShoulder": "UpperChest",
    "LeftUpperArm": "LeftShoulder",
    "LeftUpperArm2": "LeftUpperArm",
    "LeftLowerArm": "LeftUpperArm2",
    "LeftLowerArm2": "LeftLowerArm",
    "LeftHand": "LeftLowerArm2",

    "RightShoulder": "UpperChest",
    "RightUpperArm": "RightShoulder",
    "RightUpperArm2": "RightUpperArm",
    "RightLowerArm": "RightUpperArm2",
    "RightLowerArm2": "RightLowerArm",
    "RightHand": "RightLowerArm2",

    # Pelvis
    "LeftPelvis": "Hips",
    "RightPelvis": "Hips",

    # Legs
    "LeftUpperLeg": "Hips",
    "LeftUpperLeg2": "LeftUpperLeg",
    "LeftLowerLeg": "LeftUpperLeg2",
    "LeftLowerLeg2": "LeftLowerLeg",
    "LeftFoot": "LeftLowerLeg2",
    "LeftToes": "LeftFoot",

    "RightUpperLeg": "Hips",
    "RightUpperLeg2": "RightUpperLeg",
    "RightLowerLeg": "RightUpperLeg2",
    "RightLowerLeg2": "RightLowerLeg",
    "RightFoot": "RightLowerLeg2",
    "RightToes": "RightFoot",
}

def main():
    print("Rigify to Godot")

    armature = bpy.context.active_object

    assert armature is not None, "No active object found."
    assert armature.type == "ARMATURE", "Active object is not an armature."
    assert isinstance(armature.data, Armature), "Active object data is not an Armature."
    assert bpy.context.view_layer is not None, "No active view layer found."
    assert bpy.context.collection is not None, "No active collection found."

    bpy.ops.object.mode_set(mode="OBJECT")

    # Create a new target armature
    target_armature_data = bpy.data.armatures.new(f"{armature.data.name}.target")
    target_armature = bpy.data.objects.new(f"{armature.name}.target", target_armature_data)
    bpy.context.collection.objects.link(target_armature)

    bpy.ops.object.mode_set(mode="EDIT")
    source_bones = [b for b in armature.data.edit_bones if b.name in RENAME_BONE_MAP.keys()]
    bpy.ops.object.mode_set(mode="OBJECT")

    # Deselect the source armature
    bpy.ops.object.select_all(action='DESELECT')
    bpy.context.view_layer.objects.active = None

    # Select the target armature
    target_armature.select_set(True)
    bpy.context.view_layer.objects.active = target_armature

    bpy.ops.object.mode_set(mode="EDIT")
    tgt_edit_bones = target_armature_data.edit_bones

    # Copy bones to target armature
    for def_bone in source_bones:
        new_name = RENAME_BONE_MAP[def_bone.name] if def_bone.name in RENAME_BONE_MAP else def_bone.name
        print("TGT bone: ", new_name)
        tgt_bone = tgt_edit_bones.new(new_name)
        tgt_bone.head = def_bone.head
        tgt_bone.tail = def_bone.tail
        tgt_bone.roll = def_bone.roll

    # Set target bone parents
    for bone_name, parent_name in PARENT_BONE_MAP.items():
        if bone_name in tgt_edit_bones and parent_name in tgt_edit_bones:
            print(f"Set parent: {bone_name} -> {parent_name}")
            tgt_edit_bones[bone_name].parent = tgt_edit_bones[parent_name]

    bpy.ops.object.mode_set(mode="OBJECT")

main()
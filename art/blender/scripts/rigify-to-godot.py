import bpy
import re
from bpy.types import Armature, BoneCollection, CopyLocationConstraint, CopyRotationConstraint
from typing import cast

RIGIFY_RENAME_BONE_MAP = {
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

    # Arms
    "DEF-shoulder.L": "LeftShoulder",
    "DEF-upper_arm.L": "LeftUpperArm",
    "DEF-upper_arm.L.001": "LeftUpperArm2",
    "DEF-forearm.L": "LeftLowerArm",
    "DEF-forearm.L.001": "LeftLowerArm2",
    "DEF-hand.L": "LeftHand",

    "DEF-shoulder.R": "RightShoulder",
    "DEF-upper_arm.R": "RightUpperArm",
    "DEF-upper_arm.R.001": "RightUpperArm2",
    "DEF-forearm.R": "RightLowerArm",
    "DEF-forearm.R.001": "RightLowerArm2",
    "DEF-hand.R": "RightHand",

    # Pelvis
    "DEF-pelvis.L": "LeftPelvis",
    "DEF-pelvis.R": "RightPelvis",

    # Legs
    "DEF-thigh.L": "LeftUpperLeg",
    "DEF-thigh.L.001": "LeftUpperLeg2",
    "DEF-shin.L": "LeftLowerLeg",
    "DEF-shin.L.001": "LeftLowerLeg2",
    "DEF-foot.L": "LeftFoot",
    "DEF-toe.L": "LeftToes",

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
    rename_bone_map = RIGIFY_RENAME_BONE_MAP

    armature = bpy.context.active_object

    assert armature is not None, "No active object found."
    assert armature.type == "ARMATURE", "Active object is not an armature."
    assert isinstance(armature.data, Armature), "Active object data is not an Armature."
    assert bpy.context.view_layer is not None, "No active view layer found."
    assert bpy.context.collection is not None, "No active collection found."

    bpy.ops.object.mode_set(mode="EDIT")
    edit_bones = armature.data.edit_bones

    tgt_collection = armature.data.collections.get("TGT")

    # If TGT collection exists, we assume the script has run before, so remove any bones from previous run.
    if tgt_collection:
        for bone_name_names in [n for n in rename_bone_map.values() if n in edit_bones]:
            edit_bones.remove(edit_bones[bone_name_names])
    else:
        print("Creating TGT collection.")
        tgt_collection = armature.data.collections.new("TGT")

    source_bone_data = [b for b in edit_bones if b.name in rename_bone_map.keys()]

    # Copy bones to TGT bone collection
    for source_bone in source_bone_data:
        # Disable deform for source bones (DEF-) since our TGT bones will be the
        # the transform bones.
        source_bone.use_deform = False

        new_name = rename_bone_map[source_bone.name] if source_bone.name in rename_bone_map else source_bone.name
        print("TGT bone: ", new_name)
        tgt_bone = edit_bones.new(new_name)
        tgt_bone.head = source_bone.head
        tgt_bone.tail = source_bone.tail
        tgt_bone.roll = source_bone.roll
        tgt_bone.use_deform = True
        tgt_bone.use_connect = False
        tgt_collection.assign(tgt_bone)

    # Set TGT bone parents
    for bone_name_names, parent_name in PARENT_BONE_MAP.items():
        if bone_name_names not in edit_bones or parent_name not in edit_bones:
            print("Bone not found in target armature:", bone_name_names)
            continue

        print(f"Set parent: {bone_name_names} -> {parent_name}")
        edit_bones[bone_name_names].parent = edit_bones[parent_name]

    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.mode_set(mode="POSE")

    # Add copy location and rotation constraints to match target bones to source bones
    assert armature.pose is not None, "Target armature has no pose."
    for source_name, target_name in rename_bone_map.items():
        target_bone = armature.pose.bones[target_name]

        # Add Copy Location constraint
        loc_constraint = cast(CopyLocationConstraint, target_bone.constraints.new(type='COPY_LOCATION'))
        loc_constraint.target = armature
        loc_constraint.subtarget = source_name
        loc_constraint.name = f"CopyLoc_{source_name}"

        # Add Copy Rotation constraint
        rot_constraint = cast(CopyRotationConstraint, target_bone.constraints.new(type='COPY_ROTATION'))
        rot_constraint.target = armature
        rot_constraint.subtarget = source_name
        rot_constraint.name = f"CopyRot_{source_name}"

    bpy.ops.object.mode_set(mode="OBJECT")

main()
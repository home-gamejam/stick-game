import bpy
import re
from bpy.types import Armature, CopyLocationConstraint, CopyRotationConstraint
from dataclasses import dataclass
from mathutils import Vector
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

MIXAMO_RENAME_BONE_MAP = {
    # Spine chain
    "mixamorig:Hips": "Hips",
    "mixamorig:Spine": "Spine",
    "mixamorig:Spine1": "Chest",
    "mixamorig:Spine2": "UpperChest",
    "mixamorig:Neck": "Neck",
    "mixamorig:Head": "Head",

    # Left arm chain
    "mixamorig:LeftShoulder": "LeftShoulder",
    "mixamorig:LeftArm": "LeftUpperArm",
    "mixamorig:LeftForeArm": "LeftLowerArm",
    "mixamorig:LeftHand": "LeftHand",

    # Right arm chain
    "mixamorig:RightShoulder": "RightShoulder",
    "mixamorig:RightArm": "RightUpperArm",
    "mixamorig:RightForeArm": "RightLowerArm",
    "mixamorig:RightHand": "RightHand",

    # Left leg chain
    "mixamorig:LeftUpLeg": "LeftUpperLeg",
    "mixamorig:LeftLeg": "LeftLowerLeg",
    "mixamorig:LeftFoot": "LeftFoot",
    "mixamorig:LeftToeBase": "LeftToes",

    # Right leg chain
    "mixamorig:RightUpLeg": "RightUpperLeg",
    "mixamorig:RightLeg": "RightLowerLeg",
    "mixamorig:RightFoot": "RightFoot",
    "mixamorig:RightToeBase": "RightToes",
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

@dataclass
class BoneData:
    name: str
    head: Vector
    tail: Vector
    roll: float

def main():
    print("Rigify to Godot")
    rename_bone_map = MIXAMO_RENAME_BONE_MAP

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
    target_armature.show_in_front = True
    bpy.context.collection.objects.link(target_armature)

    bpy.ops.object.mode_set(mode="EDIT")
    source_bone_data = [BoneData(
        name=b.name,
        head=b.head.copy(),
        tail=b.tail.copy(),
        roll=b.roll
    ) for b in armature.data.edit_bones if b.name in rename_bone_map.keys()]
    bpy.ops.object.mode_set(mode="OBJECT")

    # Deselect the source armature
    bpy.ops.object.select_all(action='DESELECT')
    bpy.context.view_layer.objects.active = None

    # Select the target armature
    target_armature.select_set(True)
    bpy.context.view_layer.objects.active = target_armature

    bpy.ops.object.mode_set(mode="EDIT")
    tgt_edit_bones = target_armature_data.edit_bones

    # Mixamo doesn't have a root bone, so create one
    if not "root" in rename_bone_map:
        # create new bone at origin pointing backwards
        root_bone = tgt_edit_bones.new("Root")
        root_bone.head = Vector((0.0, 0.0, 0.0))
        root_bone.tail = Vector((0.0, 0.5, 0.0))
        root_bone.roll = 0.0
        root_bone.use_deform = False

    # Assume a uniform scale for the armature. e.g. Mixamo scales to 0.01
    source_scale = armature.scale.x

    # Copy bones to target armature
    for source_bone in source_bone_data:
        new_name = rename_bone_map[source_bone.name] if source_bone.name in rename_bone_map else source_bone.name
        print("TGT bone: ", new_name)
        tgt_bone = tgt_edit_bones.new(new_name)
        tgt_bone.head = source_bone.head * source_scale
        tgt_bone.tail = source_bone.tail * source_scale
        tgt_bone.roll = source_bone.roll
        tgt_bone.use_deform = True
        tgt_bone.use_connect = False

    # Set target bone parents
    for bone_name, parent_name in PARENT_BONE_MAP.items():
        if bone_name not in tgt_edit_bones:
            print("Bone not found in target armature:", bone_name)
            continue

        # If assigne parent isn't in target armature, check if it is 1 level
        # up in the hierarchy (e.g. Mixamo doesn't have as many bones as Rigify)
        if parent_name not in tgt_edit_bones:
            parent_name = PARENT_BONE_MAP.get(parent_name, None)

        if parent_name is None or parent_name not in tgt_edit_bones:
            print("Parent not found for", bone_name)
            continue

        print(f"Set parent: {bone_name} -> {parent_name}")
        tgt_edit_bones[bone_name].parent = tgt_edit_bones[parent_name]

    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.mode_set(mode="POSE")

    # Add copy location and rotation constraints to match target bones to source bones
    assert target_armature.pose is not None, "Target armature has no pose."
    for source_name, target_name in rename_bone_map.items():
        target_bone = target_armature.pose.bones[target_name]

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
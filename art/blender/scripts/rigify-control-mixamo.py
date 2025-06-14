import bpy
from mathutils import Vector

# Define the armature names
MIXAMO_ARMATURE_NAME = "Mixamo.Armature"  # Replace with your Mixamo armature name
RIGIFY_ARMATURE_NAME = "Rigify.rig"  # Replace with your Rigify armature name

BONE_MAP = {
    "mixamorig:Hips": "DEF-spine",
    "mixamorig:Spine": "DEF-spine.001",
    "mixamorig:Spine1": "DEF-spine.002",
    "mixamorig:Spine2": "DEF-spine.003",
    # Rigify has 2 "neck" bones DEF-spine.004 and DEF-spine.005. We map Mixomo's
    # single "Neck" to the first DEF-spine.004. This should usually work since
    # it would apply to the base of the neck.
    "mixamorig:Neck": "DEF-spine.004",
    # Skip Rigify "DEF-spine.005"
    "mixamorig:Head": "DEF-spine.006",
    "mixamorig:HeadTop_End": "DEF-spine.006",
    "mixamorig:LeftShoulder": "DEF-shoulder.L",
    "mixamorig:LeftArm": "DEF-upper_arm.L",
    "mixamorig:LeftForeArm": "DEF-forearm.L",
    "mixamorig:LeftHand": "DEF-hand.L",
    "mixamorig:RightShoulder": "DEF-shoulder.R",
    "mixamorig:RightArm": "DEF-upper_arm.R",
    "mixamorig:RightForeArm": "DEF-forearm.R",
    "mixamorig:RightHand": "DEF-hand.R",
    "mixamorig:LeftUpLeg": "DEF-thigh.L",
    "mixamorig:LeftLeg": "DEF-shin.L",
    "mixamorig:LeftFoot": "DEF-foot.L",
    "mixamorig:LeftToeBase": "DEF-toe.L",
    "mixamorig:RightUpLeg": "DEF-thigh.R",
    "mixamorig:RightLeg": "DEF-shin.R",
    "mixamorig:RightFoot": "DEF-foot.R",
    "mixamorig:RightToeBase": "DEF-toe.R",
    # Skip fingers for now since target rig does not have them.
    # "mixamorig:LeftHandIndex1": None,
    # "mixamorig:LeftHandIndex2": None,
    # "mixamorig:LeftHandIndex3": None,
    # "mixamorig:LeftHandIndex4": None,
    # "mixamorig:RightHandIndex1": None,
    # "mixamorig:RightHandIndex2": None,
    # "mixamorig:RightHandIndex3": None,
    # "mixamorig:RightHandIndex4": None,
    # Rigify doesn't have comparable toe end bone
    # "mixamorig:LeftToe_End": None,
    # "mixamorig:RightToe_End": None,
}

def add_constraints_and_adjust_length():
    # Get the armatures
    mixamo_armature = bpy.data.objects.get(MIXAMO_ARMATURE_NAME)
    rigify_armature = bpy.data.objects.get(RIGIFY_ARMATURE_NAME)

    if not mixamo_armature or not rigify_armature:
        print("Error: One or both armatures not found!")
        return

    # Ensure we're in Object Mode
    bpy.ops.object.mode_set(mode='OBJECT')

    # Select Mixamo rig and go into pose mode
    bpy.context.view_layer.objects.active = mixamo_armature

    # Switch to Edit Mode to adjust bone lengths
    bpy.ops.object.mode_set(mode='EDIT')

    # Get edit bones for both armatures
    mixamo_bones = mixamo_armature.data.edit_bones
    rigify_bones = rigify_armature.data.bones

    # Adjust Mixamo bone lengths to match Rigify DEF- bones
    for mixamo_bone in mixamo_bones:
        rigify_bone_name = BONE_MAP.get(mixamo_bone.name)

        if rigify_bone_name == None:
            continue

        rigify_bone = rigify_bones.get(rigify_bone_name)

        if rigify_bone:
            print(f"Setting length of {mixamo_bone.name}")

            # Get the length of the Rigify bone
            rigify_length = (rigify_bone.tail - rigify_bone.head).length * 100

            # Calculate the direction vector of the Mixamo bone
            mixamo_direction = (mixamo_bone.tail - mixamo_bone.head).normalized()

            # Adjust the Mixamo bone's tail to match the Rigify bone's length
            mixamo_bone.tail = mixamo_bone.head + mixamo_direction * rigify_length
        else:
            print(f"Warning: No matching Rigify edit bone found for {mixamo_bone.name}")




    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.mode_set(mode='POSE')

    # Iterate through Mixamo rig's pose bones
    for mixamo_bone in mixamo_armature.pose.bones:
        rigify_bone_name = BONE_MAP.get(mixamo_bone.name)

        if rigify_bone_name == None:
            continue

        rigify_bone = rigify_armature.pose.bones.get(rigify_bone_name)

        if rigify_bone:
            # Remove all constraints from the bone
            for constraint in mixamo_bone.constraints:
                mixamo_bone.constraints.remove(constraint)

            # Add Copy Location constraint
            loc_constraint = mixamo_bone.constraints.new(type='COPY_LOCATION')
            loc_constraint.target = rigify_armature
            loc_constraint.subtarget = rigify_bone_name
            loc_constraint.name = f"CopyLoc_{rigify_bone_name}"

            # Add Copy Rotation constraint
            rot_constraint = mixamo_bone.constraints.new(type='COPY_ROTATION')
            rot_constraint.target = rigify_armature
            rot_constraint.subtarget = rigify_bone_name
            rot_constraint.name = f"CopyRot_{rigify_bone_name}"
        else:
            print(f"Warning: No matching Rigify bone found for {mixamo_bone.name}")

    return



    # Return to Object Mode
    bpy.ops.object.mode_set(mode='OBJECT')
    print("Constraints added and bone lengths adjusted successfully!")

# Run the script
add_constraints_and_adjust_length()
# Rename Mixamo action groups and curves to Rigify deform bones (DEF-xxx) format.
import bpy
import re

BONE_NAME_MAP = {
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

EXTRACT_MIXAMO_BONE_NAME_REGEX = r'"(mixamorig:\w+)"'

# Extract a Mixamo bone from inside double quotes.
# e.g. pose.bones["mixamorig:Hips"].scale -> mixamorig:Hips
def extract_mixamo_bone_name(s):
    match = re.search(EXTRACT_MIXAMO_BONE_NAME_REGEX, s)
    if match:
        return match.group(1)
    return None

def is_mapped_group(group) -> bool:
    return group.name in BONE_NAME_MAP

# Predicate function for filtering iterable containing curves. Extracts the name
# after `pose.bones[\"mixamorig:"` and checks if it is in the BONE_NAME_MAP.
def is_mapped_curve(curve) -> bool:
    return extract_mixamo_bone_name(curve.data_path) in BONE_NAME_MAP

def rename_actions_and_curves() -> None:
    # Actions
    for action in bpy.data.actions:

        # Mixamo action groups
        for group in filter(is_mapped_group, action.groups):
            new_group_name = BONE_NAME_MAP[group.name]
            print("group: ", group.name, " -> ", new_group_name)
#           group.name = new_group_name

        # Mixamo action fcurves
        for fcurve in filter(is_mapped_curve, action.fcurves):
            bone_name = extract_mixamo_bone_name(fcurve.data_path)
            new_data_path = fcurve.data_path.replace(
                f'"{bone_name}"',
                f'"{BONE_NAME_MAP[bone_name]}"')

            print("curve: ", fcurve.data_path, " -> ",  new_data_path)
#           fcurve.data_path = new_data_path

def main():
    print("Retargetting Mixamo to Rigify")
    rename_actions_and_curves()

main()
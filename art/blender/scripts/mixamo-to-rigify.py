# Rename Mixamo bones, action groups and curves to Rigify format. Strips the
# "mixamorig:" prefix from the bone name and replaces "Left" / "Right" prefix
# with ".L" / ".R" suffixes.
import bpy
import re

# Regular expression to extract the bone name from the "mixamorig:xxxx" format
EXTRACT_MIXAMO_BONE_NAME_REGEX = r'"mixamorig:(\w+)"'

MIXAMO_PREFIX = "mixamorig:"
MIXAMO_CURVE_PREFIX = "pose.bones[\"mixamorig:"

# Strip the "mixamorig:" prefix from the bone name and replace "Left" prefix
# with ".L" suffix and "Right" prefix with ".R" suffix
def new_name(name):
    name = name.replace(MIXAMO_PREFIX, "")
    if 'Left' in name:
        name = name[4:] + '.L'
    elif 'Right' in name:
        name = name[5:] + '.R'
    return name

# replace the "mixamorig:xxxx" part of the name with the new name
def new_curve_name(name):
    return re.sub(
        EXTRACT_MIXAMO_BONE_NAME_REGEX,
        lambda match: f'"{new_name(match.group(1))}"',
        name
    )

# Returns a predicate function that can be used to filter an iterable based on
# whether the attribute `attr_name` of the object starts with the given `prefix`.
def starts_with(prefix, attr_name="name"):
    return lambda s: getattr(s, attr_name).startswith(prefix)

def rename_actions_and_curves():
    # Actions
    for action in bpy.data.actions:
        # Mixamo action groups
        for group in filter(starts_with(MIXAMO_PREFIX), action.groups):
            print("group: ", group.name)
#            group.name = new_name(group.name)

        # Mixamo action curves
        for curve in filter(starts_with(MIXAMO_CURVE_PREFIX, "data_path"), action.fcurves):
            print("curve: ", curve.data_path)
#            curve.data_path = new_curve_name(curve.data_path)

def rename_bones(armature):
    # Mixamo bones
    for bone in filter(starts_with(MIXAMO_PREFIX), armature.data.bones):
        print("bone: ", bone.name)
#        bone.name = new_name(bone.name)

def main():
    print("Retargetting Mixamo to Rigify")
    # get selected armature
    armature = bpy.context.active_object

    if armature:
        rename_bones(armature)

    # Note: action names and curves are not restricted to armature.
    # This will target any found in the blend file
    rename_actions_and_curves()

main()

# def test():
#     bone_name = "mixamorig:LeftArm"
#     group_name = "mixamorig:RightUpLeg"
#     curve_name = "pose.bones[\"mixamorig:RightUpLeg\"].location"

#     print(bone_name, new_name(bone_name))
#     print(group_name, new_name(group_name))
#     print(curve_name, new_curve_name(curve_name))

# test()
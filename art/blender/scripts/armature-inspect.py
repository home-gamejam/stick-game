# This script lists specific bones in a selected armature in Blender.
# Mixamo - Any bone whose name starts with "mixamorig:"
# Rigify - List all of the deform bones (any bone whose name starts with "DEF-")
import bpy
import re

def is_mixamo_bone(bone) -> bool:
    return bone.name.startswith("mixamorig:")

def is_rigify_control_bone(bone) -> bool:
    exclude = ["DEF-", "MCH-", "ORG-", "tweak_", "_tweak.", "_ik.", "ik_target.", "VIS_"]
    return not any(ex in bone.name for ex in exclude)

# Print bone name for any bone that starts with a filter in the give filters list.
# If no filters are provided, it will list all bones.
def list_bones(armature, filters=None):
    print(f"Armature: {armature.name}")
    print("Bones:")

    for bone in armature.data.bones:
        if filters is None or any(filter(bone) for filter in filters):
            print(bone.name)


def main():
    # get selected armature
    armature = bpy.context.active_object

    if not armature or armature.type != 'ARMATURE':
        print("Active object is not an armature.")
        return

    list_bones(armature, filters=[is_mixamo_bone, is_rigify_control_bone])

main()
# This script lists specific bones in a selected armature in Blender.
# Mixamo - Any bone whose name starts with "mixamorig:"
# Rigify - List all of the deform bones (any bone whose name starts with "DEF-")
import bpy
import re

# Print bone name for any bone that starts with a filter in the give filters list.
# If no filters are provided, it will list all bones.
def list_bones(armature, filters=None):
    print(f"Armature: {armature.name}")
    print("Bones:")

    for bone in armature.data.bones:
        if filters is None or any(bone.name.startswith(prefix) for prefix in filters):
            print(bone.name)


def main():
    # get selected armature
    armature = bpy.context.active_object

    if not armature or armature.type != 'ARMATURE':
        print("Active object is not an armature.")
        return

    list_bones(armature, filters=["DEF-", "mixamorig:"])

main()
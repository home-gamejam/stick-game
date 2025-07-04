"""
set_origin_to_selection.py

Blender script to set the object's origin to the centroid (arithmetic mean) of the currently selected vertices, or to a specific mesh corner.

Features:
- Works in Edit Mode (Mesh objects).
- Remembers and restores the original mode and 3D cursor location.
- Adds operators to the 3D Viewport context menu for easy access.
- Provides two operators:
    1. Set origin to centroid of selected vertices.
    2. Set origin to the mesh corner (lowest Z, highest Y, lowest X) of all vertices.
- Robust error handling and user feedback.
- Designed for maintainability and code reuse.
"""

from typing import cast
import bpy
from bpy.types import Mesh, Object
from mathutils import Vector
import bmesh
from bmesh.types import BMesh

class OBJECT_OT_set_origin_base(bpy.types.Operator):
    bl_options = {'REGISTER', 'UNDO'}

    @classmethod
    def poll(cls, context) -> bool:
        obj = context.active_object
        if obj is None:
            return False
        return obj.type == 'MESH' and obj.mode in {'EDIT', 'OBJECT'}

    def get_target_point(self, bm: BMesh) -> Vector | None:
        raise NotImplementedError

    def execute(self, context) -> set[str]: # type: ignore
        obj = context.active_object
        if obj is None:
            self.report({'WARNING'}, 'No active object')
            return {'CANCELLED'}
        scene = context.scene
        if scene is None:
            self.report({'WARNING'}, 'No active scene')
            return {'CANCELLED'}

        # Store things we want to restore later
        original_mode = obj.mode
        original_cursor_location = scene.cursor.location.copy()

        # Get selected verts using bmesh in edit mode
        mesh = cast(Mesh, obj.data)
        bm = bmesh.from_edit_mesh(mesh)
        target = self.get_target_point(bm)
        if target is None:
            return {'CANCELLED'}

        # Switch to object mode for origin operation
        bpy.ops.object.mode_set(mode='OBJECT')
        # Set 3D cursor to target point
        scene.cursor.location = obj.matrix_world @ target
        # Set origin to 3D cursor
        bpy.ops.object.origin_set(type='ORIGIN_CURSOR', center='MEDIAN')
        # Restore original 3D cursor position
        scene.cursor.location = original_cursor_location
        bpy.ops.object.mode_set(mode=original_mode)
        return {'FINISHED'}

class OBJECT_OT_set_origin_to_selection(OBJECT_OT_set_origin_base):
    bl_idname = "object.set_origin_to_selection"
    bl_label = "Set Origin to Centroid"
    bl_description = "Set the object's origin to the centroid of selected vertices"

    def get_target_point(self, bm: BMesh) -> Vector | None:
        selected_verts = [v.co.copy() for v in bm.verts if v.select]
        if not selected_verts:
            self.report({'WARNING'}, 'No vertices selected')
            return None
        return sum(selected_verts, Vector()) / len(selected_verts)

class OBJECT_OT_set_origin_to_corner(OBJECT_OT_set_origin_base):
    bl_idname = "object.set_origin_to_corner"
    bl_label = "Set Origin to Corner (Lowest Z, Highest Y, Lowest X)"
    bl_description = "Set the object's origin to the corner of all vertices (lowest Z, highest Y, lowest X)"

    def get_target_point(self, bm: BMesh) -> Vector | None:
        all_verts = [v.co.copy() for v in bm.verts]
        if not all_verts:
            self.report({'WARNING'}, 'No vertices found')
            return None
        return min(all_verts, key=lambda v: (v.z, -v.y, v.x))

# Add both operators to the context menus in Edit and Object mode

def menu_func(self, context):
    self.layout.operator(OBJECT_OT_set_origin_to_selection.bl_idname)
    self.layout.operator(OBJECT_OT_set_origin_to_corner.bl_idname)

def register():
    bpy.utils.register_class(OBJECT_OT_set_origin_to_selection)
    bpy.utils.register_class(OBJECT_OT_set_origin_to_corner)
    bpy.types.VIEW3D_MT_edit_mesh_context_menu.append(menu_func)
    bpy.types.VIEW3D_MT_object_context_menu.append(menu_func)  # Add to object mode menu

def unregister():
    bpy.types.VIEW3D_MT_edit_mesh_context_menu.remove(menu_func)
    bpy.types.VIEW3D_MT_object_context_menu.remove(menu_func)  # Remove from object mode menu
    bpy.utils.unregister_class(OBJECT_OT_set_origin_to_corner)
    bpy.utils.unregister_class(OBJECT_OT_set_origin_to_selection)

if __name__ == "__main__":
    register()

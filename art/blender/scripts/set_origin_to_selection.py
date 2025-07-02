"""
set_origin_to_selection.py

Blender script to set the object's origin to the centroid (arithmetic mean) of the currently selected vertices.
- Works in Edit Mode (Mesh objects).
- Remembers and restores the original mode.
- Adds an operator to the 3D Viewport context menu for easy access.
"""

from typing import cast
import bpy
from bpy.types import Mesh
from mathutils import Vector
import bmesh

class OBJECT_OT_set_origin_to_selection(bpy.types.Operator):
    bl_idname = "object.set_origin_to_selection"
    bl_label = "Set Origin to Centroid"
    bl_description = "Set the object's origin to the centroid of selected vertices"
    bl_options = {'REGISTER', 'UNDO'}

    @classmethod
    def poll(cls, context) -> bool:
        obj = context.active_object
        if obj is None:
            return False
        return obj.type == 'MESH' and obj.mode == 'EDIT'

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
        selected_verts = [v.co.copy() for v in bm.verts if v.select]
        if not selected_verts:
            self.report({'WARNING'}, 'No vertices selected')
            return {'CANCELLED'}
        centroid = sum(selected_verts, Vector()) / len(selected_verts)

        # Switch to object mode for origin operation
        bpy.ops.object.mode_set(mode='OBJECT')
        # Set 3D cursor to centroid
        scene.cursor.location = obj.matrix_world @ centroid
        # Set origin to 3D cursor
        bpy.ops.object.origin_set(type='ORIGIN_CURSOR', center='MEDIAN')
        # Restore original 3D cursor position
        scene.cursor.location = original_cursor_location
        bpy.ops.object.mode_set(mode=original_mode)
        return {'FINISHED'}

def menu_func(self, context):
    self.layout.operator(OBJECT_OT_set_origin_to_selection.bl_idname)

def register():
    bpy.utils.register_class(OBJECT_OT_set_origin_to_selection)
    bpy.types.VIEW3D_MT_edit_mesh_context_menu.append(menu_func)

def unregister():
    bpy.types.VIEW3D_MT_edit_mesh_context_menu.remove(menu_func)
    bpy.utils.unregister_class(OBJECT_OT_set_origin_to_selection)

if __name__ == "__main__":
    register()

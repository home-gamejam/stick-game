"""
set_origin_to_selection.py

Blender script to set the object's origin to the centroid (arithmetic mean) of the currently selected vertices, or to a specific mesh corner.

Features:
- Works in Edit Mode (Mesh objects).
- Remembers and restores the original mode and 3D cursor location.
- Adds operators to the 3D Viewport context menu for easy access.
- Provides three operators:
    1. Set origin to centroid of selected vertices.
    2. Set origin to the mesh corner (lowest Z, highest Y, lowest X) of all vertices.
    3. Set origin to the center of the floor (lowest Z, center of min/max X and Y).
- Robust error handling and user feedback.
- Designed for maintainability and code reuse.
"""

from typing import cast
import bpy
from bpy.types import Mesh, Object
from mathutils import Vector
import bmesh
from bmesh.types import BMesh

bl_info = {
    "name": "Set Origin Tools",
    "author": "Emeraldwalk",
    "version": (1, 0, 0),
    "blender": (3, 0, 0),
    "location": "View3D > Object Context Menu, Edit Mesh Context Menu",
    "description": "Set origin to centroid, bounding box corner, or bounding box bottom center for mesh objects.",
    "category": "Object",
}

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

        # Ensure we are in Edit mode to access mesh data
        if obj.mode != 'EDIT':
            bpy.ops.object.mode_set(mode='EDIT')

        mesh = cast(Mesh, obj.data)
        bm = bmesh.from_edit_mesh(mesh)
        target = self.get_target_point(bm)
        if target is None:
            # Restore original mode if changed
            if obj.mode != original_mode:
                bpy.ops.object.mode_set(mode=original_mode)
            return {'CANCELLED'}

        # Switch to object mode for origin operation
        bpy.ops.object.mode_set(mode='OBJECT')
        # Set 3D cursor to target point
        scene.cursor.location = obj.matrix_world @ target
        # Set origin to 3D cursor
        bpy.ops.object.origin_set(type='ORIGIN_CURSOR', center='MEDIAN')
        # Restore original 3D cursor position
        scene.cursor.location = original_cursor_location
        # Restore original mode if changed
        if obj.mode != original_mode:
            bpy.ops.object.mode_set(mode=original_mode)
        return {'FINISHED'}

class OBJECT_OT_set_origin_to_selection(OBJECT_OT_set_origin_base):
    bl_idname = "object.set_origin_to_selection"
    bl_label = "Origin to Centroid"
    bl_description = "Set the object's origin to the centroid of selected vertices"

    def get_target_point(self, bm: BMesh) -> Vector | None:
        selected_verts = [v.co.copy() for v in bm.verts if v.select]
        if not selected_verts:
            self.report({'WARNING'}, 'No vertices selected')
            return None
        return sum(selected_verts, Vector()) / len(selected_verts)

class OBJECT_OT_set_origin_to_corner(OBJECT_OT_set_origin_base):
    bl_idname = "object.set_origin_to_corner"
    bl_label = "Origin to Corner"
    bl_description = "Set the object's origin to the corner of all vertices (lowest Z, highest Y, lowest X)"

    def get_target_point(self, bm: BMesh) -> Vector | None:
        all_verts = [v.co.copy() for v in bm.verts]
        if not all_verts:
            self.report({'WARNING'}, 'No vertices found')
            return None
        return min(all_verts, key=lambda v: (v.z, -v.y, v.x))

class OBJECT_OT_set_origin_to_bottom_center(OBJECT_OT_set_origin_base):
    bl_idname = "object.set_origin_to_bottom_center"
    bl_label = "Origin to Bounding Bottom Center"
    bl_description = (
        "Set the object's origin to the center of the bottom face of the mesh's bounding box (min Z, center X/Y)"
    )

    def get_target_point(self, bm: BMesh) -> Vector | None:
        verts = [v.co for v in bm.verts]
        if not verts:
            self.report({'WARNING'}, 'No vertices found')
            return None
        min_x = min(v.x for v in verts)
        max_x = max(v.x for v in verts)
        min_y = min(v.y for v in verts)
        max_y = max(v.y for v in verts)
        min_z = min(v.z for v in verts)
        center_x = (min_x + max_x) / 2.0
        center_y = (min_y + max_y) / 2.0
        return Vector((center_x, center_y, min_z))

# Add all operators to the context menus in Edit and Object mode

def menu_func(self, context):
    self.layout.operator(OBJECT_OT_set_origin_to_selection.bl_idname)
    self.layout.operator(OBJECT_OT_set_origin_to_corner.bl_idname)
    self.layout.operator(OBJECT_OT_set_origin_to_bottom_center.bl_idname)

def register():
    bpy.utils.register_class(OBJECT_OT_set_origin_to_selection)
    bpy.utils.register_class(OBJECT_OT_set_origin_to_corner)
    bpy.utils.register_class(OBJECT_OT_set_origin_to_bottom_center)
    bpy.types.VIEW3D_MT_edit_mesh_context_menu.append(menu_func)
    bpy.types.VIEW3D_MT_object_context_menu.append(menu_func)


def unregister():
    bpy.types.VIEW3D_MT_edit_mesh_context_menu.remove(menu_func)
    bpy.types.VIEW3D_MT_object_context_menu.remove(menu_func)
    bpy.utils.unregister_class(OBJECT_OT_set_origin_to_bottom_center)
    bpy.utils.unregister_class(OBJECT_OT_set_origin_to_corner)
    bpy.utils.unregister_class(OBJECT_OT_set_origin_to_selection)

# Only run register if loaded as an addon, not as a script
if __name__ == "__main__":
    register()

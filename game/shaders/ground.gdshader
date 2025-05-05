shader_type spatial;
render_mode cull_back;

// Uniforms for customization
uniform vec3 dirt_color : source_color = vec3(0.35, 0.25, 0.15); // Base dirt color (brownish)
uniform float roughness : hint_range(0.0, 1.0) = 0.9; // Rough surface
uniform float noise_scale : hint_range(0.1, 10.0) = 2.0; // Noise frequency
uniform float noise_strength : hint_range(0.0, 0.5) = 0.2; // Noise color variation
uniform float normal_strength : hint_range(0.0, 2.0) = 0.5; // Procedural normal intensity

// Simple 2D noise function (Godot doesn't have built-in 3D noise in shaders)
float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// Layered noise for more organic look
float layered_noise(vec2 uv, float scale) {
    float n = 0.0;
    n += noise(uv * scale) * 0.5;
    n += noise(uv * scale * 2.0) * 0.25;
    n += noise(uv * scale * 4.0) * 0.125;
    return n;
}

void fragment() {
    // Scale UV for noise
    vec2 uv = UV * noise_scale;

    // Generate noise for albedo variation
    float noise_value = layered_noise(uv, 1.0);
    vec3 albedo = dirt_color + noise_value * noise_strength; // Vary base color

    // Generate procedural normal using noise derivatives
    float delta = 0.01;
    float n1 = layered_noise(uv, 1.0);
    float n2 = layered_noise(uv + vec2(delta, 0.0), 1.0);
    float n3 = layered_noise(uv + vec2(0.0, delta), 1.0);
    vec3 normal = normalize(vec3(n1 - n2, n1 - n3, 1.0)) * normal_strength;
    normal = normal * 0.5 + 0.5; // Convert to [0,1] range for NORMAL_MAP

    // Set material properties
    ALBEDO = albedo;
    ROUGHNESS = roughness;
    METALLIC = 0.0; // Dirt is non-metallic
    NORMAL_MAP = normal; // Apply procedural normal
    NORMAL_MAP_DEPTH = normal_strength; // Control normal intensity
}
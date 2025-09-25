shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 center_world;   // world-space center
uniform float radius = 0.0;

void fragment() {
    // Convert SCREEN_UV to world-space coordinates (pixels in the viewport)
    vec2 world_pos = SCREEN_UV * vec2(textureSize(SCREEN_TEXTURE, 0));

    float dist = distance(world_pos, center_world);
    float alpha = smoothstep(radius - 10.0, radius, dist);

    COLOR = vec4(vec3(0.0), alpha);
}

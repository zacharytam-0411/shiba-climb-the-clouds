shader_type canvas_item;

uniform vec2 center;           // normalized (0–1)
uniform float radius = 0.0;    // normalized
uniform float softness = 0.05;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Aspect ratio correction
    float aspect = float(SCREEN_PIXEL_SIZE.x) / SCREEN_PIXEL_SIZE.y;
    vec2 corrected_uv = vec2(uv.x - center.x, (uv.y - center.y) * aspect);

    float dist = length(corrected_uv);
    float mask = smoothstep(radius, radius - softness, dist);
    float alpha = 1.0 - mask;

    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}

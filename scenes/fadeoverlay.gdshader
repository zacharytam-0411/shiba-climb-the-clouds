shader_type canvas_item;

uniform vec2 center;       // in pixels
uniform float radius = 0.0;

void fragment() {
    vec2 pos = FRAGCOORD.xy;               // pixel position
    float dist = distance(pos, center);    // distance from circle center
    float mask = smoothstep(radius - 10.0, radius + 10.0, dist);
    COLOR = vec4(0.0, 0.0, 0.0, mask);     // black outside circle
}

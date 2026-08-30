shader_type spatial;

render_mode
    unshaded,
    cull_front,
    depth_test_disabled,
    depth_draw_never;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width = 0.05;

void vertex() {
    VERTEX += NORMAL * outline_width;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    EMISSION = outline_color.rgb;
    ALPHA = outline_color.a;
}

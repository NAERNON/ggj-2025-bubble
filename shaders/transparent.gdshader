shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D alpha_viewport;
uniform vec4 albedo : source_color;
uniform float alpha = 0.0;

//uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec3 behind = textureLod(alpha_viewport, SCREEN_UV, 0.0).rgb;
	vec3 color = mix(albedo.rgb, behind, alpha);

    ALBEDO = color;
}

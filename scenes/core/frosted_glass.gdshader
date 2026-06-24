shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;

void fragment() {
    vec4 blurred_bg = textureLod(screen_texture, SCREEN_UV, blur_amount);
    vec3 final_rgb = mix(blurred_bg.rgb, COLOR.rgb, COLOR.a);
    float final_alpha = smoothstep(0.0, 0.05, COLOR.a);
    COLOR = vec4(final_rgb, final_alpha);
}
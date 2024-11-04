shader_type canvas_item;

uniform lowp sampler2D screen_texture : hint_screen_texture, filter_nearest_mipmap, repeat_enable;
uniform lowp float alpha : hint_range(0.0, 1.0);
uniform lowp float scale : hint_range(0.0, 2.0);

uniform lowp float red_shift;
uniform lowp float blue_shift;
uniform lowp float green_shift;
uniform lowp float red_mult = 1;

// New uniform for screen shake intensity
uniform lowp float shake_intensity : hint_range(0.0, 100.0);

void fragment() {
    // Basic UV scaling
    vec2 uvs = SCREEN_UV * scale;

    // Adding screen shake effect using sine and cosine waves with time-based offsets
    float shake_x = sin(TIME * 50.0) * shake_intensity * SCREEN_PIXEL_SIZE.x;
    float shake_y = cos(TIME * 30.0) * shake_intensity * SCREEN_PIXEL_SIZE.y;

    // Offset uvs with the shake effect
    uvs += vec2(shake_x, shake_y);

    // Sampling texture with RGB shifts
    vec4 final_texture = texture(screen_texture, uvs);
    float r = texture(screen_texture, uvs + vec2(SCREEN_PIXEL_SIZE * red_shift), 0.0).r * red_mult;
    float g = texture(screen_texture, uvs + vec2(SCREEN_PIXEL_SIZE * green_shift), 0.0).g;
    float b = texture(screen_texture, uvs + vec2(SCREEN_PIXEL_SIZE * blue_shift), 0.0).b;

    COLOR = vec4(r, g, b, alpha);
}

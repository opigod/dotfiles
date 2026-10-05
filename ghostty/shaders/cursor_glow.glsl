// Simple glowing cursor for Ghostty

// --- CONFIGURATION ---
const vec3  GLOW_COLOR   = vec3(0.635, 0.467, 1.0); // or iCurrentCursorColor.rgb to match your cursor
const float GLOW_RADIUS  = 4.0;  // falloff in pixels (bigger = wider glow)
const float INTENSITY    = 0.8;   // brightness of the glow
const float PULSE_AMOUNT = 0.0;   // 0.0 = steady, try 0.25 for a slow "breathing" pulse
const float PULSE_SPEED  = 2.0;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 base = texture(iChannel0, uv);

    // iCurrentCursor: xy = top-left corner, zw = size (origin bottom-left)
    vec4 cur = iCurrentCursor;
    vec2 center = vec2(cur.x + cur.z * 0.5, cur.y - cur.w * 0.5);
    vec2 halfSize = cur.zw * 0.5;

    // distance from this pixel to the cursor rectangle (0 inside it)
    vec2 d = abs(fragCoord - center) - halfSize;
    float dist = length(max(d, 0.0));

    float glow = exp(-dist / GLOW_RADIUS);
    float pulse = 1.0 - PULSE_AMOUNT * (0.5 + 0.5 * sin(iTime * PULSE_SPEED));

    // additive, so it reads as light instead of a flat overlay
    vec3 color = base.rgb + GLOW_COLOR * glow * INTENSITY * pulse;
    fragColor = vec4(color, base.a);
}

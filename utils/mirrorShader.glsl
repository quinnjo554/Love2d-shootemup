extern vec2 SCREEN_SIZE;
extern float TIME; // Pass the time in seconds from Lua

const float RIPPLE_INTENSITY = 0.01; // Reduced ripple strength
const float WAVE_SPEED = 0.5; // Slowed down wave speed
const float SHIMMER_INTENSITY = 0.05; // Softer shimmer
const float GRAIN_INTENSITY = 0.08; // Grain effect
const float REFLECTION_INTENSITY = 0.4; // New reflection intensity
const vec3 MAGIC_COLOR = vec3(0.4, 0.5, 0.8); // Softer magic glow
const vec3 REFLECTION_COLOR = vec3(1.0, 1.0, 1.0); // Bright white reflection

// Simple pseudo-random function for grain
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Improved noise function for more organic reflections
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    // Smooth Interpolation using Hermite cubic
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    // Mix 4 corners percentual
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Normalize screen coordinates
    vec2 uv = screen_coords / SCREEN_SIZE;
    
    // Create a softer ripple effect centered on the mirror
    float dist = distance(uv, vec2(0.5, 0.5));
    float ripple = sin(dist * 15.0 - TIME * WAVE_SPEED) * RIPPLE_INTENSITY * (1.0 - dist * 2.0);
    
    // Add subtle shimmer effect
    float shimmer = sin(TIME * 4.0 + uv.x * 8.0) * SHIMMER_INTENSITY * (1.0 - dist);
    
    // Add grain effect
    float grain = random(uv + TIME * 0.01) * GRAIN_INTENSITY;
    
    // Create reflection effect
    float reflection = noise(uv * 10.0 + TIME * 0.5) * REFLECTION_INTENSITY * (1.0 - dist);
    vec3 reflectionColor = REFLECTION_COLOR * reflection;
    
    // Modify texture coordinates with softer distortion
    vec2 distortedCoords = texture_coords;
    distortedCoords.x += ripple + shimmer;
    
    // Sample the texture with distorted coordinates
    vec4 texColor = Texel(texture, distortedCoords);
    
    // Softer, more subtle glow around the edges
    float glow = smoothstep(0.3, 0.7, dist) * 0.3; // Reduced and softened glow
    vec3 magicGlow = MAGIC_COLOR * glow;
    
    // Combine the texture with magic effects, reflection, and grain
    texColor.rgb += magicGlow;
    texColor.rgb += reflectionColor;
    texColor.rgb += grain;
    
    // Slightly reduce overall intensity
    texColor *= 0.9;
    
    return texColor * color;
}

#version 460

precision mediump float;
layout(location = 0) out vec4 fragColor;
layout(location = 0) uniform vec2 iResolution;
layout(location = 1) uniform float iTime;

//simulating if conditions for greater than
//if x greater than or equal k to return 1
//else return 0
float isGt(float x, float k) {
    return ceil(((sign(x - k)) + 1.0) / 2.0);
}

void main() {
    vec2 p = gl_FragCoord.xy / iResolution.xy;
    vec3 horColour = vec3(p.x, p.y, p.x);

    fragColor = vec4(horColour, 1.0);
}

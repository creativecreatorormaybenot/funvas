#version 320 es

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
    vec2 p = (2.0 * gl_FragCoord.xy - iResolution.xy) / iResolution.xy;
    float tau = 3.1415926535 * 2.0;
    float a = atan(p.x, p.y);
    float r = length(p) * 0.75;
    vec2 uv = vec2(a / tau, r);

	//get the color
    float xCol = (uv.x - (iTime / 3.0)) * 3.0;
    xCol = mod(xCol, 3.0);
    vec3 horColour = vec3(0.25, 0.25, 0.25);

    horColour.r += mix(1.0 - xCol, 0.0, isGt(xCol, 1.0));
    horColour.g += mix(xCol, 0.0, isGt(xCol, 1.0));

    float newxCol = mix(xCol - 1.0, xCol - 2.0, isGt(xCol, 2.0));

    horColour.g += mix(0.0, mix(1.0 - newxCol, 0.0, isGt(xCol, 2.0)), isGt(xCol, 1.0));
    horColour.b += mix(0.0, mix(newxCol, 1.0 - newxCol, isGt(xCol, 2.0)), isGt(xCol, 1.0));
    horColour.r += mix(0.0, mix(newxCol, 0.0, isGt(xCol, 2.0)), isGt(xCol, 1.0));


	// draw color beam
    uv = (2.0 * uv) - 1.0;
    float beamWidth = (0.7 + 0.5 * cos(uv.x * 10.0 * tau * 0.15 * clamp(floor(5.0 + 10.0 * cos(iTime)), 0.0, 10.0))) * abs(1.0 / (30.0 * uv.y));
    vec3 horBeam = vec3(beamWidth);
    fragColor = vec4(((horBeam) * horColour), 1.0);
}

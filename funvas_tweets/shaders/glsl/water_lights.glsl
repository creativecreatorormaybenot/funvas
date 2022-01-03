#version 450 

precision highp float;
layout(location = 0) out vec4 outColor;
layout(location = 0) uniform vec2 resolution;
layout(location = 2) uniform float time;

//random
float rand(vec2 coord) {
    return fract(sin(dot(coord, vec2(12.9898, 78.233))) *
        43758.5453123);
}

//noise1d
float noise1D(float coord) {
    float cellId = floor(coord);
    return rand(vec2(cellId));
}

//noise2d
float noise2D(vec2 coord) {
    vec2 id = floor(coord);
    vec2 fraction = fract(coord);
    //4 punkty kwadratu
    float a = rand(id);
    float b = rand(id + vec2(1., 0.));
    float c = rand(id + vec2(0., 1.));
    float d = rand(id + vec2(1., 1.));

    //interpolacja
    vec2 smoothCorners = smoothstep(0., 1., fraction);

    //mix kornerow
    return mix(a, b, smoothCorners.x) +
        (c - a) * smoothCorners.y * (1. - smoothCorners.x) +
        (d - b) * smoothCorners.x * smoothCorners.y;
}

//rysowanie kwadratow 
float drawSquare(vec2 coord, float a, float blur) {
    float band1 = smoothstep(a + blur, a - blur, coord.x);
    float band2 = smoothstep(-a - blur, -a + blur, coord.x);
    float band3 = smoothstep(a + blur, a - blur, coord.y);
    float band4 = smoothstep(-a - blur, -a + blur, coord.y);
    return band1 * band2 * band3 * band4;
}

//rotate
mat2 rotate(float angle) {

    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));

}
void main() {
    vec2 iResolution = resolution;
    float iTime = time;

     // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = gl_FragCoord.xy / iResolution.xy - vec2(0.5, 0.5);
    uv *= 2.;

    float noise1d1 = noise1D(uv.x * 65.) * .1;

    float timeSin = sin(iTime);
    float timeCos = cos(iTime);
    vec2 uv2 = abs(uv * .15 * 150. * (noise1d1 * sin(iTime * 1.21)));

    vec2 uv3 = (uv * .15 * 50.);

    vec2 uvSquareRot1 = uv * 1.7;
    vec2 uvSquareRot2 = uv * 2.2;
    vec2 uvSquareRot3 = uv * 2.;

    vec3 col = vec3(.0);
    vec3 blue = vec3(0., .5, 1.);

    float noise1 = noise2D(vec2(uv2.x + iTime, uv2.y)) *
        noise2D(vec2(-uv2.x + iTime, uv2.y)) *
        noise2D(vec2(-uv2.x, -uv2.y + iTime)) *
        noise2D(vec2(uv2.x, -uv2.y + iTime));

    uv2.x += noise1 * 1.5;

    float noise3x = noise2D(vec2(uv2.x * 1. + iTime * 1.1 + iTime));
    noise3x += noise2D(vec2(uv2.x * 2.));
    float noise3y = noise2D(vec2(uv3.y * 1. + iTime * 5.));

    float time = iTime * -2.5;
    col = 1. - col;

    uvSquareRot1.y += ((noise3x - .5) * .2) * 10. * timeSin;
    uvSquareRot2.y += ((noise3x - .5) * .2) * 10. * timeSin;
    uvSquareRot3.y += ((noise3x - .5) * .2) * 10. * timeSin;

    uvSquareRot1.x += ((noise3y - .5) * .2) * 5. * timeCos * 3.;
    uvSquareRot2.x += ((noise3y - .5) * .2) * 5. * timeCos * 2.;
    uvSquareRot3.x += ((noise3y - .5) * .2) * 5. * timeCos * 1.;

    uvSquareRot1 *= rotate(1. * time * .1 * noise1d1 * 15.); ///////////////////////
    uvSquareRot2 *= rotate(-1. * time * .5);
    uvSquareRot3 *= rotate(1. * time * .25);

    col *= (drawSquare(uvSquareRot1, .55 + noise1, .2) - drawSquare(uvSquareRot1, .55 * .99 + noise1, .01)) * blue * .7 +
        (drawSquare(uvSquareRot1, 1. + noise1, .2) - drawSquare(uvSquareRot1, 1. * .9 + noise1, .01)) * blue * .1 +
        (drawSquare(uvSquareRot2, .5 + noise1, .1) - drawSquare(uvSquareRot2, .5 * .9 + noise1, .01)) * blue * .5 +
        (drawSquare(uvSquareRot3, .35 + noise1, .3) - drawSquare(uvSquareRot3, .35 * .9 + noise1, .01)) * blue * 1. +
        drawSquare(uvSquareRot3, .1 + noise1, .05);

    col += vec3(pow(col.x, 1.5));
    col += vec3(pow(col.y, .9));
    col += vec3(pow(col.z, 3.5));

    // Output to screen
    outColor = vec4(col, 0.5);
}
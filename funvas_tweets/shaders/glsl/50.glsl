#version 460

precision mediump float;
layout(location = 0) out vec4 fragColor;
layout(location = 0) uniform vec2 res;
layout(location = 1) uniform float t;

const float iterations = 100;
const float rotationDuration = 9;
const float threshold = 16;

const float pi = 3.14159265359;

// HSL conversion from https://www.shadertoy.com/view/XljGzV.
vec3 hsl2rgb(in vec3 c) {
  vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
  return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

void main() {
  float zoom = cos(mod(t, rotationDuration) / rotationDuration * 2 * pi) * .5;
  vec2 reRange = vec2(-1.65 + .65 - zoom, 1.65 - .65 + zoom);
  vec2 imRange = vec2(-1.65 + .65 - zoom, 1.65 - .65 + zoom);

  vec2 centerPoint = vec2(-0.75, 0);
  vec2 c = vec2(centerPoint.x + cos(mod(t, rotationDuration) / rotationDuration * 2 * pi) * .05, centerPoint.y + sin(mod(t, rotationDuration) / rotationDuration * 2 * pi) * .1);

  float re = (reRange.y - reRange.x) * (gl_FragCoord.x / res.x);
  float im = (imRange.y - imRange.x) * (gl_FragCoord.y / res.y);

  float n = 0;
  float zre = re, zim = im;
  for(float tn = 0; tn < iterations; tn++) {
    float tzre = zre * zre - zim * zim + c.x;
    zim = 2 * zre * zim + c.y;
    zre = tzre;

    n = tn;
    if (abs(zre) + abs(zim) > threshold)
      break;
  }

  if (n == iterations) {
    fragColor = vec4(0, 0, 0, 1);
  } else {
    vec3 hsl = vec3(1 - n / iterations, .9, .6);
    vec3 rgb = hsl2rgb(hsl);
    fragColor = vec4(rgb, 1);
  }
}

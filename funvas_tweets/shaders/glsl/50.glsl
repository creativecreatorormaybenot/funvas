#version 460

precision mediump float;
layout(location = 0) out vec4 fragColor;
layout(location = 0) uniform vec2 iResolution;
layout(location = 1) uniform float t;

const float iterations = 100;
const float rotationDuration = 9;
const float threshold = 16;

const float pi = 3.14159265359;

void main() {
  float zoom = cos(mod(t, rotationDuration) / rotationDuration * 2 * pi) * .5;
  vec2 reRange = vec2(-1.65 + .65 - zoom, 1.65 - .65 + zoom);
  vec2 imRange = vec2(-1.65 + .65 - zoom, 1.65 - .65 + zoom);

  vec2 centerPoint = vec2(-0.75, 0);
  vec2 c = vec2(
    centerPoint.x + cos(mod(t, rotationDuration) / rotationDuration * 2 * pi) * .05,
    centerPoint.y + sin(mod(t, rotationDuration) / rotationDuration * 2 * pi) * .1
  );

  float re = (reRange.y - reRange.x) * (gl_FragCoord.x / iResolution.x);
  float im = (imRange.y - imRange.x) * (gl_FragCoord.y / iResolution.y);

  float n = 0;
  float zre = re, zim = im;
  while (n < iterations) {
    float tzre = zre * zre - zim * zim + c.x;
    zim = 2 * zre * zim + c.y;
    zre = tzre;

    if (abs(zre) + abs(zim) > threshold) break;
    n++;
  }

  if (n == iterations) {
    fragColor = vec4(0, 0, 0, 1);
  } else {
    fragColor = vec4(n / iterations, n / iterations, n / iterations, 1);
  }
}

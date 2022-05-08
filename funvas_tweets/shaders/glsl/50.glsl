#version 460

precision mediump float;
layout(location = 0) out vec4 fragColor;
layout(location = 0) uniform vec2 res;
layout(location = 1) uniform float t;

const float iterations = 700;
const float threshold = 16;

const vec2 zoomPoint = vec2(-0.761574,-0.0847596);
const vec2 reRange = vec2(-2, 1);
const vec2 imRange = vec2(-1.5, 1.5);

// HSL conversion from https://www.shadertoy.com/view/XljGzV.
vec3 hsl2rgb(in vec3 c) {
  vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
  return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

void main() {
  float scale = pow(2, mod(t, 14)) - 0.5;

  vec2 rel = gl_FragCoord.xy / res.xy;
  rel -= vec2(0.5);
  rel /= scale;
  rel += vec2(0.5);

  vec2 center = vec2(reRange.y + reRange.x, imRange.y + imRange.x) / 2.0;
  vec2 offset = zoomPoint - center;

  float re = reRange.x + (reRange.y - reRange.x) * rel.x + offset.x;
  float im = imRange.x + (imRange.y - imRange.x) * rel.y + offset.y;

  float n = 0;
  float zre = re, zim = im;
  for(float tn = 1; tn <= iterations; tn++) {
    float tzre = zre * zre - zim * zim + re;
    zim = 2 * zre * zim + im;
    zre = tzre;

    n = tn;
    if (abs(zre) + abs(zim) > threshold) {
      break;
    }
  }

  if (n == iterations) {
    fragColor = vec4(0, 0, 0, 1);
  } else {
    vec3 hsl = vec3(n / 100, .9, .6);
    vec3 rgb = hsl2rgb(hsl);
    fragColor = vec4(rgb, 1);
  }
}

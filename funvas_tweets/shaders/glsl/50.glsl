#version 460

precision mediump float;
layout(location = 0) out vec4 fragColor;
layout(location = 0) uniform vec2 res;
layout(location = 1) uniform float t;

const float iterations = 200;
const float threshold = 16;

const vec2 zoomPoint = vec2(-1.74999841099374081749002483162428393452822172335808534616943930976364725846655540417646727085571962736578151132907961927190726789896685696750162524460775546580822744596887978637416593715319388030232414667046419863755743802804780843375, -0.00000000000000165712469295418692325810961981279189026504290127375760405334498110850956047368308707050735960323397389547038231194872482690340369921750514146922400928554011996123112902000856666847088788158433995358406779259404221904755);
const vec2 reRange = vec2(-2, 1);
const vec2 imRange = vec2(-1.5, 1.5);

// HSL conversion from https://www.shadertoy.com/view/XljGzV.
vec3 hsl2rgb(in vec3 c) {
  vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
  return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

void main() {
  vec2 rel = gl_FragCoord.xy / res.xy;

  float width = reRange.y - reRange.x;
  float height = imRange.y - imRange.x;
//   float zoomedWidth = width / (0.5 + mod(t, 5));
//   float zoomedHeight = height / (0.5 + mod(t, 5));
  float zoomedWidth = width, zoomedHeight = height;
  float rl = zoomPoint.x - zoomedWidth / 2;
  float rt = zoomPoint.y - zoomedHeight / 2;
  float rr = zoomPoint.x + zoomedWidth / 2;
  float rb = zoomPoint.y + zoomedHeight / 2;

  float re = reRange.x + (reRange.y - reRange.x) * rel.x;
  float im = imRange.x + (imRange.y - imRange.x) * rel.y;

  float n = 0;
  float zre = re, zim = im;
  for(float tn = 1; tn <= iterations; tn++) {
    float tzre = zre * zre - zim * zim + re;
    zim = 2 * zre * zim + im;
    zre = tzre;

    n = tn;
    if (abs(zre) + abs(zim) > threshold)
      break;
  }

  if (n == iterations) {
    fragColor = vec4(0, 0, 0, 1);
  } else {
    vec3 hsl = vec3(n / iterations, .9, .6);
    vec3 rgb = hsl2rgb(hsl);
    fragColor = vec4(rgb, 1);
  }
}

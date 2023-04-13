precision highp float;
//动画时间
varying lowp vec2 textureCoordinate;
uniform sampler2D texture0;
uniform sampler2D texture1;

uniform float progress;


uniform float strength; // = 0.5
vec4 getFromColor(vec2 fromUv) {
    return texture2D(texture0, fromUv);
}
vec4 getToColor(vec2 toUv) {
    return texture2D(texture1, toUv);
}

//vec4 transition (vec2 p) {
//  float pr = smoothstep(-smoothness, 0.0, p.x - progress * (1.0 + smoothness));
//  float s = step(pr, fract(count * p.x));//b>a时返回1，b<a时返回0
//  return mix(getFromColor(p), getToColor(p), s); // x(1-a)+y*a
//}
//




//vec4 transition (vec2 uv) {
//  float displacement = texture2D(displacementMap, uv).r * strength;
//
//  vec2 uvFrom = vec2(uv.x + progress * displacement, uv.y);
//  vec2 uvTo = vec2(uv.x - (1.0 - progress) * displacement, uv.y);
//
//  return mix(
//    getFromColor(uvFrom),
//    getToColor(uvTo),
//    progress
//  );
//}
//

//const  float amplitude = 30.0; // = 30
//const  float speed = 30.0; // = 30

const float count = 8.0; // = 10.0
const float smoothness = 0.5; // = 0.5

vec4 transition (vec2 p) {
  float pr = smoothstep(-smoothness, 0.0, p.x - progress * (1.0 + smoothness));
  float s = step(pr, fract(count * p.x));
  return mix(getFromColor(p), getToColor(p), s);
}


void main(){
    gl_FragColor = transition(textureCoordinate);
}

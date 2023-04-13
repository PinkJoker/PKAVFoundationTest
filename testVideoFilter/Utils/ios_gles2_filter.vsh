precision highp float;

attribute vec4 position;
attribute vec2 texcoord0;
varying vec2 uv0;
uniform mat4 u_VP;
void main() 
{ 
    gl_Position = u_VP * position;
    // gl_Position = sign(vec4(position.xy, 0.0, 1.0));
    uv0 = texcoord0;
    uv0.y = 1.0 - uv0.y;
    // float roratetion = 0.;
    // mat2 rorate = mat2(
    //     cos(roratetion),sin(roratetion),
    //     -sin(roratetion),cos(roratetion)
    // );
    // uv0 = rorate * uv0;
}

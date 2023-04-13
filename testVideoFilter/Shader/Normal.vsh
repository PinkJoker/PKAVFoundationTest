attribute vec3 position;
attribute vec2 inputTextureCoordinate;
varying vec2 textureCoordinate;
uniform mat4 vMatrix;
void main (){
    float preferredRotation = 3.14;
    mat4 rotationMatrix = mat4(-cos(preferredRotation), sin(preferredRotation), 0.0, 0.0,sin(preferredRotation),cos(preferredRotation), 0.0, 0.0,0.0,0.0,1.0,0.0,0.0,0.0, 0.0,1.0);
    gl_Position =  vec4(position,1.0) * vMatrix;
    textureCoordinate = inputTextureCoordinate;
}

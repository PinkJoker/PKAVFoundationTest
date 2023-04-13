attribute vec3 aPosition;
attribute vec2 aCoordinate;
varying vec2 textureCoordinate;

void main (void) {
   
    gl_Position = vec4(aPosition,1.0);
    textureCoordinate = aCoordinate;
}


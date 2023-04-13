precision highp float;
varying vec2 uv0;
#define texCoord uv0

#define BLUR_MOTION 0x1
#define BLUR_SCALE  0x2

uniform float inputHeight;
uniform float inputWidth;

uniform float offset;
uniform float inputRatio;
//uniform float blurStep;
//uniform mat4 u_InvModel;
//uniform vec2 blurDirection;
uniform float texscale;
#define u_InvMat u_InvModel
uniform mat4 u_InvMat;
uniform sampler2D u_InputTex;
uniform sampler2D _MainTex;
uniform float rorate;
#define inputImageTexture _MainTex

uniform vec2 inputSize;

const float PI = 3.141592653589793;

uniform float swing_index;

/* random number between 0 and 1 */
float random(in vec3 scale, in float seed) {
    /* use the fragment position for randomness */
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}

vec4 crossFade(in vec2 uv, in float dissolve) {
    return texture2D(inputImageTexture, uv).rgba;
}


void transformInvert(inout vec2 uv) {
    float ratio = inputWidth / inputHeight;
    uv = (u_InvMat * vec4((uv.x * 2.0 - 1.0) * ratio, uv.y * 2.0 - 1.0, 0.0, 1.0)).xy;
    uv.x = (uv.x / ratio + 1.0) / 2.0;
    uv.y = (uv.y + 1.0) / 2.0;
}

void main() {

    float ratio = inputWidth / inputHeight;
    
    vec2 uv = uv0;

    transformInvert(uv);
    uv -= 0.5;
    uv.y = mix(uv.y,uv.y/ratio,step(0.99,inputRatio));
    uv.x = mix(uv.x*ratio,uv.x,step(0.99,inputRatio));
    uv+=0.5;
    //gl_FragColor = texture2D(inputImageTexture,uv);
    ///return;
    float roratetion = rorate * PI / 180.;
    mat2 roratemat = mat2(
        cos(roratetion),sin(roratetion),
        -sin(roratetion),cos(roratetion)
    );
    vec2 uv1 = uv;
    uv.x+=offset;
    uv1.x-=offset;
    //uv.x = mix(uv.x,uv1.x,step(1.,uv.x));
    uv-=0.5;
    // uv = roratemat * uv;
    uv = roratemat * uv;
    uv *= (1./(texscale+0.00001));
    uv.y = mix(uv.y,uv.y*inputRatio,step(0.99,inputRatio));
    uv.x = mix(uv.x/inputRatio,uv.x,step(0.99,inputRatio));
    uv+=0.5;


    uv1-=0.5;
    // uv1.y = mix(uv1.y,uv1.y/ratio,step(1.,inputRatio));
    // uv1.x = mix(uv1.x*ratio,uv1.x,step(1.,inputRatio));
    uv1 = roratemat * uv1;
    uv1 *= (1./(texscale+0.00001));
    uv1.y = mix(uv1.y,uv1.y*inputRatio,step(0.99,inputRatio));
    uv1.x = mix(uv1.x/inputRatio,uv1.x,step(0.99,inputRatio));
    uv1+=0.5;

    // uv -= 0.5;
    // if(inputHeight > inputWidth)
    //     uv.y *= (inputSize.y/inputSize.x) * (inputWidth/inputHeight);
    // else
    //     uv.x *= (inputSize.x/inputSize.y) * (inputHeight/inputWidth);
    // uv += 0.5;

    // uv1 -= 0.5;
    // if(inputHeight > inputWidth)
    //     uv1.y *= (inputSize.y/inputSize.x) * (inputWidth/inputHeight);
    // else
    //     uv1.x *= (inputSize.x/inputSize.y) * (inputHeight/inputWidth);
    // uv1 += 0.5;

    if(swing_index>0.5){
        uv1.y = 1.-uv1.y;
        uv.y = 1.-uv.y;
    }

    vec4 resultColor = texture2D(inputImageTexture, uv) * step(0.,uv.x)*(1.-step(1.,uv.x))*step(0.,uv.y)*(1.-step(1.,uv.y));
    vec4 resultColor1 = texture2D(inputImageTexture, uv1) * step(0.,uv1.x)*(1.-step(1.,uv1.x))*step(0.,uv1.y)*(1.-step(1.,uv1.y));
	gl_FragColor = resultColor*(1.-resultColor1.a)+resultColor1;

   //gl_FragColor *= step(0.,uv.x)*(1.-step(1.,uv.x))*step(0.,uv.y)*(1.-step(1.,uv.y));
}

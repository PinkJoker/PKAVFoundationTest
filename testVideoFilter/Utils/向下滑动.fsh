precision highp float;
//#iChannel0 "file://image/ren1.jpg"
varying lowp vec2 textureCoordinate;
uniform vec2 renderTexture;
uniform float iTime;
//贝塞尔曲线 三次方公式
vec2 lm_cubic_bezier(vec2 p0, vec2 p1, vec2 p2, vec2 p3,float t)
{
    float t_inv = 1.0-t;
    float t_inv_2 = pow(t_inv,2.0);
    float t_inv_3 = pow(t_inv,3.0);
    float t_2 = pow(t,2.0);
    float t_3 = pow(t,3.0);
    vec2 p = p0*t_inv_3+3.0*p1*t*t_inv_2+3.0*p2*t_2*t_inv+p3*t_3;
    return p;
}

//不透明度
float getAlpha(float p)
{
    vec2 xp0 = vec2(0.0);
    vec2 xp3 = vec2(1.0);
    vec2 xp1 = vec2(0.0, 0.0);
    vec2 xp2 = vec2(1.0, 1.0);
    vec2 bezier = lm_cubic_bezier(xp0, xp1, xp2, xp3, p);
    return clamp(bezier.y, 0.0, 1.0);

}

//方向
float getDirection(float p)
{
    vec2 xp0 = vec2(0.0);
    vec2 xp3 = vec2(1.0);
    vec2 xp1 = vec2(0.39, 0.575);
    vec2 xp2 = vec2(0.565, 1.0);
    vec2 bezier = lm_cubic_bezier(xp0, xp1, xp2, xp3, p);
    return clamp(bezier.y, 0.0, 1.0);
}

float duration = 1.3;
void main()
{

    vec2 uv = gl_FragCoord.xy / renderTexture.xy;
    float progress =  mod(iTime / duration , 1.0);
    float _alpha = 1.0;
    if (progress <= 0.2)
    {
        _alpha = getAlpha(progress * 5.0);
    }
    uv.y = uv.y + 0.5 + 0.5 * getDirection(progress); 
    vec4 resultColor = texture2D(textureCoordinate, uv) * step(1.0, uv.y) ;
    gl_FragColor = resultColor * _alpha ;
}

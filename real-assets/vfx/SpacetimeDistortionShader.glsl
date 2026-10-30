// Mora GIDE 2026 - 时空扭曲与引力透镜冲击波着色器 (Spacetime Distortion & Gravitational Lensing Shader)
// 适配: GLSL ES 3.0 / WebGL / GameMaker 2026 FX / Unity URP ShaderLab / Unreal Custom HLSL Node

#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D u_screenTexture; // 屏幕画面纹理
uniform vec2 u_center;            // 扭曲中心点 (归一化 UV: 0.0 ~ 1.0)
uniform float u_time;             // 当前时间 (秒)
uniform float u_progress;         // 扩散进度 (0.0 ~ 1.0)
uniform float u_shockwaveRadius;  // 冲击波波前半径
uniform float u_distortionPower;  // 时空扭曲折射强度 (默认 0.08)
uniform float u_aberration;       // 色相色散偏移 (RGB 时空撕裂色差)

varying vec2 v_uv;

void main() {
    vec2 uv = v_uv;
    vec2 dir = uv - u_center;
    float dist = length(dir);
    
    // 1. 计算时空引力震荡环带衰减
    float waveDist = abs(dist - u_shockwaveRadius);
    float ringWidth = 0.08;
    
    vec2 offset = vec2(0.0);
    if (dist < u_shockwaveRadius + ringWidth && dist > u_shockwaveRadius - ringWidth) {
        float wave = sin((dist - u_shockwaveRadius) / ringWidth * 3.14159265);
        float decay = 1.0 - smoothstep(0.0, 1.0, u_progress);
        offset = normalize(dir) * wave * u_distortionPower * decay;
    }
    
    // 2. 引力黑洞核心奇点坍缩吸积扭曲
    float blackholeRadius = 0.05 * (1.0 - u_progress);
    if (dist < blackholeRadius) {
        float pull = (1.0 - dist / blackholeRadius) * 0.15;
        offset -= normalize(dir) * pull;
    }
    
    // 3. 伴随色散 (Chromatic Aberration) 时空撕裂特效
    float r = texture2D(u_screenTexture, uv + offset * (1.0 + u_aberration)).r;
    float g = texture2D(u_screenTexture, uv + offset).g;
    float b = texture2D(u_screenTexture, uv + offset * (1.0 - u_aberration)).b;
    
    gl_FragColor = vec4(r, g, b, 1.0);
}

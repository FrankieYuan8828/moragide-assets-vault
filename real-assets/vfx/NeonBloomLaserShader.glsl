// Mora GIDE 2026 - 霓虹激光与高能光束着色器 (Neon Bloom Laser & High-Energy Beam Shader)
// 适配: GLSL ES 3.0 / WebGL / GameMaker 2026 FX / Unity URP / Unreal Custom Node
#ifdef GL_ES
precision highp float;
#endif

uniform float u_time;              // 时间 (秒)
uniform vec2 u_resolution;         // 视口分辨率
uniform vec3 u_laserColor;         // 激光主霓虹色 (如 vec3(0.1, 0.85, 1.0) 赛博青, 或 vec3(1.0, 0.2, 0.8) 霓虹粉)
uniform vec3 u_coreColor;          // 核心超能白光 (通常 vec3(1.0, 1.0, 1.0))
uniform float u_beamWidth;         // 光束宽度 (0.01 ~ 0.2)
uniform float u_glowIntensity;     // 霓虹光晕强度 (1.0 ~ 4.0)
uniform float u_pulseSpeed;        // 高能等离子脉冲速度 (默认 8.0)

varying vec2 v_uv;

void main() {
    vec2 uv = v_uv;
    
    // 激光中心轴对齐 (假设光束沿水平方向穿行，垂直为 Y 距离)
    float distFromAxis = abs(uv.y - 0.5);
    
    // 1. 核心白光能量束 (Core Beam)
    float core = smoothstep(u_beamWidth * 0.25, 0.0, distFromAxis);
    
    // 2. 霓虹色辉光过渡 (Neon Exponential Glow Falloff)
    float glow = exp(-distFromAxis * (12.0 / u_beamWidth)) * u_glowIntensity;
    
    // 3. 等离子高能纵向脉冲波纹 (Plasma Energy Wavelets)
    float energyPulse = sin(uv.x * 40.0 - u_time * u_pulseSpeed) * 0.15 + 0.85;
    float highFreqNoise = sin(uv.x * 120.0 + u_time * 24.0) * 0.05;
    
    // 4. 激光头部聚焦光斑扩散
    float headSpark = smoothstep(0.05, 0.0, length(uv - vec2(0.95, 0.5))) * 2.0;
    
    // 5. 颜色合成 (HDR 乘法与加法叠加)
    vec3 finalColor = u_laserColor * (glow * (energyPulse + highFreqNoise));
    finalColor += u_coreColor * core * 1.5;
    finalColor += u_laserColor * headSpark;
    
    float alpha = clamp(glow + core * 1.2 + headSpark, 0.0, 1.0);
    gl_FragColor = vec4(finalColor, alpha);
}

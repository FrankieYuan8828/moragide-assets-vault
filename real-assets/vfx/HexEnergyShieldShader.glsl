// Mora GIDE 2026 - 六边形蜂巢护盾与受击震荡着色器 (Hexagonal Energy Shield & Hit Ripple Shader)
// 适配: GLSL ES 3.0 / Unity URP / Godot 4 Spatial / WebGL Three.js
#ifdef GL_ES
precision highp float;
#endif

uniform float u_time;               // 时间 (秒)
uniform vec3 u_shieldColor;         // 护盾主色 (如 vec3(0.0, 0.95, 1.0) 能量青蓝)
uniform vec2 u_hitPoint;            // 受击命中点 UV (0.0 ~ 1.0)
uniform float u_hitTime;            // 受击触发衰减进度 (0.0 ~ 1.0)
uniform float u_hexScale;           // 六边形网格缩放密度 (默认 28.0)

varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_viewDir;

// 程序化六边形网格距离场 (Procedural Hexagon SDF)
float hexDist(vec2 p) {
    p = abs(p);
    float c = dot(p, normalize(vec2(1.0, 1.7320508)));
    return max(c, p.x);
}

void main() {
    vec2 st = v_uv * u_hexScale;
    
    // 六边形晶格采样偏移
    vec2 r = vec2(1.0, 1.7320508);
    vec2 h = r * 0.5;
    vec2 a = mod(st, r) - h;
    vec2 b = mod(st - h, r) - h;
    vec2 gv = dot(a, a) < dot(b, b) ? a : b;
    
    float hexEdge = smoothstep(0.48, 0.50, hexDist(gv));
    
    // 菲涅尔边缘光晕 (Rim Glow)
    float fresnel = 0.0;
    #ifdef HAS_NORMALS
    fresnel = pow(1.0 - clamp(dot(v_normal, v_viewDir), 0.0, 1.0), 3.0);
    #else
    fresnel = pow(abs(v_uv.x - 0.5) * 2.0, 2.0) * 0.5;
    #endif
    
    // 受击同心震荡涟漪 (Hit Ripple Shockwave)
    float dHit = length(v_uv - u_hitPoint);
    float ripple = sin(dHit * 45.0 - u_hitTime * 20.0) * exp(-dHit * 4.0) * (1.0 - u_hitTime);
    ripple = clamp(ripple, 0.0, 1.0);
    
    // 能量流转脉冲
    float pulse = sin(u_time * 2.5 + v_uv.y * 8.0) * 0.15 + 0.85;
    
    // 最终颜色合成
    float alpha = hexEdge * 0.45 + fresnel * 0.7 + ripple * 1.5;
    alpha = clamp(alpha * pulse, 0.0, 1.0);
    vec3 col = u_shieldColor * (1.0 + ripple * 2.0);
    
    gl_FragColor = vec4(col, alpha);
}

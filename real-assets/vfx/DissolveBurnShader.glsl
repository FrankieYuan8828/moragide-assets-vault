// Mora GIDE 2026 - 灰烬消融与燃烧边缘着色器 (Dissolve & Burning Embers Rim Shader)
// 适配: GLSL ES 3.0 / Unity URP ShaderLab / Godot 4 Shader / GameMaker 2026 FX
#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D u_mainTexture;    // 主材质漫反射纹理
uniform sampler2D u_noiseTexture;   // 灰度噪声/溶解蒙版贴图 (Perlin / Voronoi)
uniform float u_dissolveProgress;   // 溶解进度 (0.0 完整 ~ 1.0 完全消融)
uniform float u_edgeWidth;          // 燃烧边缘宽度 (默认 0.05)
uniform vec3 u_burnColorInner;      // 燃烧内沿超白金光 (如 vec3(1.0, 0.9, 0.3))
uniform vec3 u_burnColorOuter;      // 燃烧外沿熔岩赤红 (如 vec3(1.0, 0.15, 0.02))

varying vec2 v_uv;

void main() {
    vec4 baseColor = texture2D(u_mainTexture, v_uv);
    float noiseVal = texture2D(u_noiseTexture, v_uv).r;
    
    // 1. 溶解透明度剔除剪裁
    if (noiseVal < u_dissolveProgress) {
        discard; // 像素已彻底烧尽
    }
    
    // 2. 燃烧余烬光晕带计算
    float edgeDist = noiseVal - u_dissolveProgress;
    if (edgeDist < u_edgeWidth) {
        float edgeFactor = edgeDist / u_edgeWidth; // 0.0 (最外缘) -> 1.0 (内部过渡)
        vec3 emberColor = mix(u_burnColorInner * 2.2, u_burnColorOuter * 1.5, edgeFactor);
        gl_FragColor = vec4(emberColor, baseColor.a);
        return;
    }
    
    // 3. 未被消融区域正常渲染
    gl_FragColor = baseColor;
}

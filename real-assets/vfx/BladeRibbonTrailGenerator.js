/**
 * Mora GIDE 2026 - 挥刀刀锋与剑气轨迹几何体生成器 (Blade Ribbon Trail & Sword Arc Generator)
 * 适配引擎: WebGL / Three.js / GameMaker 2026 GML / Unity Mesh / Unreal Procedural Mesh
 */

class BladeRibbonTrailGenerator {
  /**
   * 生成弯月剑气弧光顶点网格 (Sword Aura Crescent Arc Mesh)
   * @param {Object} opts 参数配置
   * @param {number} opts.radius 外弧半径 (默认 120px / 1.2m)
   * @param {number} opts.arcAngle 弧度张角 (默认 Math.PI * 0.75, 即 135 度)
   * @param {number} opts.bladeThickness 刀气中心厚度 (默认 28px)
   * @param {number} opts.segments 细分段数 (默认 32 段平滑曲线)
   * @param {string} opts.auraColorHex 剑气基准色 (十六进制，如 "#38bdf8" 破空冰蓝)
   */
  static generateSwordAuraMesh(opts = {}) {
    const {
      radius = 120,
      arcAngle = Math.PI * 0.75,
      bladeThickness = 28,
      segments = 32,
      auraColorHex = '#38bdf8'
    } = opts;

    const vertices = []; // x, y, z
    const uvs = [];      // u, v (0..1)
    const colors = [];   // r, g, b, a
    const indices = [];

    const startAngle = -arcAngle / 2;
    const step = arcAngle / segments;

    for (let i = 0; i <= segments; i++) {
      const t = i / segments; // 0 (刀尖尾部) -> 0.5 (刀身正中) -> 1.0 (前锋冲击点)
      const angle = startAngle + i * step;

      // 弧形中间厚两头尖 (抛物线厚度衰减)
      const currentThickness = Math.sin(t * Math.PI) * bladeThickness;

      // 外弧点 (剑气外缘锋刃)
      const rOuter = radius + currentThickness * 0.5;
      const xOuter = Math.cos(angle) * rOuter;
      const yOuter = Math.sin(angle) * rOuter;

      // 内弧点 (剑气内缘尾迹)
      const rInner = radius - currentThickness * 0.5;
      const xInner = Math.cos(angle) * rInner;
      const yInner = Math.sin(angle) * rInner;

      // 透明度与发光强度衰减
      const alpha = Math.pow(Math.sin(t * Math.PI), 0.65);

      // 外刃顶点 (UV y = 0.0)
      vertices.push(xOuter, yOuter, 0);
      uvs.push(t, 0.0);
      colors.push(1.0, 1.0, 1.0, alpha); // 外刃白热化核心

      // 内刃顶点 (UV y = 1.0)
      vertices.push(xInner, yInner, 0);
      uvs.push(t, 1.0);
      colors.push(0.2, 0.7, 1.0, alpha * 0.4); // 内侧霓虹幽光衰减

      // 三角网格拓扑索引 (Quad -> 2 Triangles)
      if (i < segments) {
        const base = i * 2;
        indices.push(base, base + 1, base + 2);
        indices.push(base + 1, base + 3, base + 2);
      }
    }

    return {
      type: 'SwordAuraMesh',
      vertexCount: vertices.length / 3,
      triangleCount: indices.length / 3,
      vertices,
      uvs,
      colors,
      indices
    };
  }

  /**
   * 导出为 GameMaker 2026 GML 实时绘制脚本代码
   */
  static exportToGameMakerGML(meshData, spriteName = 'spr_vfx_blade_slash') {
    let gml = `/// @function draw_vfx_blade_ribbon(x, y, angle, scale)\n`;
    gml += `var _x = argument0, _y = argument1, _ang = argument2, _scale = argument3;\n`;
    gml += `var _tex = sprite_get_texture(${spriteName}, 0);\n`;
    gml += `draw_primitive_begin_texture(pr_trianglelist, _tex);\n`;

    for (let idx of meshData.indices) {
      const vOffset = idx * 3;
      const uvOffset = idx * 2;
      const colOffset = idx * 4;
      const vx = meshData.vertices[vOffset];
      const vy = meshData.vertices[vOffset + 1];
      const u = meshData.uvs[uvOffset];
      const v = meshData.uvs[uvOffset + 1];
      const a = meshData.colors[colOffset + 3];

      gml += `draw_vertex_texture_colour(_x + lengthdir_x(${vx} * _scale, _ang) - lengthdir_y(${vy} * _scale, _ang), `;
      gml += `_y + lengthdir_y(${vx} * _scale, _ang) + lengthdir_x(${vy} * _scale, _ang), `;
      gml += `${u.toFixed(3)}, ${v.toFixed(3)}, c_white, ${a.toFixed(2)});\n`;
    }

    gml += `draw_primitive_end();\n`;
    return gml;
  }
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = BladeRibbonTrailGenerator;
}

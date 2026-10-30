/**
 * Mora GIDE 2026 - Effekseer 跨引擎通用特效全能桥接器 (Effekseer Omni Bridge)
 * 专为跨引擎（GameMaker 2026 / Unity 6 / Unreal 5.5 / Godot 4 / WebGL）特效互通设计
 * 官方源码库: https://github.com/FrankieYuan8828/Effekseer
 */

class EffekseerOmniBridge {
  static get VERSION() {
    return '2026.1.5';
  }

  /**
   * 解析 Effekseer 二进制特效文件元数据
   */
  static inspectEfkefc(buffer) {
    const view = new DataView(buffer);
    const magic = String.fromCharCode(view.getUint8(0), view.getUint8(1), view.getUint8(2), view.getUint8(3));
    if (magic !== 'EFEK') {
      return { valid: false, error: '非合法 Effekseer 二进制特效文件 (缺少 EFEK 魔数)' };
    }
    const version = view.getInt32(4, true);
    return {
      valid: true,
      magic,
      version,
      format: 'Effekseer Compiled Effect (.efkefc)',
      supportedEngines: ['Unity 6', 'Unreal 5.5', 'Godot 4', 'GameMaker 2026', 'WebGL Three.js']
    };
  }

  /**
   * 生成跨引擎集成代码模板
   * @param {string} effectName 特效名称 (如 "LaserSwordSlash")
   * @param {string} targetEngine 目标引擎 ('unity' | 'unreal' | 'godot' | 'gamemaker' | 'threejs')
   */
  static generateIntegrationCode(effectName, targetEngine = 'unity') {
    switch (targetEngine.toLowerCase()) {
      case 'unity':
        return `// Unity 6 C# 挂载脚本
using UnityEngine;
using Effekseer;

public class ${effectName}Controller : MonoBehaviour {
    public EffekseerEffectAsset effectAsset;
    private EffekseerHandle handle;

    public void PlayVFX(Vector3 position, Quaternion rotation) {
        handle = EffekseerSystem.PlayEffect(effectAsset, position);
        handle.SetRotation(rotation);
        handle.SetScale(Vector3.one);
    }
    public void StopVFX() => handle.Stop();
}`;

      case 'unreal':
        return `// Unreal Engine 5.5 C++ / Blueprints 绑定
// 引用插件: FrankieYuan8828/Effekseer/UnrealEngine
#include "EffekseerSystemComponent.h"

void AGameCharacter::Spawn${effectName}VFX(FVector Location, FRotator Rotation) {
    UEffekseerEffect* LoadedEffect = LoadObject<UEffekseerEffect>(nullptr, TEXT("/Game/VFX/${effectName}.${effectName}"));
    if (LoadedEffect) {
        UEffekseerSystemComponent::PlayEffectAtLocation(GetWorld(), LoadedEffect, Location, Rotation);
    }
}`;

      case 'godot':
        return `# Godot 4 GDScript 挂载 (使用 GDExtension godot-effekseer)
extends Node3D

@onready var effekseer_emitter = $EffekseerEmitter3D

func play_${effectName.toLowerCase()}_vfx():
    if effekseer_emitter:
        effekseer_emitter.play()
`;

      case 'gamemaker':
        return `/// GameMaker 2026 GML 脚本: scr_play_${effectName.toLowerCase()}
function play_${effectName.toLowerCase()}(_x, _y, _angle) {
    // 自动桥接 Effekseer 渲染纹理序列
    var _inst = instance_create_layer(_x, _y, "VFX_Layer", obj_vfx_effekseer_runner);
    _inst.effect_id = "${effectName}";
    _inst.image_angle = _angle;
    return _inst;
}`;

      default:
        return `// WebGL / Three.js 实时渲染
effekseer.playEffect(loadedEffects["${effectName}"], position.x, position.y, position.z);`;
    }
  }
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = EffekseerOmniBridge;
}

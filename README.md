# dex2oat 全核解锁 (unlock_core_for_dex2oat)

让 MIUI / HyperOS 全核跑 dex2oat(KernelSU / Magisk 模块)。

## 作用

MIUI 的 ART 守护进程 `artd` 决定 dex2oat 能占哪些 CPU 核心时,**只在属性为空时**回退到编译进二进制的硬编码列表:

```
0,1,2,3      (以及 0,1,4,5)
```

也就是说：MIUI 里 dexopt 默认只有前 4 个核干活(一个大核集群 + 一个小核集群),剩下半个 8 核 SoC 全程围观。

本模块做的事很朴素——开机时把这几个属性**主动填满**:

```
dalvik.vm.dex2oat-cpu-set            = 0,1,2,3,4,5,6,7
dalvik.vm.boot-dex2oat-cpu-set       = 0,1,2,3,4,5,6,7
dalvik.vm.background-dex2oat-cpu-set = 0,1,2,3,4,5,6,7
dalvik.vm.restore-dex2oat-cpu-set    = 0,1,2,3,4,5,6,7
dalvik.vm.default-dex2oat-cpu-set    = 0,1,2,3,4,5,6,7
```

`artd` 读到非空,就把 `--cpu-set=0,1,...,7` 原样透传给 dex2oat。

## 性能

- 仅在开机时运行一次，无任何占用。
- 会加速开机状态下系统的dex2oat编译，比如手机放着熄屏充电的时候，它会全速编译，实测在Redmi k60上速度大约提升了100%。本模块适合长期不重启的手机，或者经常安装软件的手机。


## 兼容性

- **ROM**:超 MIUI/HyperOS 对症;AOSP/GSI 属性名本就存在,设了无害(纯惰性);其他魔改 ROM 至多无效果,不炸。
- **ART 版本**:属性名从 Android N 沿用至今(早期 dex2oat 直接读,14+ 由 artd 读),跨版本稳定;未来改名则静默失效,无副作用。
- **核心数**:脚本用 `nproc` 动态生成 `0..n-1`,不写死 8;`system.prop` 里的 `0-7` 只是 init 阶段瞬时备案,开机即被覆盖。
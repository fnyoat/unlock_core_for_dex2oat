#!/system/bin/sh
# unlock_core_for_dex2oat — 让 MIUI/HyperOS 的 dex2oat 用全部核心 + 全部工作线程。
# post-fs-data 阶段一次性、纯因果(喂 artd 真正读的那 5 个属性),无轮询、无循环写盘。
# MIUI 的 artd 对这 5 个属性在"属性为空"时回退到编译进二进制的硬编码 --cpu-set 与 -j 个数;
#  本模块在属性空窗一出现前就填上"全核列表 + 全核线程数",artd 一读即为满配。

n=$(nproc 2>/dev/null)
case "$n" in
  ''|*[!0-9]*) n=8 ;;
esac
[ "$n" -ge 1 ] || n=8

i=0
LIST=
while [ "$i" -lt "$n" ]; do
  if [ -z "$LIST" ]; then LIST="$i"; else LIST="$LIST,$i"; fi
  i=$((i + 1))
done

# CPU 核心集合:全核。
for k in dex2oat boot-dex2oat background-dex2oat restore-dex2oat default-dex2oat; do
  setprop "dalvik.vm.$k-cpu-set" "$LIST"
done

# 工作线程数:与核数一一对应(artd 读 *-dex2oat-threads 决定 -j)。漏掉它则 dex2oat
# 只开 artd 编译进二进制的回退线程数,全核喂了也是空转。一并补齐。
for k in dex2oat boot-dex2oat background-dex2oat restore-dex2oat default-dex2oat image-dex2oat; do
  setprop "dalvik.vm.$k-threads" "$n"
done
setprop ro.sys.fw.dex2oat_thread_count "$n"

T=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
echo "$T [post-fs-data] cores=$n cpu-set=$LIST threads=$n" >> /data/adb/unlock_core_for_dex2oat.log
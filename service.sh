#!/system/bin/sh
# Re-apply the cpu-set properties at late_start in case anything reset them.
n=$(nproc 2>/dev/null)
case "$n" in
  ''|*[!0-9]*) n=8 ;;
esac
[ "$n" -ge 1 ] || n=8
i=0
while [ "$i" -lt "$n" ]; do
  if [ -z "$LIST" ]; then LIST="$i"; else LIST="$LIST,$i"; fi
  i=$((i + 1))
done
for k in dex2oat boot-dex2oat background-dex2oat restore-dex2oat default-dex2oat; do
  setprop "dalvik.vm.$k-cpu-set" "$LIST"
done

echo "$(date '+%Y-%m-%d %H:%M:%S') [service] cores=$n cpu-set=$LIST" >> /data/adb/unlock_core_for_dex2oat.log
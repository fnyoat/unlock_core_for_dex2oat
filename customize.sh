#!/sbin/sh
# You can overwrite the creatEvent here; this is the dynamic part of a
# KernelSU/Magisk module. Post-fs-data + service scripts do the actual work.

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=true

ui_print "- [unlock_core_for_dex2oat] preparing"
PY=$(getprop sys.boot_completed)
ui_print "- artd will use all cores + nproc threads"

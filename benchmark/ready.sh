#!/bin/sh

echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
echo 0 > /proc/sys/kernel/perf_event_paranoid

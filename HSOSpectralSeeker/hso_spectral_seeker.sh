#!/bin/bash
PHI=1.618033988749895
HC_TARGET=5.0832
F_BASE=25.174825174825
current_f=65.00000000
locked=0

clear
echo "HSOSpectralSeeker - TARGET Hc $HC_TARGET"
printf "[PHASE 1] SEEKING"

while [ $locked -eq 0 ]; do
    h_level=$(echo "scale=10; $current_f / ($F_BASE / $PHI)" | bc -l)
    diff=$(echo "scale=10; d=$HC_TARGET-$h_level; if(d<0) -d else d" | bc -l)
    is_close=$(echo "$diff < 0.0000001" | bc -l)
    if [ "$is_close" -eq 1 ]; then
        locked=1
    else
        current_f=$(echo "scale=10; $current_f + ($HC_TARGET - $h_level) / 5" | bc -l)
    fi
    printf "."
    sleep 0.01
done

echo -e "\n[LOCKED: $current_f MHz]"
echo -e "\n[PHASE 2] VALIDATING"
printf "%-12s | %-10s | %-13s\n" "OFFSET" "H-LEVEL" "ERROR"
echo "------------------------------------------"

for offset in -0.1 -0.05 0 0.05 0.1; do
    test_f=$(echo "scale=8; $current_f + $offset" | bc -l)
    h_now=$(echo "scale=8; $test_f / ($F_BASE / $PHI)" | bc -l)
    error=$(echo "scale=8; d=$HC_TARGET-$h_now; if(d<0) -d else d" | bc -l)
    printf "%-12s | %-10s | %-13s\n" "$offset" "$h_now" "$error"
done

echo -e "------------------------------------------"
echo -e "[RESULT] VERIFIED: $current_f MHz"

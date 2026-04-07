#!/bin/bash

files=(
"../DCache/pkg/DCache_common_pkg.sv"
"../ICache/pkg/ICache_common_pkg.sv"
"../pkgs/types_pkg.sv"
"../pkgs/common_pkg.sv"
"../pkgs/interconnect_pkg.sv"
"../io/pkg/io_common_pkg.sv"
"../BusArbitration/pkg/DTE_FSM_gen_pkg.sv"
"../BusArbitration/pkg/BusArbitration_common_pkg.sv"
"../core/Fetch/pkg/Fetch_pkg.sv"
"../core/Fetch/Predictor/Predictor_pkg.sv"
"../core/TLB/pkg/TLB_pkg.sv"
"../core/WB/pkg/WriteBack_pkg.sv"
"../core/pkgs/control_store_pkg.sv"
"../core/pkgs/core_stage_latches_pkg.sv"
"../core/pkgs/reg_ids_pkg.sv"
"../core/pkgs/core_common_pkg.sv"
"../core/SegmentTranslation/SegmentTranslation_pkg.sv"
"../core/DC/pkg/DC_pkg.sv"
"../core/Decode/pkg/Decode_pkg.sv"
"../core/RR/pkg/RegisterRead_pkg.sv"
"../core/IDM/pkg/IDM_pkg.sv"
"../mem/pkg/mem_common_pkg.sv"
)

for file in "${files[@]}"; do
    # Extract filename without path
    base=$(basename "$file")

    # Remove _pkg.sv and replace with _define.vh
    out="${base/_pkg.sv/_define.vh}"

    echo "Converting $file -> $out"

    python3 ./convert.py "$file" "$out"
done

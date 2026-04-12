# wave_groups.tcl — organize VPD signals into groups for DVE
# Usage:  dve -vpd sim.vpd -script wave_groups.tcl
#   or:   source wave_groups.tcl   (inside an active DVE session)

# ── Configuration ────────────────────────────────────────────────
set vpd_file  "vcdplus.vpd"
set top       "/tb_stages"

# ── Open database ────────────────────────────────────────────────

# Get the wave window (open one if none exists)
set wins [gui_get_window_id -type Wave]
set win  [expr {[llength $wins] ? [lindex $wins 0] : [gui_open_window Wave]}]

# ── Helper: add a named group then its signals ────────────────────
proc add_group {win name signals} {
    gui_wv_add $win -group $name
    foreach sig $signals {
        gui_wv_add $win -sig $sig
    }
}

# ── Signal groups — edit to match your design ────────────────────
add_group $win "Core" [list \
    $top/uut_core/rst        \
    $top/uut_core/clk      \
]

# ── Fit view to full simulation time ─────────────────────────────
gui_wv_zoom_fit -win $win
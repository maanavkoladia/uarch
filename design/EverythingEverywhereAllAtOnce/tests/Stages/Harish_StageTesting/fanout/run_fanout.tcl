set target_library ""
set link_library "*"


# set __top_module__  "Decode"
# set __masterfile__  "./tbs/decode/master.txt"

set __top_module__  "AllAtOnce_TOP"
set __masterfile__  "./tbs/allAtOnce/master.txt.maanav"

define_design_lib WORK -path ./WORK

set f [open "$__masterfile__" r]
set files [split [read $f] "\n"]
close $f
# strip blanks/comments
set files [lsearch -all -inline -not -regexp $files {^\s*(#.*)?$}]

read_file -format verilog [lindex $files 0]
analyze -format verilog [lrange $files 1 end]
elaborate $__top_module__

current_design $__top_module__
link

source fanout.tcl
fanout_check -print_loads -print_only violation
#fanout_check
exit

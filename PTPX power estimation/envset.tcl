#####################################################
#Read design data & technology
#####################################################

set CURRENT_PATH [pwd]
set TOP_DESIGN mul_arr

set search_path [list \
					"$CURRENT_PATH" \
				]

## Add libraries below
## technology .db file, and memory .db files
set target_library ""

set LINK_PATH [concat  "*" $target_library]

## Replace with your complete file paths
set SDC_FILE      	$CURRENT_PATH/$TOP_DESIGN.sdc
set NETLIST_FILE	$CURRENT_PATH/$TOP_DESIGN.vg

## Replace with your instance hierarchy
set STRIP_PATH    testbench/mul_arr0

## Replace with your activity file dumped from vcs simulation
set ACTIVITY_FILE 	$CURRENT_PATH/$TOP_DESIGN.vcd

######## Timing Sections ########
set	START_TIME 50
set	END_TIME 1800

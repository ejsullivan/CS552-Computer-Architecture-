echo "********** CS552 Reading files begin ********************"
set my_verilog_files [list alu.v cache.v claAdder16.v claAdder1bit.v claAdder4bit.v claUnit4bit.v control_unit.v decode_unit.v dff.v execute_unit.v fetch_unit.v final_memory.syn.v forwarding_unit.v four_bank_mem.v hazard_unit.v memc.syn.v memory2c_align.syn.v memory2c.syn.v memory_unit.v mem_system_ref.v mem_system.v memv.syn.v nand2.v nor2.v not1.v proc.v reg_EX_MEM.v reg_ID_EX.v reg_IF_ID.v register.v reg_MEM_WB.v rf_bypass.v rf.v shifter.v stallmem.syn.v statereg.v writeback_unit.v xor2.v  ]
set my_toplevel proc
define_design_lib WORK -path ./WORK
analyze -f verilog $my_verilog_files
elaborate $my_toplevel -architecture verilog
echo "********** CS552 Reading files end ********************"
current_design proc
#/* The name of the clock pin. If no clock-pin     */
#/* exists, pick anything                          */
set my_clock_pin clk

#/* Target frequency in MHz for optimization       */
set my_clk_freq_MHz 1000

#/* Delay of input signals (Clock-to-Q, Package etc.)  */
set my_input_delay_ns 0.1

#/* Reserved time for output signals (Holdtime etc.)   */
set my_output_delay_ns 0.1


#/**************************************************/
#/* No modifications needed below                  */
#/**************************************************/
set verilogout_show_unconnected_pins "true"


# analyze -f verilog $my_verilog_files
# elaborate $my_toplevel -architecture verilog
# current_design $my_toplevel

report_hierarchy 
link
uniquify

set my_period [expr 1000 / $my_clk_freq_MHz]

set find_clock [ find port [list $my_clock_pin] ]
if {  $find_clock != [list] } {
   set clk_name $my_clock_pin
   create_clock -period $my_period $clk_name
} else {
   set clk_name vclk
   create_clock -period $my_period -name $clk_name
} 

set_driving_cell  -lib_cell INVX1  [all_inputs]
set_input_delay $my_input_delay_ns -clock $clk_name [remove_from_collection [all_inputs] $my_clock_pin]
set_output_delay $my_output_delay_ns -clock $clk_name [all_outputs]

compile -map_effort low  -area_effort low

check_design -summary
report_constraint -all_violators

set filename [format "%s%s"  $my_toplevel ".syn.v"]
write -hierarchy -f verilog $my_toplevel -output synth/$filename
set filename [format "%s%s"  $my_toplevel ".ddc"]
write -hierarchy -format ddc -output synth/$filename

report_reference > synth/reference_report.txt
report_area > synth/area_report.txt
report_cell > synth/cell_report.txt
report_timing -max_paths 20 > synth/timing_report.txt
report_power > synth/power_report.txt

quit


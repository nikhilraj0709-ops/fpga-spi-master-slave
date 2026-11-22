set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir ".."]]
set report_dir [file join $repo_root "reports"]
set bit_dir [file join $repo_root "build"]

source [file join $script_dir "create_project.tcl"]

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1

open_run impl_1

report_power -file [file join $report_dir "power_latest.rpt"]
report_timing_summary -file [file join $report_dir "final_timing_latest.rpt"]
report_drc -file [file join $report_dir "final_drc_latest.rpt"]

write_bitstream -force [file join $bit_dir "spi_board_top.bit"]

puts ""
puts "=========================================="
puts "FINAL SPI BITSTREAM GENERATED"
puts "=========================================="

exit

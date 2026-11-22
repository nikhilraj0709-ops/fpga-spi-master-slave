set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir ".."]]
set report_dir [file join $repo_root "reports"]

source [file join $script_dir "create_project.tcl"]

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1

open_run impl_1

report_timing_summary -file [file join $report_dir "timing_summary.rpt"]
report_methodology -file [file join $report_dir "methodology.rpt"]
report_drc -file [file join $report_dir "drc.rpt"]

puts ""
puts "=========================================="
puts "SPI SYNTHESIS + IMPLEMENTATION COMPLETED"
puts "=========================================="

exit

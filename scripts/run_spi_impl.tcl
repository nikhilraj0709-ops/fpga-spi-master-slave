open_project "C:/SPI_PROJECT/spi_industrial_project/spi_industrial_project.xpr"

set_property top spi_board_top [current_fileset]
update_compile_order -fileset sources_1

reset_run synth_1
launch_runs synth_1 -jobs 2
wait_on_run synth_1

reset_run impl_1
launch_runs impl_1 -to_step route_design -jobs 2
wait_on_run impl_1

open_run impl_1

report_timing_summary -file "C:/SPI_PROJECT/spi_industrial_project/timing_summary.rpt"
report_methodology    -file "C:/SPI_PROJECT/spi_industrial_project/methodology.rpt"
report_drc            -file "C:/SPI_PROJECT/spi_industrial_project/drc.rpt"

puts ""
puts "=========================================="
puts "SPI SYNTHESIS + IMPLEMENTATION COMPLETED"
puts "=========================================="

exit

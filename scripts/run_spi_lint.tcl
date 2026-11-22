set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir "create_project.tcl"]

synth_design -top spi_board_top -part xc7s50csga324-1 -lint

puts ""
puts "=========================================="
puts "SPI RTL LINT COMPLETED"
puts "=========================================="

close_project
exit

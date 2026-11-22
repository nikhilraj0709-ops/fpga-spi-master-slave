open_project "C:/SPI_PROJECT/spi_industrial_project/spi_industrial_project.xpr"

set_property top spi_board_top [current_fileset]
update_compile_order -fileset sources_1

synth_design -top spi_board_top -part xc7s50csga324-1 -lint

puts ""
puts "=========================================="
puts "SPI BOARD RTL LINT COMPLETED"
puts "=========================================="

exit

open_project "C:/SPI_PROJECT/spi_industrial_project/spi_industrial_project.xpr"

open_run impl_1

report_power \
    -file "C:/SPI_PROJECT/spi_industrial_project/power.rpt"

report_timing_summary \
    -file "C:/SPI_PROJECT/spi_industrial_project/final_timing.rpt"

report_drc \
    -file "C:/SPI_PROJECT/spi_industrial_project/final_drc.rpt"

write_bitstream \
    -force \
    "C:/SPI_PROJECT/spi_industrial_project/spi_board_top.bit"

puts ""
puts "=========================================="
puts "FINAL SPI BITSTREAM GENERATED"
puts "=========================================="

exit

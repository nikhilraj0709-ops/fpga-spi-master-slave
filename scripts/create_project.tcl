set script_dir [file dirname [file normalize [info script]]]
set repo_root  [file normalize [file join $script_dir ".."]]
set build_dir  [file join $repo_root "build"]

file mkdir $build_dir

create_project -force spi_project $build_dir -part xc7s50csga324-1

add_files [glob -nocomplain [file join $repo_root "rtl" "*.sv"]]
add_files -fileset constrs_1 [file join $repo_root "constraints" "spi_board.xdc"]

set_property top spi_board_top [current_fileset]
update_compile_order -fileset sources_1

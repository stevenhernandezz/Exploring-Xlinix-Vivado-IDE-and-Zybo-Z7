source -notrace ./script/proj_gen.tcl

proc create_target {} {

    variable proj_dict

    set part_name "xc7z010clg400-1"

    # Get the current time as a Unix timestamp
    set currentTime [clock seconds]
    # Format the timestamp into the desired format
    set formattedTime [clock format $currentTime -format {%Y%m%d_%H%M%S}]

    set proj_name "zybo_lab1_${formattedTime}_"

    set origin_dir "."

    # Set project info
    ::proj::set_proj_info   \
        -force              \
        -part  "$part_name" \
        -addr "$origin_dir" \
        -name "$proj_name"

    ::proj::generate_project
    set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]
    # Add source files
    ::proj::create_src_filesets -base_folder $origin_dir

    # Set top module
    set HDL_TOP_MODULE_NAME "top_module"
    ::proj::set_top_wrapper -file_name $HDL_TOP_MODULE_NAME

    # Add mannaged constraint files and set their compilation order
    ::proj::create_constr_filesets -base_folder $origin_dir

    # Add simulation files
    ::proj::create_sim_filesets -base_folder $origin_dir 

    update_compile_order -fileset sources_1

    # Build the project with generic value for clock connections in the top
    # module
    puts "--- Building project"
    ::proj::build_proj

    wait_on_run impl_1

    puts "--- Export bitstream"
    set xil_proj [::proj::get_project_name]
    ::proj::export_proj_bitstream -destination "$origin_dir/build/export_${xil_proj}"

}

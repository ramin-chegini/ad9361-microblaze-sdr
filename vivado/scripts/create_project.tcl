# Recreate the source project with Vivado 2018.3. Generated files stay in build/.
# Usage: vivado -mode batch -source vivado/scripts/create_project.tcl
# Optional: -tclargs <new-output-directory>
set source_dir [file normalize [file join [file dirname [info script]] ..]]
if {[llength $argv] > 1} {
    error "Usage: create_project.tcl ?new-output-directory?"
}
set output_dir [file join $source_dir build ad9361_microblaze]
if {[llength $argv] == 1} {
    set output_dir [file normalize [lindex $argv 0]]
}
if {[file exists $output_dir]} {
    error "Output directory already exists: $output_dir. Choose a new directory."
}
if {![string match "2018.3*" [version -short]]} {
    error "Use Vivado 2018.3 (original design: 2018.3_AR71948); IP migration is not automatic."
}

create_project ad9361_microblaze $output_dir -part xcvu9p-flga2104-2-i
set_property target_language VHDL [current_project]
set_property default_lib xil_defaultlib [current_project]

add_files -norecurse [glob [file join $source_dir rtl *.v]]
set_property top adaloop_top [get_filesets sources_1]

# Import descriptors so generation never rewrites the tracked BD/XCI sources.
# up_axi is an RTL module reference, not an external packaged IP dependency.
import_files -norecurse [file join $source_dir bd system.bd]
foreach ip_name {dds1 ila_0 ila_pulse_gen vio_0} {
    import_ip -files [file join $source_dir ip $ip_name ${ip_name}.xci]
}

# Original synth_1 and impl_1 both selected constrs_2 (the FMC2 pin map).
# Historical alternatives are retained in constraints/legacy but are not loaded.
add_files -fileset constrs_1 -norecurse \
    [file join $source_dir constraints rfmc6000_orihard_FMC2.xdc]
set_property target_constrs_file \
    [file join $source_dir constraints rfmc6000_orihard_FMC2.xdc] \
    [get_filesets constrs_1]

update_compile_order -fileset sources_1
set bd_file [get_files */system.bd]
open_bd_design $bd_file
validate_bd_design
save_bd_design
generate_target all $bd_file
update_compile_order -fileset sources_1
report_ip_status -file [file join $output_dir ip_status.rpt]

puts "Created project: [file join $output_dir ad9361_microblaze.xpr]"
puts "Review vivado/README.md before synthesis or board programming."

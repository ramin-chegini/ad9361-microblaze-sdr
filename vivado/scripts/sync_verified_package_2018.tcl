# Ramin: synchronize this original project's verified wrapper with its local IP.
# Run in Vivado 2018.3. This does not upgrade the BD or touch the main IP_Repo.
if {![string match 2018.3* [version -short]]} {
    error "Use Vivado 2018.3 for this original project and its local IP package."
}
set legacy_root [file dirname [file dirname [file normalize [info script]]]]
set legacy_repo [file join $legacy_root IP_Repo_2018_3]
set legacy_src [file join $legacy_root rtl]
foreach name {adaloop_top.v axi_lite_drv.v} {
    file copy -force [file join $legacy_src $name] [file join $legacy_repo src $name]
}
file copy -force \
    [file join $legacy_root constraints rfmc6000_orihard_FMC2.xdc] \
    [file join $legacy_repo src rfmc6000_orihard_FMC2.xdc]
set legacy_core [ipx::open_core [file join $legacy_repo component.xml]]
foreach {name width} {cmd_ready 1 cmd_busy 1 cmd_done 1 cmd_overflow 1 cmd_sequence 32 reply_sequence 32 reply_command 32 reply_data 64 reply_error 32} {
    set port [ipx::get_ports -quiet $name -of_objects $legacy_core]
    if {![llength $port]} {set port [ipx::add_port $name $legacy_core]}
    set_property direction out $port
    if {$width>1} {
        set_property size_left [expr {$width-1}] $port
        set_property size_right 0 $port
    }
}
set_property core_revision 2 $legacy_core
ipx::update_checksums $legacy_core
ipx::save_core $legacy_core
ipx::unload_core $legacy_core
puts "AD9361_2018_LOCAL_PACKAGE_SYNCHRONIZED"

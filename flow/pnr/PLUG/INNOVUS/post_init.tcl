# Floorplan (from long time ago in a galaxy far, far away)
floorplan -r 1.0 0.65 40 40 40 40 

# Make VDD/VSS power connectors
globalNetConnect VSS -type pgpin -pin vgnd -inst * 
globalNetConnect VDD -type pgpin -pin vpwr -inst * 
# Not sure I need this
#globalNetConnect VDD –type tiehi
#globalNetConnect VSS –type tielo

# Add Ring
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer met2 -stacked_via_bottom_layer met1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top met1 bottom met1 left met2 right met2} -width {top 14.4 bottom 14.4 left 14.4 right 14.4} -spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -extend_corner {} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

# Connect to power
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { met5(5) met1(1) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { met1(1) met5(5) } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { met1(1) met5(5) }

if { [string first "ware" $::env(DESIGN)]!=-1 } {
    if { $::env(WIDTH)=="32" } {
        set my_period 0.44
    }
    if { $::env(WIDTH)=="64" } {
        set my_period 0.515
    }
    if { $::env(WIDTH)=="128" } {
        set my_period 0.59
    }
} elseif { [string first "ripple" $::env(DESIGN)]!=-1 } {
    if { $::env(WIDTH)=="32" } {
        set my_period 1.4
    }
    if { $::env(WIDTH)=="64" } {
        set my_period 2.8
    }
    if { $::env(WIDTH)=="128" } {
        set my_period 4.2
    }
} else {
    if { $::env(WIDTH)=="32" } {
        set my_period 0.45
    }
    if { $::env(WIDTH)=="64" } {
        set my_period 0.535
    }
    if { $::env(WIDTH)=="128" } {
        set my_period 0.62
    }
}

set_interactive_constraint_modes setup_func_mode
create_clock -name vclk -period $my_period

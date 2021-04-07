onbreak {resume}

# create library
if [file exists work] {
    vdel -all
}
vlib work

vlog tb.v $::env(DESIGN).v

vopt +acc work.tb -o workopt
vsim workopt
view wave

add wave -hex /tb/*

run -all

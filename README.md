# prefix_adders
Parallel-prefix adders in 90nm<br>
Oklahoma State University<br>
VLSI Computer Architecture Research Group<br>

To generate HDL for all adder structures at a certain width, simply

`make compile WIDTH=<desired width>`


To run synth on all adder structures at a certain width, simply

`source sourceme`

`make synth WIDTH=<desired_width>`

This will save all synthesis results to the outputs folder.
Note that re-running synthesis with a different width will not override previous results.
Re-running synthesis with the SAME width WILL OVERRIDE previous results.


Once synthesis is done, pnr can be run with

`source sourceme`

`make pnr WIDTH=<desired_width>`

This will make full back-ups of all PnR runs.
Note that re-running PnR with a different width will not override previous results.
Re-running PnR with the SAME width WILL OVERRIDE previous results.


To run testbenches and generate VCD for all adder structures at a certain width, simply

`make vcd WIDTH=<desired_width>`


To automatically parse PPA results for all adder structures at a certain width, run PnR, and then

`make results WIDTH=<desired_width>`


Both synth and PnR can be run in parallel, with `parallel_synth` and `parallel_pnr` respectively.

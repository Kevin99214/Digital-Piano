vlib work 

vlog FinalProject.v
vsim control

log {/*}
add wave {/*}

force {clk} 1 0ns, 0 {5ns} -r 10ns

force {reset} 0
force {play} 1
run 11ns

force {play} 0
force {ended} 1
run 60ns
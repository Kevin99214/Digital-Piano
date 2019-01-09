vlib work 

vlog FinalProject.v
vsim datapath

log {/*}
add wave {/*}

force {clk} 1 0ns, 0 {5ns} -r 10ns

force {reset} 1
force {ld_song} 1
force {data_inP} 1
run 11ns

force {reset} 0
force {ld_song} 0
force {increaseAddress} 1
run 10ns
force {increaseAddress} 0
run 60ns
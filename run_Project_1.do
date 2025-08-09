vlib work
vlog Project_1.v Project_1_tb.v
vsim -voptargs=+acc work.Project_1_tb
add wave *
run -all
#quit -sim

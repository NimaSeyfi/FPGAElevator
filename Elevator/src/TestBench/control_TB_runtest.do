SetActiveLib -work
comp -include "$dsn\src\Controller.vhd" 
comp -include "$dsn\src\TestBench\control_TB.vhd" 
asim +access +r TESTBENCH_FOR_control 
wave 
wave -noreg clock
wave -noreg reset
wave -noreg start
wave -noreg ManualDataIn
wave -noreg ManualEn
wave -noreg Timer
wave -noreg Floor
wave -noreg LiftDir
wave -noreg LiftDoor
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\control_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_control 

#EJERCICIO: Rellenar los archivos verilog
yosys read_verilog computer.v alu.v control_unit.v data_memory.v instruction_memory.v mux_data.v mux2.v mux3.v mux4.v mux5.v mux6.v pc.v register.v status_register.v

yosys synth
yosys write_verilog out/netlist.v

yosys stat
yosys tee -q -o "out/computer.rpt" stat

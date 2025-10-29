module computer(clk);
   input clk;
   
   // Buses internos
   wire [7:0]   pc_out;
   wire [14:0]  instruction;  // 15 bits
   wire [7:0]   regA_out;
   wire [7:0]   regB_out;
   wire [7:0]   alu_out;
   wire [3:0]   status_out;
   wire [7:0]   mem_out;
   
   // Señales de control desde Control Unit
   wire load_a, load_b, load_pc, load_status, write_mem;

   // +++ NUEVO +++
   wire [2:0] mux_a_sel;   // antes era [1:0]
   wire [2:0] mux_b_sel;   // antes era [1:0]
   wire       mem_addr_sel; // 0 = Literal (Dir), 1 = B (indirecto)

   wire mux_data_sel;
   wire [2:0] alu_op;
   
   // Flags desde ALU
   wire z_flag, n_flag, c_flag, v_flag;
   
   // Salidas de multiplexores (ANTES de la ALU)
   wire [7:0] mux_a_out;  // Entrada A de la ALU
   wire [7:0] mux_b_out;  // Entrada B de la ALU
   wire [7:0] mux_data_out;
   
   // Operando inmediato y opcode de la instrucción (15 bits total)
   wire [6:0] opcode = instruction[14:8];  // 7 bits de opcode
   wire [7:0] literal_raw = instruction[7:0];  // 8 bits de literal
   
   // Para INC, forzar literal a 1 (INC opcode = 0100100)
   wire [7:0] literal = (opcode == 7'b0100100) ? 8'd1 : literal_raw;

   wire [7:0] mem_addr_in;

   wire [7:0] one8 = 8'd1;
   
   // PC - Program Counter
   pc PC(
      .clk(clk),
      .load(load_pc),
      .k(literal),
      .pc(pc_out)
   );
   
   // Instruction Memory
   instruction_memory IM(
      .address(pc_out),
      .out(instruction)
   );
   
   // Control Unit
   control_unit CU(
      .instruction(instruction),
      .flags(status_out),
      .load_a(load_a),
      .load_b(load_b),
      .load_pc(load_pc),
      .load_status(load_status),
      .write_mem(write_mem),
      .mux_a_sel(mux_a_sel),
      .mux_b_sel(mux_b_sel),
      .mux_data_sel(mux_data_sel),
      .alu_op(alu_op),
      .mem_addr_sel(mem_addr_sel)
   );
   
   // Registro A (carga desde la salida de la ALU)
   register regA(
      .clk(clk),
      .data(alu_out),
      .load(load_a),
      .out(regA_out)
   );
   
   // Registro B (carga desde la salida de la ALU)
   register regB(
      .clk(clk),
      .data(alu_out),
      .load(load_b),
      .out(regB_out)
   );
   
   // Status Register
   status_register Status(
      .clk(clk),
      .load(load_status),
      .z_in(z_flag),
      .n_in(n_flag),
      .c_in(c_flag),
      .v_in(v_flag),
      .flags_out(status_out)
   );
   
   // Mux A: 0=Z, 1=A, 2=B, 3=Lit, 4=Mem
   mux5 muxA(
   .e0(8'b0), .e1(regA_out), .e2(regB_out), .e3(literal), .e4(mem_out),
   .s(mux_a_sel), .out(mux_a_out)
   );

   // Mux B: 0=Z, 1=B, 2=Lit, 3=A, 4=Mem
   mux6 muxB(
   .e0(8'b0),
   .e1(regB_out),
   .e2(literal),
   .e3(regA_out),
   .e4(mem_out),
   .e5(one8),
   .s(mux_b_sel),
   .out(mux_b_out)
   );
   
   // ALU: Recibe entradas desde Mux A y Mux B
   alu ALU(
      .a(mux_a_out),
      .b(mux_b_out),
      .s(alu_op),
      .out(alu_out),
      .z(z_flag),
      .n(n_flag),
      .c(c_flag),
      .v(v_flag)
   );
   
   // Mux Data: Selecciona qué se escribe en memoria
   mux_data muxData(
      .e0(regA_out),
      .e1(alu_out),
      .s(mux_data_sel),
      .out(mux_data_out)
   );
   
   // Data Memory
   data_memory DM(
      .clk(clk),
      .address(mem_addr_in),
      .data_in(mux_data_out),
      .write_enable(write_mem),
      .data_out(mem_out)
   );

   mux2 addrSel( .e0(literal), .e1(regB_out), .c(mem_addr_sel), .out(mem_addr_in) );
   
endmodule

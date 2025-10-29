module control_unit(instruction, flags, load_a, load_b, load_pc, load_status, 
                    write_mem, mux_a_sel, mux_b_sel, mux_data_sel, alu_op, mem_addr_sel);
   input [14:0] instruction;  // 15 bits
   input [3:0]  flags;        // [V, C, N, Z]
   
   output load_a;             // Señal de carga para registro A
   output load_b;             // Señal de carga para registro B
   output load_pc;            // Señal de carga para PC (saltos)
   output load_status;        // Señal de carga para registro de estado
   output write_mem;          // Señal de escritura en memoria
   output [2:0] mux_a_sel;    // Selector para Mux A (SA)
   output [2:0] mux_b_sel;    // Selector para Mux B (SB)
   output mux_data_sel;       // Selector para Mux Data
   output [2:0] alu_op;       // Operación de la ALU (S)

   output mem_addr_sel;   // 0 = Literal (Dir), 1 = B (indirecto)

   reg mem_addr_sel;
   
   wire [14:0] instruction;   // 15 bits
   wire [3:0]  flags;

   // flags = {V,C,N,Z}
   wire v = flags[3];
   wire c = flags[2];
   wire n = flags[1];
   wire z = flags[0];

   
   reg load_a;
   reg load_b;
   reg load_pc;
   reg load_status;
   reg write_mem;
   reg    [2:0] mux_a_sel, mux_b_sel;
   reg [2:0] alu_op;
   reg mux_data_sel;
   
   // Decodificación del opcode (bits 14:8 = 7 bits)
   wire [6:0] opcode = instruction[14:8];
   wire [7:0] literal = instruction[7:0];
   
   localparam SA_ZERO = 3'd0;
   localparam SA_REGA = 3'd1;
   localparam SA_REGB = 3'd2;
   localparam SA_LIT  = 3'd3;
   localparam SA_MEM  = 3'd4;

   localparam SB_ZERO = 3'd0;
   localparam SB_REGB = 3'd1;
   localparam SB_LIT  = 3'd2;
   localparam SB_REGA = 3'd3;
   localparam SB_MEM  = 3'd4;
   
   // Constantes para operaciones ALU (S)
   localparam ALU_ADD = 3'b000;  // +
   localparam ALU_SUB = 3'b001;  // -
   localparam ALU_AND = 3'b010;  // AND
   localparam ALU_OR  = 3'b011;  // OR
   localparam ALU_XOR = 3'b100;  // XOR
   localparam ALU_NOT = 3'b101;  // NOT
   localparam ALU_SHL = 3'b110;  // Shift Left
   localparam ALU_SHR = 3'b111;  // Shift Right

   localparam SB_ONE  = 3'd5;  // NUEVO: constante 1
   
   always @(*) begin
      // Valores por defecto
      load_a = 0;
      load_b = 0;
      load_pc = 0;
      load_status = 0;
      mem_addr_sel = 0;
      write_mem = 0;
      mux_a_sel = SA_ZERO;
      mux_b_sel = SB_ZERO;
      mux_data_sel = 0;
      alu_op = ALU_ADD;
      
      // Decodificación según la tabla de instrucciones
      case(opcode)
         // ========== MOV ==========
         // MOV A,B (0000000): A=B
         7'b0000000: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_ZERO;  // Z
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_ADD;     // +
            load_status = 0;
         end
         
         // MOV B,A (0000001): B=A
         7'b0000001: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_ZERO;  // Z
            alu_op = ALU_ADD;     // +
            load_status = 0;
         end
         
         // MOV A,Lit (0000010): A=Lit
         7'b0000010: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_ZERO;  // Z
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_ADD;     // +
            load_status = 0;
         end
         
         // MOV B,Lit (0000011): B=Lit
         7'b0000011: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_ZERO;  // Z
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_ADD;     // +
            load_status = 0;
         end
         
         // ========== ADD ==========
         // ADD A,B (0000100): A=A+B
         7'b0000100: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_ADD;     // +
            load_status = 1;
         end
         
         // ADD B,A (0000101): B=A+B
         7'b0000101: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_ADD;     // +
            load_status = 1;
         end
         
         // ADD A,Lit (0000110): A=A+Lit
         7'b0000110: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_ADD;     // +
            load_status = 1;
         end
         
         // ADD B,Lit (0000111): B=B+Lit
         7'b0000111: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_ADD;     // +
            load_status = 1;
         end
         
         // ========== SUB ==========
         // SUB A,B (0001000): A=A-B
         7'b0001000: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_SUB;     // -
            load_status = 1;
         end
         
         // SUB B,A (0001001): B=A-B
         7'b0001001: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_SUB;     // -
            load_status = 1;
         end
         
         // SUB A,Lit (0001010): A=A-Lit
         7'b0001010: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_SUB;     // -
            load_status = 1;
         end
         
         // SUB B,Lit (0001011): B=B-Lit
         7'b0001011: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_SUB;     // -
            load_status = 1;
         end
         
         // ========== AND ==========
         // AND A,B (0001100): A = A & B
         7'b0001100: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_AND;     // &
            load_status = 1;
         end
         
         // AND B,A (0001101): B = A & B
         7'b0001101: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_AND;     // &
            load_status = 1;
         end
         
         // AND A,Lit (0001110): A = A & Lit
         7'b0001110: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_AND;     // &
            load_status = 1;
         end
         
         // AND B,Lit (0001111): B = B & Lit
         7'b0001111: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_AND;     // &
            load_status = 1;
         end
         
         // ========== OR ==========
         // OR A,B (0010000): A = A | B
         7'b0010000: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_OR;      // |
            load_status = 1;
         end
         
         // OR B,A (0010001): B = A | B
         7'b0010001: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_OR;      // |
            load_status = 1;
         end
         
         // OR A,Lit (0010010): A = A | Lit
         7'b0010010: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_OR;      // |
            load_status = 1;
         end
         
         // OR B,Lit (0010011): B = B | Lit
         7'b0010011: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_OR;      // |
            load_status = 1;
         end
         
         // ========== NOT ==========
         // NOT A,A (0010100): A = ~A
         7'b0010100: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_NOT;     // ~
            load_status = 1;
         end
         
         // NOT A,B (0010101): A = ~B
         7'b0010101: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_NOT;     // ~
            load_status = 1;
         end
         
         // NOT B,A (0010110): B = ~A
         7'b0010110: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_NOT;     // ~
            load_status = 1;
         end
         
         // NOT B,B (0010111): B = ~B
         7'b0010111: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_NOT;     // ~
            load_status = 1;
         end
         
         // ========== XOR ==========
         // XOR A,B (0011000): A = A ^ B
         7'b0011000: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_XOR;     // ^
            load_status = 1;
         end
         
         // XOR B,A (0011001): B = A ^ B
         7'b0011001: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_XOR;     // ^
            load_status = 1;
         end
         
         // XOR A,Lit (0011010): A = A ^ Lit
         7'b0011010: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_XOR;     // ^
            load_status = 1;
         end
         
         // XOR B,Lit (0011011): B = B ^ Lit
         7'b0011011: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_LIT;   // Lit
            alu_op = ALU_XOR;     // ^
            load_status = 1;
         end
         
         // ========== SHL (Shift Left) ==========
         // SHL A,A (0011100): A = A << 1
         7'b0011100: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_SHL;     // <<
            load_status = 1;
         end
         
         // SHL A,B (0011101): A = B << 1
         7'b0011101: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_SHL;     // <<
            load_status = 1;
         end
         
         // SHL B,A (0011110): B = A << 1
         7'b0011110: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_SHL;     // <<
            load_status = 1;
         end
         
         // SHL B,B (0011111): B = B << 1
         7'b0011111: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_SHL;     // <<
            load_status = 1;
         end
         
         // ========== SHR (Shift Right) ==========
         // SHR A,A (0100000): A = A >> 1
         7'b0100000: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_SHR;     // >>
            load_status = 1;
         end
         
         // SHR A,B (0100001): A = B >> 1
         7'b0100001: begin
            load_a = 1;
            load_b = 0;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_SHR;     // >>
            load_status = 1;
         end
         
         // SHR B,A (0100010): B = A >> 1
         7'b0100010: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGA;  // A
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_SHR;     // >>
            load_status = 1;
         end
         
         // SHR B,B (0100011): B = B >> 1
         7'b0100011: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_REGB;  // B
            mux_b_sel = SB_ZERO;  // No se usa
            alu_op = ALU_SHR;     // >>
            load_status = 1;
         end
         
         // ========== INC (Increment) ==========
         // INC B (0100100): B = B + 1
         // Nota: El literal en la instrucción debe ser 1
         7'b0100100: begin
            load_a = 0;
            load_b = 1;
            mux_a_sel = SA_LIT;   // Literal (debe ser 1)
            mux_b_sel = SB_REGB;  // B
            alu_op = ALU_ADD;     // +
            load_status = 1;
         end
         
         // Aquí se agregarían las demás operaciones...

         // ================== 1.2 MOV con Mem ==================
         // MOV A,(Dir): A = Mem[Lit]
         7'b0100101: begin
         load_a = 1; load_b = 0; load_status = 0;
         mux_a_sel = SA_ZERO; mux_b_sel = SB_MEM; alu_op = ALU_ADD;
         mem_addr_sel = 1'b0; // Dir
         end
         // MOV B,(Dir): B = Mem[Lit]
         7'b0100110: begin
         load_a = 0; load_b = 1; load_status = 0;
         mux_a_sel = SA_ZERO; mux_b_sel = SB_MEM; alu_op = ALU_ADD;
         mem_addr_sel = 1'b0; // Dir
         end
         // MOV (Dir),A : Mem[Lit] = A
         7'b0100111: begin
         write_mem = 1; mux_data_sel = 1'b0; // escribir A
         mem_addr_sel = 1'b0; // Dir
         end
         // MOV (Dir),B : Mem[Lit] = B  (usa ALU para pasar B)
         7'b0101000: begin
         write_mem = 1; mux_data_sel = 1'b1; // escribir resultado ALU
         mux_a_sel = SA_ZERO; mux_b_sel = SB_REGB; alu_op = ALU_ADD;
         mem_addr_sel = 1'b0; // Dir
         end
         // MOV A,(B) : A = Mem[B]
         7'b0101001: begin
         load_a = 1; mux_a_sel = SA_ZERO; mux_b_sel = SB_MEM; alu_op = ALU_ADD;
         mem_addr_sel = 1'b1; // B indirecto
         end
         // MOV B,(B) : B = Mem[B]
         7'b0101010: begin
         load_b = 1; mux_a_sel = SA_ZERO; mux_b_sel = SB_MEM; alu_op = ALU_ADD;
         mem_addr_sel = 1'b1;
         end
         // MOV (B),A : Mem[B] = A
         7'b0101011: begin
         write_mem = 1; mux_data_sel = 1'b0; mem_addr_sel = 1'b1;
         end

         // ================== 1.2 ADD con Mem ==================
         // ADD A,(Dir) : A = A + Mem[Lit]
         7'b0101100: begin
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_ADD;
         mem_addr_sel = 1'b0;
         end
         // ADD B,(Dir) : B = B + Mem[Lit]
         7'b0101101: begin
         load_b = 1; load_status = 1;
         mux_a_sel = SA_REGB; mux_b_sel = SB_MEM; alu_op = ALU_ADD;
         mem_addr_sel = 1'b0;
         end
         // ADD A,(B) : A = A + Mem[B]
         7'b0101110: begin
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_ADD;
         mem_addr_sel = 1'b1;
         end
         // ADD (Dir) : Mem[Lit] = A + B
         7'b0101111: begin
         write_mem = 1; mux_data_sel = 1'b1; // ALU
         mux_a_sel = SA_REGA; mux_b_sel = SB_REGB; alu_op = ALU_ADD; load_status = 1;
         mem_addr_sel = 1'b0;
         end

         // ================== 1.2 SUB con Mem ==================
         7'b0110000: begin // SUB A,(Dir)
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_SUB;
         mem_addr_sel = 1'b0;
         end
         7'b0110001: begin // SUB B,(Dir)
         load_b = 1; load_status = 1;
         mux_a_sel = SA_REGB; mux_b_sel = SB_MEM; alu_op = ALU_SUB;
         mem_addr_sel = 1'b0;
         end
         7'b0110010: begin // SUB A,(B)
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_SUB;
         mem_addr_sel = 1'b1;
         end
         7'b0110011: begin // SUB (Dir) : Mem[Lit] = A - B
         write_mem = 1; mux_data_sel = 1'b1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_REGB; alu_op = ALU_SUB; load_status = 1;
         mem_addr_sel = 1'b0;
         end

         // ================== 1.2 AND con Mem ==================
         7'b0110100: begin // AND A,(Dir)
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_AND;
         mem_addr_sel = 1'b0;
         end
         7'b0110101: begin // AND B,(Dir)
         load_b = 1; load_status = 1;
         mux_a_sel = SA_REGB; mux_b_sel = SB_MEM; alu_op = ALU_AND;
         mem_addr_sel = 1'b0;
         end
         7'b0110110: begin // AND A,(B)
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_AND;
         mem_addr_sel = 1'b1;
         end
         7'b0110111: begin // AND (Dir) : Mem[Lit] = A and B
         write_mem = 1; mux_data_sel = 1'b1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_REGB; alu_op = ALU_AND; load_status = 1;
         mem_addr_sel = 1'b0;
         end

         // ================== 1.2 OR con Mem ===================
         7'b0111000: begin // OR A,(Dir)
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_OR;
         mem_addr_sel = 1'b0;
         end
         7'b0111001: begin // OR B,(Dir)
         load_b = 1; load_status = 1;
         mux_a_sel = SA_REGB; mux_b_sel = SB_MEM; alu_op = ALU_OR;
         mem_addr_sel = 1'b0;
         end
         7'b0111010: begin // OR A,(B)
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_OR;
         mem_addr_sel = 1'b1;
         end
         7'b0111011: begin // OR (Dir) : Mem[Lit] = A or B
         write_mem = 1; mux_data_sel = 1'b1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_REGB; alu_op = ALU_OR; load_status = 1;
         mem_addr_sel = 1'b0;
         end

         // ================== 1.2 NOT con Mem ==================
         7'b0111100: begin // NOT (Dir),A : Mem[Lit] = ~A
         write_mem = 1; mux_data_sel = 1;
         mux_a_sel = SA_REGA; alu_op = ALU_NOT; load_status = 1;
         mem_addr_sel = 1'b0;
         end
         7'b0111101: begin // NOT (Dir),B : Mem[Lit] = ~B
         write_mem = 1; mux_data_sel = 1;
         mux_a_sel = SA_REGB; alu_op = ALU_NOT; load_status = 1;
         mem_addr_sel = 1'b0;
         end
         7'b0111110: begin // NOT (B) : Mem[B] = ~A
         write_mem = 1; mux_data_sel = 1;
         mux_a_sel = SA_REGA; alu_op = ALU_NOT; load_status = 1;
         mem_addr_sel = 1'b1;
         end

         // ================== 1.2 XOR con Mem ==================
         7'b0111111: begin // XOR A,(Dir)
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_XOR;
         mem_addr_sel = 1'b0;
         end
         7'b1000000: begin // XOR B,(Dir)
         load_b = 1; load_status = 1;
         mux_a_sel = SA_REGB; mux_b_sel = SB_MEM; alu_op = ALU_XOR;
         mem_addr_sel = 1'b0;
         end
         7'b1000001: begin // XOR A,(B)
         load_a = 1; load_status = 1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_MEM; alu_op = ALU_XOR;
         mem_addr_sel = 1'b1;
         end
         7'b1000010: begin // XOR (Dir) : Mem[Lit] = A xor B
         write_mem = 1; mux_data_sel = 1'b1;
         mux_a_sel = SA_REGA; mux_b_sel = SB_REGB; alu_op = ALU_XOR; load_status = 1;
         mem_addr_sel = 1'b0;
         end

         // ================== 1.2 SHL / SHR a Mem ==================
         // SHL (Dir),A : Mem[Lit] = A<<1
         7'b1000011: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_REGA;
         alu_op        = ALU_SHL;
         load_status   = 1;
         mem_addr_sel  = 1'b0;
         end
         // SHL (Dir),B : Mem[Lit] = B<<1
         7'b1000100: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_REGB;
         alu_op        = ALU_SHL;
         load_status   = 1;
         mem_addr_sel  = 1'b0;
         end
         // SHL (B) : Mem[B] = A<<1
         7'b1000101: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_REGA;
         alu_op        = ALU_SHL;
         load_status   = 1;
         mem_addr_sel  = 1'b1;
         end
         // SHR (Dir),A : Mem[Lit] = A>>1
         7'b1000110: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_REGA;
         alu_op        = ALU_SHR;
         load_status   = 1;
         mem_addr_sel  = 1'b0;
         end
         // SHR (Dir),B : Mem[Lit] = B>>1
         7'b1000111: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_REGB;
         alu_op        = ALU_SHR;
         load_status   = 1;
         mem_addr_sel  = 1'b0;
         end
         // SHR (B) : Mem[B] = A>>1
         7'b1001000: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_REGA;
         alu_op        = ALU_SHR;
         load_status   = 1;
         mem_addr_sel  = 1'b1;
         end

         // ================== 1.2 INC / RST a Mem ==================
         // INC (Dir) : Mem[Lit] = Mem[Lit] + 1
         7'b1001001: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_MEM;        // Mem[addr] como A
         mux_b_sel     = SB_ONE;        // <-- ver punto B abajo
         alu_op        = ALU_ADD;
         load_status   = 1;
         mem_addr_sel  = 1'b0;
         end
         // INC (B) : Mem[B] = Mem[B] + 1
         7'b1001010: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_MEM;
         mux_b_sel     = SB_ONE;        // <-- ver punto B
         alu_op        = ALU_ADD;
         load_status   = 1;
         mem_addr_sel  = 1'b1;
         end
         // RST (Dir) : Mem[Lit] = 0
         7'b1001011: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_ZERO;       // genera 0 por la ALU (0+0)
         alu_op        = ALU_ADD;
         load_status   = 1;
         mem_addr_sel  = 1'b0;
         end

         // RST (Dir) : Mem[B] = 0
         7'b1001100: begin
         write_mem     = 1;
         mux_data_sel  = 1;
         mux_a_sel     = SA_ZERO;       // genera 0 por la ALU (0+0)
         alu_op        = ALU_ADD;
         load_status   = 1;
         mem_addr_sel  = 1'b1;
         end

         // ===== 1.3 CMP: solo setea flags usando A - (algo) =====
    
         7'b1001101: begin // CMP A,B
            load_status = 1;
            mux_a_sel = SA_REGA; mux_b_sel = SB_REGB; alu_op = ALU_SUB;
         end
    
         7'b1001110: begin // CMP A,Lit
            load_status = 1;
            mux_a_sel = SA_REGA; mux_b_sel = SB_LIT;  alu_op = ALU_SUB;
         end
    
         7'b1001111: begin // CMP B,Lit
            load_status = 1;
            mux_a_sel = SA_REGB; mux_b_sel = SB_LIT;  alu_op = ALU_SUB;
         end
    
         7'b1010000: begin // CMP A,(Dir)
            load_status = 1;
            mux_a_sel = SA_REGA; mux_b_sel = SB_MEM;  alu_op = ALU_SUB;
            mem_addr_sel = 1'b0; // Dir
         end
    
         7'b1010001: begin // CMP B,(Dir)
            load_status = 1;
            mux_a_sel = SA_REGB; mux_b_sel = SB_MEM;  alu_op = ALU_SUB;
            mem_addr_sel = 1'b0;
         end

         7'b1010010: begin // CMP A,(B)
            load_status = 1;
            mux_a_sel = SA_REGA; mux_b_sel = SB_MEM;  alu_op = ALU_SUB;
            mem_addr_sel = 1'b1; // Indirecto por B
         end

         // ====== 1.3 Jumps ======

         // JMP incondicional
         7'b1010011: begin
            load_pc = 1;
         end

         // JEQ (Z==1)
         7'b1010100: begin
            load_pc = z;
         end

         // JNE (Z==0)
         7'b1010101: begin
            load_pc = ~z;
         end

         // JGT (N==0 && Z==0)
         7'b1010110: begin
            load_pc = (~n) & (~z);
         end

         // JLT (N==1)
         7'b1010111: begin
            load_pc = n;
         end

         // JGE (N==0)
         7'b1011000: begin
            load_pc = ~n;
         end

         // JLE (N==1 || Z==1)
         7'b1011001: begin
            load_pc = n | z;
         end
         
         default: begin
            // NOP - No hacer nada
            load_a = 0;
            load_b = 0;
            load_pc = 0;
            load_status = 0;
            write_mem = 0;
         end
      endcase
   end
endmodule

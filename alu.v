module alu(a, b, s, out, z, n, c, v);
   input [7:0] a, b;
   input [2:0] s;
   output [7:0] out;
   output z, n, c, v;  // Flags: Zero, Negative, Carry, oVerflow

   wire [7:0]   a, b;
   wire [2:0]   s;
   reg [7:0]    out;
   reg          z, n, c, v;

   always @(*) begin
      // Default flags
      c = 0;
      v = 0;
      
      case(s)
         3'b000: out = a + b;      // ADD
         3'b001: out = a - b;      // SUB
         3'b010: out = a & b;      // AND
         3'b011: out = a | b;      // OR
         3'b100: out = a ^ b;      // XOR
         3'b101: out = ~a;         // NOT
         3'b110: out = a << 1;     // Shift Left
         3'b111: out = a >> 1;     // Shift Right
         default: out = 8'b0;
      endcase
      
      // Calculate flags
      z = (out == 8'b0);          // Zero flag
      n = out[7];                 // Negative flag (MSB)
   end
endmodule

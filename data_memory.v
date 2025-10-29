module data_memory(clk, address, data_in, write_enable, data_out);
   input clk;
   input [7:0] address;
   input [7:0] data_in;
   input write_enable;
   output [7:0] data_out;

   wire clk;
   wire [7:0]   address;
   wire [7:0]   data_in;
   wire         write_enable;
   wire [7:0]   data_out;

   reg [7:0]    mem [0:255];  // 256 posiciones de 8 bits

   // Lectura asíncrona
   assign data_out = mem[address];

   // Escritura síncrona
   always @(negedge clk) begin
      if (write_enable) begin
         mem[address] <= data_in;
      end
   end
endmodule


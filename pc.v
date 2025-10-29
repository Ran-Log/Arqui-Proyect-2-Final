module pc(clk, load, k, pc);
   input clk;
   input load;           // Señal de carga para saltos
   input [7:0] k;        // Dirección de salto
   output [7:0] pc;

   reg [7:0]     pc;
   wire          clk;
   wire          load;
   wire [7:0]    k;

   initial begin
	   pc = 0;
   end

   always @(posedge clk) begin
      if (load) begin
         pc <= k;        // Cargar dirección de salto
      end else begin
         pc <= pc + 1;   // Incrementar normalmente
      end
   end
endmodule

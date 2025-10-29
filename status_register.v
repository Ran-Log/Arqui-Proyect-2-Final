module status_register(clk, load, z_in, n_in, c_in, v_in, flags_out);
   input clk;
   input load;
   input z_in, n_in, c_in, v_in;
   output [3:0] flags_out;

   wire clk, load;
   wire z_in, n_in, c_in, v_in;
   reg [3:0] flags_out;

   initial begin
      flags_out = 4'b0000;
   end

   always @(posedge clk) begin
      if (load) begin
         flags_out <= {v_in, c_in, n_in, z_in};  // [V, C, N, Z]
      end
   end
endmodule


module mux_data(e0, e1, s, out);
   input [7:0] e0, e1;
   input       s;
   output [7:0] out;
   
   wire [7:0]   e0, e1;
   wire         s;
   reg [7:0]    out;
   
   always @(*) begin
      case(s)
         1'b0: out = e0;
         1'b1: out = e1;
      endcase
   end
endmodule


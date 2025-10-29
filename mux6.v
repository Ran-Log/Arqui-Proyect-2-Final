module mux6(
  input  [7:0] e0, e1, e2, e3, e4, e5,
  input  [2:0] s,
  output reg [7:0] out
);
  always @(*) begin
    case (s)
      3'd0: out = e0; // Z
      3'd1: out = e1; // B
      3'd2: out = e2; // Lit
      3'd3: out = e3; // A
      3'd4: out = e4; // Mem
      3'd5: out = e5; // ONE (1)
      default: out = 8'b0;
    endcase
  end
endmodule

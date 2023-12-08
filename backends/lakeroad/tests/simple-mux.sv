// RUN: "$YOSYS" -p 'read_verilog -sv %s; prep -top test; pmuxtree;\
// RUN: proc; opt; memory; opt; techmap; opt; abc; opt; write_lakeroad'
module test(input [2:0] a, output [2:0] out);
  // assign out = ~ a;
  always_comb begin
	  case (a)
		  2'b01: out = 2'b10;
		  2'b00: out = 2'b10;
		  2'b10: out = 2'b00;
		  2'b11: out = 2'b01;
		  default: out = 2'b01;
	  endcase
  end
endmodule


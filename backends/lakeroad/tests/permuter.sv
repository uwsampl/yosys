// DO NOT MERGE: need to get permission to use this file.
//
// Copyright 2023 Intel Corporation.
//
// This reference design file is subject licensed to you by the terms and
// conditions of the applicable License Terms and Conditions for Hardware
// Reference Designs and/or Design Examples (either as signed by you or
// found at https://www.altera.com/common/legal/leg-license_agreement.html ).
//
// As stated in the license, you agree to only use this reference design
// solely in conjunction with Intel FPGAs or Intel CPLDs.
//
// THE REFERENCE DESIGN IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED
// WARRANTY OF ANY KIND INCLUDING WARRANTIES OF MERCHANTABILITY,
// NONINFRINGEMENT, OR FITNESS FOR A PARTICULAR PURPOSE. Intel does not
// warrant or assume responsibility for the accuracy or completeness of any
// information, links or other items within the Reference Design and any
// accompanying materials.
//
// In the event that you do not agree with such terms and conditions, do not
// use the reference design file.
/////////////////////////////////////////////////////////////////////////////

module permuter_4x4_sim #(
    parameter SIZE = 4
) (
	input clk,
	input [4*SIZE-1:0] din,
	input [1:0] control,
	output reg [4*SIZE-1:0] dout
);


always @(posedge clk) begin
    case (control)
        2'b00: begin
            {dout[(3+1)*SIZE-1:3*SIZE], dout[(2+1)*SIZE-1:2*SIZE], dout[(1+1)*SIZE-1:1*SIZE], dout[(0+1)*SIZE-1:0*SIZE]} <= {din[(3+1)*SIZE-1:3*SIZE], din[(2+1)*SIZE-1:2*SIZE], din[(1+1)*SIZE-1:1*SIZE], din[(0+1)*SIZE-1:0*SIZE]};
        end
        2'b01: begin
            {dout[(3+1)*SIZE-1:3*SIZE], dout[(2+1)*SIZE-1:2*SIZE], dout[(1+1)*SIZE-1:1*SIZE], dout[(0+1)*SIZE-1:0*SIZE]} <= {din[(2+1)*SIZE-1:2*SIZE], din[(3+1)*SIZE-1:3*SIZE], din[(0+1)*SIZE-1:0*SIZE], din[(1+1)*SIZE-1:1*SIZE]};
        end
        2'b10: begin
            {dout[(3+1)*SIZE-1:3*SIZE], dout[(2+1)*SIZE-1:2*SIZE], dout[(1+1)*SIZE-1:1*SIZE], dout[(0+1)*SIZE-1:0*SIZE]} <= {din[(1+1)*SIZE-1:1*SIZE], din[(0+1)*SIZE-1:0*SIZE], din[(3+1)*SIZE-1:3*SIZE], din[(2+1)*SIZE-1:2*SIZE]};
        end
        2'b11: begin
            {dout[(3+1)*SIZE-1:3*SIZE], dout[(2+1)*SIZE-1:2*SIZE], dout[(1+1)*SIZE-1:1*SIZE], dout[(0+1)*SIZE-1:0*SIZE]} <= {din[(0+1)*SIZE-1:0*SIZE], din[(1+1)*SIZE-1:1*SIZE], din[(2+1)*SIZE-1:2*SIZE], din[(3+1)*SIZE-1:3*SIZE]};
        end
    endcase
end

endmodule


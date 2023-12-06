// RUN: "$YOSYS" -p 'read_verilog -sv %s; prep -top test; write_lakeroad' \
// RUN:   | FileCheck %s
module test(input a, output out);
  assign out = ~ a;
endmodule

// CHECK: (let v0 (Wire "v0" 1))
// CHECK: (let v1 (Wire "v1" 1))
// CHECK: (union v1 (Op1 (Not) v0))
// CHECK: (let a (Var "a" 1))
// CHECK: (union v0 a)
// CHECK: (let out v1)
// CHECK: (delete (Wire "v0" 1))
// CHECK: (delete (Wire "v1" 1))

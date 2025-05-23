
module mux2to1 (
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    input  logic        sel,
    output logic [31:0] out
);
 
    always_comb begin
    	out = in0;
    	if(sel) out = in1;
    end
 
endmodule

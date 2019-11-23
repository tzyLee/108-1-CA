module matvecmult(
    CLK,
    RST,
    vector_x,
    vector_b,
    vector_y,
    Q,
    A,
    finish
);

input               CLK;
input               RST;
input       [127:0]	vector_x;
input       [127:0]	vector_b;
output  reg [127:0]	vector_y;
input       [127:0]	Q;
output  reg [3:0]   A;
output  reg         finish;

always @(*) begin

end


always @(posedge CLK or posedge RST) begin
    if (RST) begin
        // reset

    end
    else begin

    end
end

endmodule
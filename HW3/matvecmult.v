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

integer             i;
reg    [7:0]        temp;
reg    [7:0]        vector_x_w [0:15];
reg    [7:0]        vector_b_w [0:15];
reg    [7:0]        vector_y_r [0:15], vector_y_w [0:15];
reg    [7:0]        matrix_a_row_w [15:0];
reg    [3:0]        counter_r, counter_w;
reg                 finish_r, finish_w;

always @(*) begin
    temp = 8'b0;
    for(i=0; i<16; i=i+1) begin
        vector_y_w[i] = vector_y_r[i];
        vector_x_w[i] = vector_x[8*i +: 8];
        vector_b_w[i] = vector_b[8*i +: 8];
        matrix_a_row_w[i] = Q[8*(15-i) +: 8];
    end
    temp = 2*(
        matrix_a_row_w[0]*vector_x_w[0]+
        matrix_a_row_w[1]*vector_x_w[1]+
        matrix_a_row_w[2]*vector_x_w[2]+
        matrix_a_row_w[3]*vector_x_w[3]+
        matrix_a_row_w[4]*vector_x_w[4]+
        matrix_a_row_w[5]*vector_x_w[5]+
        matrix_a_row_w[6]*vector_x_w[6]+
        matrix_a_row_w[7]*vector_x_w[7]+
        matrix_a_row_w[8]*vector_x_w[8]+
        matrix_a_row_w[9]*vector_x_w[9]+
        matrix_a_row_w[10]*vector_x_w[10]+
        matrix_a_row_w[11]*vector_x_w[11]+
        matrix_a_row_w[12]*vector_x_w[12]+
        matrix_a_row_w[13]*vector_x_w[13]+
        matrix_a_row_w[14]*vector_x_w[14]+
        matrix_a_row_w[15]*vector_x_w[15]
    ) + vector_b_w[counter_r];
    finish_w = 1'b0;
    counter_w = counter_r;

    if (RST)
        counter_w = 1'b0;
    else begin
        if (counter_r < 4'b1111) begin
            counter_w = counter_r + 1'b1;
            vector_y_w[counter_r] = temp;
        end
        else begin
            finish_w = 1'b1;
            if (finish_r == 1'b0)
                vector_y_w[15] = temp;
        end
    end

    vector_y = {
        vector_y_r[15],
        vector_y_r[14],
        vector_y_r[13],
        vector_y_r[12],
        vector_y_r[11],
        vector_y_r[10],
        vector_y_r[9],
        vector_y_r[8],
        vector_y_r[7],
        vector_y_r[6],
        vector_y_r[5],
        vector_y_r[4],
        vector_y_r[3],
        vector_y_r[2],
        vector_y_r[1],
        vector_y_r[0]
    };
    finish = finish_r;
    A = counter_w;
end


always @(posedge CLK or posedge RST) begin
    if (RST) begin
        // reset
        counter_r <= 4'b0;
        finish_r <= 1'b0;
        for (i=0; i<16; i=i+1) begin
            vector_y_r[i] <= 8'b0;
        end
    end
    else begin
        counter_r <= counter_w;
        finish_r <= finish_w;
        for (i=0; i<16; i=i+1) begin
            vector_y_r[i] <= vector_y_w[i];
        end
    end
end

endmodule
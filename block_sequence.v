module block_sequence(
    input wire       clk,
    output reg [1:0] random
    );

    initial begin
        random = 1;
    end
    always @ (posedge clk) begin
        if (random == 0) begin
            random <= 1;
        end else begin
            random <= random + 1;
        end
    end

endmodule

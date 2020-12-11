`define PIXEL_WIDTH 640
`define PIXEL_HEIGHT 480
`define HSYNC_FRONT_PORCH 16
`define HSYNC_PULSE_WIDTH 96
`define HSYNC_BACK_PORCH 48
`define VSYNC_FRONT_PORCH 10
`define VSYNC_PULSE_WIDTH 2
`define VSYNC_BACK_PORCH 33
`define BLOCK_SIZE 20
`define BLOCKS_WIDE 10
`define BLOCKS_HIGH 22
`define BOARD_WIDTH (`BLOCKS_WIDE * `BLOCK_SIZE)
`define BOARD_X (((`PIXEL_WIDTH - `BOARD_WIDTH) / 2) - 1)
`define BOARD_HEIGHT (`BLOCKS_HIGH * `BLOCK_SIZE)
`define BOARD_Y (((`PIXEL_HEIGHT - `BOARD_HEIGHT) / 2) - 1)
`define BITS_BLK_POS 8
`define BITS_X_POS 4
`define BITS_Y_POS 5
`define BITS_ROT 2
`define BITS_BLK_SIZE 3
`define BITS_SCORE 14
`define BITS_PER_BLOCK 3
`define EMPTY_BLOCK 3'b000
`define I_BLOCK 3'b001
`define O_BLOCK 3'b010
`define T_BLOCK 3'b011
`define S_BLOCK 3'b100
`define Z_BLOCK 3'b101
`define J_BLOCK 3'b110
`define L_BLOCK 3'b111
`define WHITE 8'b11111111
`define BLACK 8'b00000000
`define GRAY 8'b10100100
`define CYAN 8'b11110000
`define YELLOW 8'b00111111
`define PURPLE 8'b11000111
`define GREEN 8'b00111000
`define RED 8'b00000111
`define BLUE 8'b11000000
`define ORANGE 8'b00011111
`define ERR_BLK_POS 8'b11111111
`define DROP_TIMER_MAX 10000
module calc_test_pos_rot(
    input wire [`MODE_BITS-1:0]  mode,
    input wire                   game_clk_rst,
    input wire                   game_clk,
    input wire                   btn_left_en,
    input wire                   btn_right_en,
    input wire                   btn_rotate_en,
    input wire [`BITS_X_POS-1:0] cur_pos_x,
    input wire [`BITS_Y_POS-1:0] cur_pos_y,
    input wire [`BITS_ROT-1:0]   cur_rot,
    output reg [`BITS_X_POS-1:0] test_pos_x,
    output reg [`BITS_Y_POS-1:0] test_pos_y,
    output reg [`BITS_ROT-1:0]   test_rot
    );

    always @ (*) begin
        if (mode == `MODE_PLAY) begin
            if (game_clk) begin
                test_pos_x = cur_pos_x;
                test_pos_y = cur_pos_y + 1; // move down
                test_rot = cur_rot;
            end else if (btn_left_en) begin
                test_pos_x = cur_pos_x - 1; // move left
                test_pos_y = cur_pos_y;
                test_rot = cur_rot;
            end else if (btn_right_en) begin
                test_pos_x = cur_pos_x + 1; // move right
                test_pos_y = cur_pos_y;
                test_rot = cur_rot;
            end else if (btn_rotate_en) begin
                test_pos_x = cur_pos_x;
                test_pos_y = cur_pos_y;
                test_rot = cur_rot + 1; // rotate
            end else begin
                // do nothing, the block isn't moving this cycle
                test_pos_x = cur_pos_x;
                test_pos_y = cur_pos_y;
                test_rot = cur_rot;
            end
        end else begin
            // Other mode, do nothing
            test_pos_x = cur_pos_x;
            test_pos_y = cur_pos_y;
            test_rot = cur_rot;
        end
    end

endmodule

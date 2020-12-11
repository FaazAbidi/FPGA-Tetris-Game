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
module calc_cur_blk(
    input wire [`BITS_PER_BLOCK-1:0] piece,
    input wire [3:0] pos_x,
    input wire [4:0] pos_y,
    input wire [1:0] rot,
    output reg [7:0] blk_1,
    output reg [7:0] blk_2,
    output reg [7:0] blk_3,
    output reg [7:0] blk_4,
    output reg [2:0] width,
    output reg [2:0] height
    );
    
    
    always @ (*) begin
        case (piece)
            `EMPTY_BLOCK: begin
                 blk_1 = `ERR_BLK_POS;
                 blk_2 = `ERR_BLK_POS;
                 blk_3 = `ERR_BLK_POS;
                 blk_4 = `ERR_BLK_POS;
                 width = 0;
                 height = 0;
            end
            `I_BLOCK: begin
                 if (rot == 0 || rot == 2) begin
                     blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                     blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                     blk_3 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x;
                     blk_4 = ((pos_y + 3) * `BLOCKS_WIDE) + pos_x;
                     width = 1;
                     height = 4;
                 end else begin
                     blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                     blk_2 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                     blk_3 = (pos_y * `BLOCKS_WIDE) + pos_x + 2;
                     blk_4 = (pos_y * `BLOCKS_WIDE) + pos_x + 3;
                     width = 4;
                     height = 1;
                 end
            end
            `O_BLOCK: begin
                blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                blk_2 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                blk_3 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                width = 2;
                height = 2;
            end
            `T_BLOCK: begin
                case (rot)
                    0: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                        blk_3 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 2;
                        width = 3;
                        height = 2;
                    end
                    1: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                        blk_3 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x;
                        blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                        width = 2;
                        height = 3;
                    end
                    2: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                        blk_2 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                        blk_3 = (pos_y * `BLOCKS_WIDE) + pos_x + 2;
                        blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                        width = 3;
                        height = 2;
                    end
                    3: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_3 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                        width = 2;
                        height = 3;
                    end
                endcase
            end
            `S_BLOCK: begin
                if (rot == 0 || rot == 2) begin
                    blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                    blk_2 = (pos_y * `BLOCKS_WIDE) + pos_x + 2;
                    blk_3 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                    blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                    width = 3;
                    height = 2;
                end else begin
                    blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                    blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                    blk_3 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                    blk_4 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x + 1;
                    width = 2;
                    height = 3;
                end
            end
            `Z_BLOCK: begin
                if (rot == 0 || rot == 2) begin
                    blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                    blk_2 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                    blk_3 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                    blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 2;
                    width = 3;
                    height = 2;
                end else begin
                    blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                    blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                    blk_3 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x;
                    blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                    width = 2;
                    height = 3;
                end
            end
            `J_BLOCK: begin
                case (rot)
                    0: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_3 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_4 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x;
                        width = 2;
                        height = 3;
                    end
                    1: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                        blk_3 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 2;
                        width = 3;
                        height = 2;
                    end
                    2: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                        blk_3 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x;
                        blk_4 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                        width = 2;
                        height = 3;
                    end
                    3: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                        blk_2 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                        blk_3 = (pos_y * `BLOCKS_WIDE) + pos_x + 2;
                        blk_4 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 2;
                        width = 3;
                        height = 2;
                    end
                endcase
            end
            `L_BLOCK: begin
                case (rot)
                    0: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                        blk_3 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x;
                        blk_4 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x + 1;
                        width = 2;
                        height = 3;
                    end
                    1: begin
                        blk_1 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                        blk_2 = (pos_y * `BLOCKS_WIDE) + pos_x;
                        blk_3 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                        blk_4 = (pos_y * `BLOCKS_WIDE) + pos_x + 2;
                        width = 3;
                        height = 2;
                    end
                    2: begin
                        blk_1 = (pos_y * `BLOCKS_WIDE) + pos_x + 1;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_3 = ((pos_y + 2) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_4 = (pos_y * `BLOCKS_WIDE) + pos_x;
                        width = 2;
                        height = 3;
                    end
                    3: begin
                        blk_1 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x;
                        blk_2 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 1;
                        blk_3 = ((pos_y + 1) * `BLOCKS_WIDE) + pos_x + 2;
                        blk_4 = (pos_y * `BLOCKS_WIDE) + pos_x + 2;
                        width = 3;
                        height = 2;
                    end
                endcase
            end
        endcase
    end

endmodule

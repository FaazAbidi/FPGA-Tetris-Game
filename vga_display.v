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

module vga_display(
    input wire                                   clk,
    input wire [`BITS_PER_BLOCK-1:0]             cur_piece,
    input wire [`BITS_BLK_POS-1:0]               cur_blk_1,
    input wire [`BITS_BLK_POS-1:0]               cur_blk_2,
    input wire [`BITS_BLK_POS-1:0]               cur_blk_3,
    input wire [`BITS_BLK_POS-1:0]               cur_blk_4,
    input wire [(`BLOCKS_WIDE*`BLOCKS_HIGH)-1:0] fallen_pieces,
    output reg [7:0]                             rgb,
    output wire                                  hsync,
    output wire                                  vsync
    );

    reg [9:0] counter_x = 0;
    reg [9:0] counter_y = 0;
 
    assign hsync = ~(counter_x >= (`PIXEL_WIDTH + `HSYNC_FRONT_PORCH) &&
                     counter_x < (`PIXEL_WIDTH + `HSYNC_FRONT_PORCH + `HSYNC_PULSE_WIDTH));
    assign vsync = ~(counter_y >= (`PIXEL_HEIGHT + `VSYNC_FRONT_PORCH) &&
                     counter_y < (`PIXEL_HEIGHT + `VSYNC_FRONT_PORCH + `VSYNC_PULSE_WIDTH));
    wire [9:0] cur_blk_index = ((counter_x-`BOARD_X)/`BLOCK_SIZE) + (((counter_y-`BOARD_Y)/`BLOCK_SIZE)*`BLOCKS_WIDE);
    reg [2:0] cur_vid_mem;
    always @ (*) begin
        if (counter_x >= `BOARD_X && counter_y >= `BOARD_Y &&
            counter_x <= `BOARD_X + `BOARD_WIDTH && counter_y <= `BOARD_Y + `BOARD_HEIGHT) begin
            if (counter_x == `BOARD_X || counter_x == `BOARD_X + `BOARD_WIDTH ||
                counter_y == `BOARD_Y || counter_y == `BOARD_Y + `BOARD_HEIGHT) begin
                rgb = `WHITE;
            end else begin
                if (cur_blk_index == cur_blk_1 ||
                    cur_blk_index == cur_blk_2 ||
                    cur_blk_index == cur_blk_3 ||
                    cur_blk_index == cur_blk_4) begin
                    case (cur_piece)
                        `EMPTY_BLOCK: rgb = `GRAY;
                        `I_BLOCK: rgb = `CYAN;
                        `O_BLOCK: rgb = `YELLOW;
                        `T_BLOCK: rgb = `PURPLE;
                        `S_BLOCK: rgb = `GREEN;
                        `Z_BLOCK: rgb = `RED;
                        `J_BLOCK: rgb = `BLUE;
                        `L_BLOCK: rgb = `ORANGE;
                    endcase
                end else begin
                    rgb = fallen_pieces[cur_blk_index] ? `WHITE : `GRAY;
                end
            end
        end else begin
            rgb = `BLACK;
        end
    end

   always @ (posedge clk) begin
       if (counter_x >= `PIXEL_WIDTH + `HSYNC_FRONT_PORCH + `HSYNC_PULSE_WIDTH + `HSYNC_BACK_PORCH) begin
           counter_x <= 0;
           if (counter_y >= `PIXEL_HEIGHT + `VSYNC_FRONT_PORCH + `VSYNC_PULSE_WIDTH + `VSYNC_BACK_PORCH) begin
               counter_y <= 0;
           end else begin
               counter_y <= counter_y + 1;
           end
       end else begin
           counter_x <= counter_x + 1;
       end
   end

endmodule

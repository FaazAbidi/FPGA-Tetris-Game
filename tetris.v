//Constants 
`define PIXEL_WIDTH 640 //Size of the screen 
`define PIXEL_HEIGHT 480 // Height of the screen
`define BLOCK_SIZE 20
`define BLOCKS_WIDE 10
`define BLOCKS_HIGH 22
`define new_generated_block_WIDTH (`BLOCKS_WIDE * `BLOCK_SIZE)
`define new_generated_block_HEIGHT (`BLOCKS_HIGH * `BLOCK_SIZE)
`define new_generated_block_X (((`PIXEL_WIDTH - `new_generated_block_WIDTH) / 2) - 1) 
`define new_generated_block_Y (((`PIXEL_HEIGHT - `new_generated_block_HEIGHT) / 2) - 1)
//(new_generated_block_X,new_generated_block_Y) is the starting position of the new_generated_block
//TNumber of bots used for each staorage
`define BITS_BLK_POS 8 // position of each block
`define BITS_X_POS 4
`define BITS_Y_POS 5
`define BITS_ROT 2
`define BITS_BLK_SIZE 3
`define BITS_SCORE 14 //currently the score logic is incomplete
`define BITS_PER_BLOCK 3
// The type of each block
`define EMPTY_BLOCK 3'b000
`define I_BLOCK 3'b001
`define O_BLOCK 3'b010
`define T_BLOCK 3'b011
`define S_BLOCK 3'b100
`define Z_BLOCK 3'b101
`define J_BLOCK 3'b110
`define L_BLOCK 3'b111
// Colors
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
// Error value
`define ERR_BLK_POS 8'b11111111
//main game state constant
`define STATE_BITS 2
`define STATE_PLAY 0
`define STATE_DROP 3
`define STATE_RESET 1
`define STATE_RCOMPLETE 2
`define DROP_TIMER_MAX 10000


module top_level_module(initail_clock,rotate,left,right,rst,rgb,hsync,vsync,seg);
    input wire        initail_clock;
    input wire        rotate;
    input wire        left;
    input wire        right;
    input wire        rst;
    output wire [7:0] rgb;
    output wire       hsync;
    output wire       vsync;
    output wire [7:0] seg;

    // clock divider
    reg clk_count;
    reg clk;
    initial begin
        clk_count = 0;
        clk = 0;
    end
    always @ (posedge initail_clock) begin
        clk_count <= ~clk_count;
        if (clk_count) begin
            clk <= ~clk;
        end
    end

    reg [31:0] drop_timer; //helps is enabling the drop mode by reaching to max value
    initial begin
        drop_timer = 0;
    end

    wire [`BITS_PER_BLOCK-1:0] new_generated_block;
    block_sequence block_sequence_ (
        .clk(clk),
        .random(new_generated_block)
    );

    reg [219:0] board_matrix;

    reg [`BITS_PER_BLOCK-1:0] cur_piece;
    reg [`BITS_X_POS-1:0] cur_pos_x;
    reg [`BITS_Y_POS-1:0] cur_pos_y;
    reg [`BITS_ROT-1:0] cur_rot;
    wire [`BITS_BLK_POS-1:0] cur_blk_1;
    wire [`BITS_BLK_POS-1:0] cur_blk_2;
    wire [`BITS_BLK_POS-1:0] cur_blk_3;
    wire [`BITS_BLK_POS-1:0] cur_blk_4;
    wire [`BITS_BLK_SIZE-1:0] cur_width;
    wire [`BITS_BLK_SIZE-1:0] cur_height;

    calc_cur_blk calc_cur_blk_ (
        .piece(cur_piece),
        .pos_x(cur_pos_x),
        .pos_y(cur_pos_y),
        .rot(cur_rot),
        .blk_1(cur_blk_1),
        .blk_2(cur_blk_2),
        .blk_3(cur_blk_3),
        .blk_4(cur_blk_4),
        .width(cur_width),
        .height(cur_height)
    );

    vga_display display_ (
        .clk(clk),
        .cur_piece(cur_piece),
        .cur_blk_1(cur_blk_1),
        .cur_blk_2(cur_blk_2),
        .cur_blk_3(cur_blk_3),
        .cur_blk_4(cur_blk_4),
        .board_matrix(board_matrix),
        .rgb(rgb),
        .hsync(hsync),
        .vsync(vsync)
    );

    reg [`STATE_BITS-1:0] mode;
    wire game_clk;
    reg game_clk_rst;

    game_clock game_clock_ (
        .clk(clk),
        .rst(game_clk_rst),
        .pause(mode != `STATE_PLAY),
        .game_clk(game_clk)
    );

    wire [`BITS_X_POS-1:0] test_pos_x;
    wire [`BITS_Y_POS-1:0] test_pos_y;
    wire [`BITS_ROT-1:0] test_rot;

    calc_test_pos_rot calc_test_pos_rot_ (
        .mode(mode),
        .game_clk_rst(game_clk_rst),
        .game_clk(game_clk),
        .left(left),
        .right(right),
        .rotate(rotate),
        .cur_pos_x(cur_pos_x),
        .cur_pos_y(cur_pos_y),
        .cur_rot(cur_rot),
        .test_pos_x(test_pos_x),
        .test_pos_y(test_pos_y),
        .test_rot(test_rot)
    );

    wire [`BITS_BLK_POS-1:0] test_blk_1;
    wire [`BITS_BLK_POS-1:0] test_blk_2;
    wire [`BITS_BLK_POS-1:0] test_blk_3;
    wire [`BITS_BLK_POS-1:0] test_blk_4;
    wire [`BITS_BLK_SIZE-1:0] test_width;
    wire [`BITS_BLK_SIZE-1:0] test_height;

    calc_cur_blk calc_test_block_ (
        .piece(cur_piece),
        .pos_x(test_pos_x),
        .pos_y(test_pos_y),
        .rot(test_rot),
        .blk_1(test_blk_1),
        .blk_2(test_blk_2),
        .blk_3(test_blk_3),
        .blk_4(test_blk_4),
        .width(test_width),
        .height(test_height)
    );


    function intersects_board_matrix;
        input wire [7:0] blk1;
        input wire [7:0] blk2;
        input wire [7:0] blk3;
        input wire [7:0] blk4;
        begin
            intersects_board_matrix = board_matrix[blk1] ||
                                       board_matrix[blk2] ||
                                       board_matrix[blk3] ||
                                       board_matrix[blk4];
        end
    endfunction


    wire test_intersects = intersects_board_matrix(test_blk_1, test_blk_2, test_blk_3, test_blk_4);

    task move_left;
        begin
            if (cur_pos_x > 0 && !test_intersects) begin
                cur_pos_x <= cur_pos_x - 1;
            end
        end
    endtask

    task move_right;
        begin
            if (cur_pos_x + cur_width < `BLOCKS_WIDE && !test_intersects) begin
                cur_pos_x <= cur_pos_x + 1;
            end
        end
    endtask

    task rotate;
        begin
            if (cur_pos_x + test_width <= `BLOCKS_WIDE &&
                cur_pos_y + test_height <= `BLOCKS_HIGH &&
                !test_intersects) begin
                cur_rot <= cur_rot + 1;
            end
        end
    endtask

    task add_to_board_matrix;
        begin
            board_matrix[cur_blk_1] <= 1;
            board_matrix[cur_blk_2] <= 1;
            board_matrix[cur_blk_3] <= 1;
            board_matrix[cur_blk_4] <= 1;
        end
    endtask

    task get_new_block;
        begin
            drop_timer <= 0;
            cur_piece <= new_generated_block;
            cur_pos_x <= (`BLOCKS_WIDE / 2) - 1;
            cur_pos_y <= 0;
            cur_rot <= 0;
            game_clk_rst <= 1;
        end
    endtask

    task move_down;
        begin
            if (cur_pos_y + cur_height < `BLOCKS_HIGH && !test_intersects) begin
                cur_pos_y <= cur_pos_y + 1;
            end else begin
                add_to_board_matrix();
                get_new_block();
            end
        end
    endtask

    task drop_to_bottom;
        begin
            mode <= `STATE_DROP;
        end
    endtask

    reg [3:0] score_1; 
    reg [3:0] score_2; 
    reg [3:0] score_3; 
    reg [3:0] score_4; 
    
    wire [`BITS_Y_POS-1:0] remove_row_y;
    wire remove_row_en;
    complete_row complete_row_ (
        .clk(clk),
        .pause(mode != `STATE_PLAY),
        .board_matrix(board_matrix),
        .row(remove_row_y),
        .enabled(remove_row_en)
    );

    reg [`BITS_Y_POS-1:0] shifting_row;
    task remove_row;
        begin
            mode <= `STATE_RCOMPLETE;
            shifting_row <= remove_row_y;
            if (score_1 == 9) begin
                if (score_2 == 9) begin
                    if (score_3 == 9) begin
                        if (score_4 != 9) begin
                            score_4 <= score_4 + 1;
                            score_3 <= 0;
                            score_2 <= 0;
                            score_1 <= 0;
                        end
                    end else begin
                        score_3 <= score_3 + 1;
                        score_2 <= 0;
                        score_1 <= 0;
                    end
                end else begin
                    score_2 <= score_2 + 1;
                    score_1 <= 0;
                end
            end else begin
                score_1 <= score_1 + 1;
            end
        end
    endtask

    initial begin
        mode = `STATE_RESET;
        board_matrix = 0;
        cur_piece = `EMPTY_BLOCK;
        cur_pos_x = 0;
        cur_pos_y = 0;
        cur_rot = 0;
        score_1 = 0;
        score_2 = 0;
        score_3 = 0;
        score_4 = 0;
    end

    task start_game;
        begin
            mode <= `STATE_PLAY;
            board_matrix <= 0;
            score_1 <= 0;
            score_2 <= 0;
            score_3 <= 0;
            score_4 <= 0;
            get_new_block();
        end
    endtask

    wire game_over = cur_pos_y == 0 && intersects_board_matrix(cur_blk_1, cur_blk_2, cur_blk_3, cur_blk_4);

    always @ (posedge clk) begin
        if (drop_timer < `DROP_TIMER_MAX) begin
            drop_timer <= drop_timer + 1;
        end
        game_clk_rst <= 0;
        if (mode == `STATE_RESET && (rst_en || rst_dis)) begin
            start_game();
        end else if (rst_en || rst_dis || game_over) begin
            mode <= `STATE_RESET;
            add_to_board_matrix();
            cur_piece <= `EMPTY_BLOCK;
        end else if (mode == `STATE_PLAY) begin
            if (game_clk) begin
                move_down();
            end else if (left) begin
                move_left();
            end else if (right) begin
                move_right();
            end else if (rotate) begin
                rotate();
            end else if (remove_row_en) begin
                remove_row();
            end
        end else if (mode == `STATE_DROP) begin
            if (game_clk_rst && !sw_pause_en) begin
                mode <= `STATE_PLAY;
            end else begin
                move_down();
            end
        end else if (mode == `STATE_RCOMPLETE) begin
            if (shifting_row == 0) begin
                board_matrix[0 +: `BLOCKS_WIDE] <= 0;
                mode <= `STATE_PLAY;
            end else begin
                board_matrix[shifting_row*`BLOCKS_WIDE +: `BLOCKS_WIDE] <= board_matrix[(shifting_row - 1)*`BLOCKS_WIDE +: `BLOCKS_WIDE];
                shifting_row <= shifting_row - 1;
            end
        end
    end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2020 02:06:29 PM
// Design Name: 
// Module Name: tetris_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tetris_testbench;
  reg X;
  reg clk;
  reg btn_drop;
  reg btn_left;
  reg btn_right;
  reg btn_down;
  reg btn_rotate;
  reg sw_pause;
  reg sw_rst;
  wire [7:0] rgb;
  wire hsync;
  wire vsync;
  
  top_level_module t1(
    .clk_too_fast(clk),
    .btn_drop(btn_drop),
    .btn_rotate(btn_rotate),
    .btn_left(btn_left),
    .btn_right(btn_right),
    .btn_down(btn_down),
    .sw_pause(sw_pause),
    .sw_rst(sw_rst),
    .rgb(rgb),
    .hsync(hsync),
    .vsync(vsync),
    .seg(seg),
    );
    
  initial begin
    btn_drop <= 1'b1;
    btn_left <= 1'b0;
    btn_right <= 1'b0;
    btn_down <= 1'b0;
    btn_rotate <= 1'b0;
    sw_pause <= 1'b0;
    sw_rst <= 1'b0;
    clk <= 1'b0;
  end 
  
  always 
    #3 clk <= ~clk;
    
  always @(posedge clk) begin
    #6  
    btn_drop <= 1'b1;
  end


endmodule

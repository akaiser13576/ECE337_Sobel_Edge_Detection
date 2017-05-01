// $Id: $
// File name:   sobel_edge_detection.sv
// Created:     4/24/2017
// Author:      Imad Sheriff
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Wrapper File for all modules

// TODO:
/*
For process to be completed, pixAddress has to be set to 0x4 from window slider and wdata should be set to 1 (can send image_done signal from controller to out_buffer)
*/


module sobel_edge_detection
(
	input wire clk, 	
	input wire n_rst,
	input wire start,	// Start signal coming from the Avalon Bus Slave 
	input wire data_ready,
	input wire [31:0] read_word,	        // 32 bit data coming from the Avalon Bus
	input wire [31:0] image_start_addr,	// Input Image starting address coming from the Avalon Bus Slave
	input wire [31:0] out_start_addr,	// Output Image starting address coming from the Avalon Bus Slave
	output reg [31:0] sobel_pixel,		// edge detected pixel sent to Avalon Bus Master
	output reg [31:0] pixAddress,		// pixel address of original image sent to Master
	//output reg [31:0] endpixel,
	//output reg [31:0] write_addr		// Address of where to write in the output image sent to Avalon Bus Master
	output reg read_enable,				// Signal to get pixel data sent to Avalon Bus Master
	output reg write_out_enable,		// Signal to send the data over to the Avalon Bus Master
	output reg sobel_complete
);
//reg sobel_complete;
reg start_en;
reg store_en;
reg [3:0][23:0] pixelsBuffer;
reg gray_en;
reg [3:0][7:0] grayedBuffer;
reg gray_done;
reg edge_detected;
reg computeSobel;
reg [2:0][7:0][7:0] computationBuffer;
reg [2:0] counter;
//reg [2:0] option;
reg [2:0][2:0][7:0] sobel_matrix;
reg sobel_ready;
reg sobel_done;
reg nx_pixel_en;
reg addr_done;
reg image_done;
reg out_en;
reg out_empty;
reg out_full;
reg out_pixel;
reg tempSobel_pixel;
reg fill;
reg getMatrix;
//reg write_out_enable;

// Master-Slave Interface Signals



//avalonMasterFSM master (.clk(clk), .n_rst(n_rst), .readdata(/*FILL IN*/), .readen(read_en), .write_en(write_out_enable), .wdata(sobel_pixel), .in_addr(write_addr), .
//avalonSlaveFSM slave (.clk(clk), .n_rst(n_rst), . 


preGrayScale fillBuffer (.clk(clk), .n_rst(n_rst), .read_word(read_word), .start_en(start_en), .store_en(store_en), .out_pixels(pixelsBuffer), .gray_en(gray_en));
grayscale grayBuffer (.clk(clk), .n_rst(n_rst), .in_pixel_buffer(pixelsBuffer), .gray_en(gray_en), .gray_pixel(grayedBuffer), .gray_done(gray_done));
calculateCompBuffer fillCompBuffer (.clk(clk), .n_rst(n_rst), .grayed_done(gray_done), .grayed_pixels(grayedBuffer), .edge_detected(edge_detected), .getMatrix(getMatrix), .computeSobel(computeSobel), .out_buffer(computationBuffer), .fill(fill), .next_counter(counter));
sobel_controller getSobelMatrix (.clk(clk), .n_rst(n_rst), .option(counter), .in_buffer(computationBuffer), .computeSobel(computeSobel), .sobel_matrix(sobel_matrix), .sobel_ready(sobel_ready));
sobel_edge sobelCalc (.sobel_en(sobel_ready), .comp_matrix(sobel_matrix), .output_pixel(out_pixel), .sobel_done(sobel_done));
window_slider window (.clk(clk), .n_rst(n_rst), .nx_pixel_en(nx_pixel_en), .image_start_addr(image_start_addr), .next_edge_detected(edge_detected), .addr_done(addr_done), .next_calc_address(pixAddress), .next_last_pix_read(image_done));
outputBuffer outData (.clk(clk), .n_rst(n_rst), .edge_pixel(tempSobel_pixel), .out_en(out_en), .write_out_enable(write_out_enable), .img_done(sobel_complete), .out_empty(out_empty), .out_full(out_full), .endpixel(out_start_addr), .out_pixel(sobel_pixel), .write_addr(pixAddress));
controller controlUnit (.clk(clk), .n_rst(n_rst), .start(start), .addr_done(addr_done), .gray_en(gray_en), .gray_done(gray_done), .computeSobel(computeSobel), .sobel_ready(sobel_ready), .image_done(image_done), .sobel_complete(sobel_complete), .nx_pixel_en(nx_pixel_en), .read_enable(read_enable), .pre_gray_start_en(start_en), .pre_gray_store_en(store_en), .out_pixel(tempSobel_pixel), .out_en(out_en), .out_full(out_full), .out_empty(out_empty), .data_ready(data_ready), .sobel_pixel(out_pixel), .compBufferFill(fill), .getMatrix(getMatrix), .write_out_enable(write_out_enable));

endmodule

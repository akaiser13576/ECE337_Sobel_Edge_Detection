// $Id: $
// File name:   avalonBus.sv
// Created:     4/25/2017
// Author:      Imad Sheriff
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Avalon Bus to interface with Sobel Edge Detection


module avalonBus
(
	input wire clk,
	input wire n_rst,
	// Slave
	input wire slave_read,
	input wire slave_write,
	input wire [31:0] slave_writedata,
	input wire [31:0] slave_addr,
	output reg [31:0] slave_readdata,

	// Master
	input wire [31:0] master_readdata,
	output reg master_read,
	output reg master_write,
	output reg [31:0] master_addr,
	output reg [31:0] master_writedata,
	output reg sobel_complete
);

// To Controller
reg [31:0] startpixel; // Address 1
reg [31:0] endpixel;   // Address 2
reg [31:0] status;    // Address 3
reg [31:0] control;   // Address 4
reg dataready;


// From Controller
reg read_en;
reg write_out_en;
reg [31:0] inaddr;
reg [31:0] sobel_pixel;


// TODO: FINISH WRAPPER FILES AND INTERFACE WITH REST OF MODULE
avalonMasterFSM master (.clk(clk), .n_rst(n_rst), .readdata(master_readdata), .readen(read_en), .writen(write_out_en), .wdata(sobel_pixel), .inaddr(inaddr), .read(master_read), .write(master_write), .dataready(dataready), .address(master_addr), .writedata(master_writedata));
avalonSlaveFSM slave (.clk(clk), .n_rst(n_rst), .read(slave_read), .write(slave_write), .address(slave_addr), .writedata(slave_writedata), .readdata(slave_readdata), .startpixel(startpixel), .endpixel(endpixel), .status(status), .control(control));
sobel_edge_detection sobel (.clk(clk), .n_rst(n_rst), .start(control[0]), .data_ready(dataready), .read_word(master_readdata), .image_start_addr(startpixel), .out_start_addr(endpixel), .sobel_pixel(sobel_pixel), .pixAddress(inaddr), .read_enable(read_en), .write_out_enable(write_out_en), .sobel_complete(sobel_complete)); 

endmodule

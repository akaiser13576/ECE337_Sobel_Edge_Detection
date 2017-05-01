// $Id: $
// File name:   adrdecoder.sv
// Created:     4/7/2017
// Author:      Pradyumna Modukuru
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: address decoder for Avalon slave module
// 

module adrdecoder(
	input wire enable, clk, n_rst,
	input wire [31:0] address, writedata,
	output reg [31:0] readdata,

	//global registers
	output reg [31:0] startpixel, //1
	output reg [31:0] endpixel,  //2
	output reg [31:0] status,   //3
	output reg [31:0] control  //4
	
);

always_ff @ (posedge clk, negedge n_rst)
begin
	if( n_rst == 1'b0)
        begin
		startpixel <= 0;
		endpixel <= 0;
		status <= 0;
		control <= 0;
	end
	else
	begin	
		if (enable && address == 32'd1)
		begin
			startpixel <= writedata;
		end
		else if (enable && address == 32'd2)
		begin
			endpixel <= writedata;
		end
		else if (enable && address == 32'd3)
		begin
			readdata <= status;
		end
		else if (enable && address == 32'd4)
		begin
			control <= writedata;
		end
	end
end


endmodule

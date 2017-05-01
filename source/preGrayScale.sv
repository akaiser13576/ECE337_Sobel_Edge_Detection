// $Id: $
// File name:   preGrayScale.sv
// Created:     4/23/2017
// Author:      Imad Sheriff
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Storing 32 bit values in buffer

module preGrayScale 
(
	input wire clk,
	input wire n_rst,
	input wire [31:0]  read_word,
	input wire start_en,
	input wire store_en,
	output reg [3:0][23:0] out_pixels,
	output reg gray_en
);

reg [3:0][23:0] in_pixels;
reg [7:0] temp1, next_temp1;
reg [15:0] temp2, next_temp2;
typedef enum bit [1:0] {IDLE, EXTRACT1, EXTRACT2, EXTRACT3} stateType;
stateType state;
stateType next_state;

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 1'b0) begin
		state <= IDLE;
		in_pixels <= {24'd0, 24'd0, 24'd0, 24'd0};
		temp1 <= 0;
		temp2 <= 0;
	end
	else begin
		state <= next_state;
		in_pixels <= out_pixels;
		temp1 <= next_temp1;
		temp2 <= next_temp2;
	end
end

always_comb begin
	next_state = state;
	out_pixels = in_pixels;
	gray_en = 0;
	next_temp1 = temp1;
	next_temp2 = temp2;
	
	case (state) 
		IDLE: begin
			if (start_en == 1) begin
				next_state = EXTRACT1;
			end
		end
		EXTRACT1: begin
			if (store_en == 1) begin
				out_pixels[3] = read_word[31:8];
				next_temp1 = read_word[7:0];
				next_state = EXTRACT2;
			end
		end
		EXTRACT2: begin
			if (store_en == 1) begin
				out_pixels[2] = {next_temp1, read_word[31:16]};
				next_temp2 = read_word[15:0];
				next_state = EXTRACT3;
			end
		end
		EXTRACT3: begin
			if (store_en == 1) begin
				out_pixels[1] = {next_temp2, read_word[31:24]};
				out_pixels[0] = read_word[23:0];
				gray_en = 1;
				next_state = EXTRACT1;
			end
		end
	endcase
end
endmodule

	
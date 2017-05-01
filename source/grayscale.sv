// $Id: $
// File name:   grayscale.sv
// Created:     4/10/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Grayscale computation buffer for sobel edge detector.
module grayscale
(
	input wire clk,    
	input wire n_rst, 
	input wire [3:0][23:0] in_pixel_buffer,
	input wire gray_en,
	output reg [3:0][7:0] gray_pixel,
	output reg gray_done
);


	typedef enum bit [2:0] {IDLE, GRAY_1, GRAY_2, GRAY_3, GRAY_4, DONE} stateType;
	stateType state;
	stateType nxt_state;

	reg [7:0] gray_pixel_r, gray_pixel_g, gray_pixel_b, gray_1, gray_2;
	reg [8:0] grayscaled_value;
	reg [31:0] tmp_gray_pixel;

	// REGISTER LOGIC
	always_ff @ (posedge clk, negedge n_rst) begin : REG_LOGIC	
		if(n_rst == 1'b0) begin
			state <= IDLE;
		end else begin
			state <= nxt_state;
		end
	end


	// NEXT STATE LOGIC
	always_comb begin : NXT_LOGIC
		
		case(state) IDLE: begin
			if(gray_en == 1'b1) begin
				nxt_state = GRAY_1;
				gray_done = 1'b0;
				gray_pixel = 8'd0;
			end else begin
				gray_done = 1'b0;
				gray_pixel = 8'd0;
				nxt_state = IDLE;
			end
			end GRAY_1: begin
				//grayscale
				gray_pixel_r = {2'b00, in_pixel_buffer[3][23:18]};  // 0.25 * Red, 8bits
				gray_pixel_g = {2'b00, in_pixel_buffer[3][15:10]};  // 0.25 * Green, 8bits
				gray_pixel_b = {4'b0000, in_pixel_buffer[3][7:4]};  // 0.0625 * Blue, 8bits
				gray_1 = gray_pixel_r + {gray_pixel_g[6:0], 1'b0};  // (0.25 * Red) + (0.5 * Green)
				gray_2 = gray_pixel_b + gray_pixel_g;		    // (0.0625 * Blue) + (0.25 * Green)
				grayscaled_value = gray_1 + gray_2;		    // (0.25 * Read) + (0.75 * Green) + (0.0625 * Blue)

				// Check overflow and set output
				if(grayscaled_value[8] == 1'b1)
					tmp_gray_pixel[31:24] = 8'd255;
				else
					tmp_gray_pixel[31:24] = grayscaled_value[7:0];

				gray_done = 1'b0;
				nxt_state = GRAY_2;
			end GRAY_2: begin
				//grayscale
				gray_pixel_r = {2'b00, in_pixel_buffer[2][23:18]};  // 0.25 * Red, 8bits
				gray_pixel_g = {2'b00, in_pixel_buffer[2][15:10]};  // 0.25 * Green, 8bits
				gray_pixel_b = {4'b0000, in_pixel_buffer[2][7:4]};  // 0.0625 * Blue, 8bits
				gray_1 = gray_pixel_r + {gray_pixel_g[6:0], 1'b0};  // (0.25 * Red) + (0.5 * Green)
				gray_2 = gray_pixel_b + gray_pixel_g;		    // (0.0625 * Blue) + (0.25 * Green)
				grayscaled_value = gray_1 + gray_2;		    // (0.25 * Read) + (0.75 * Green) + (0.0625 * Blue)

				// Check overflow and set output
				if(grayscaled_value[8] == 1'b1)
					tmp_gray_pixel[23:16] = 8'd255;
				else
					tmp_gray_pixel[23:16] = grayscaled_value[7:0];

				gray_done = 1'b0;
				nxt_state = GRAY_3;
			end GRAY_3: begin
				//grayscale
				gray_pixel_r = {2'b00, in_pixel_buffer[1][23:18]};  // 0.25 * Red, 8bits
				gray_pixel_g = {2'b00, in_pixel_buffer[1][15:10]};  // 0.25 * Green, 8bits
				gray_pixel_b = {4'b0000, in_pixel_buffer[1][7:4]};  // 0.0625 * Blue, 8bits
				gray_1 = gray_pixel_r + {gray_pixel_g[6:0], 1'b0};  // (0.25 * Red) + (0.5 * Green)
				gray_2 = gray_pixel_b + gray_pixel_g;		    // (0.0625 * Blue) + (0.25 * Green)
				grayscaled_value = gray_1 + gray_2;		    // (0.25 * Read) + (0.75 * Green) + (0.0625 * Blue)

				// Check overflow and set output
				if(grayscaled_value[8] == 1'b1)
					tmp_gray_pixel[15:8] = 8'd255;
				else
					tmp_gray_pixel[15:8] = grayscaled_value[7:0];

				gray_done = 1'b0;
				nxt_state = GRAY_4;
			end GRAY_4: begin
				//grayscale
				gray_pixel_r = {2'b00, in_pixel_buffer[0][23:18]};  // 0.25 * Red, 8bits
				gray_pixel_g = {2'b00, in_pixel_buffer[0][15:10]};  // 0.25 * Green, 8bits
				gray_pixel_b = {4'b0000, in_pixel_buffer[0][7:4]};  // 0.0625 * Blue, 8bits
				gray_1 = gray_pixel_r + {gray_pixel_g[6:0], 1'b0};  // (0.25 * Red) + (0.5 * Green)
				gray_2 = gray_pixel_b + gray_pixel_g;		    // (0.0625 * Blue) + (0.25 * Green)
				grayscaled_value = gray_1 + gray_2;		    // (0.25 * Read) + (0.75 * Green) + (0.0625 * Blue)

				// Check overflow and set output
				if(grayscaled_value[8] == 1'b1)
					tmp_gray_pixel[7:0] = 8'd255;
				else
					tmp_gray_pixel[7:0] = grayscaled_value[7:0];

				gray_done = 1'b0;
				nxt_state = DONE;
			end DONE: begin
				gray_pixel= tmp_gray_pixel;
				gray_done = 1'b1;
				nxt_state = IDLE;
			end
		endcase
	end
endmodule

// $Id: $
// File name:   controller.sv
// Created:     4/24/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Main controller for Sobel Edge Detection.
module controller(
	input wire clk,
	input wire n_rst,
	input wire start,      // From Master/Slave
	input wire addr_done, 
	input wire gray_en,
	input wire gray_done,
	input wire computeSobel,
	input wire sobel_ready,
	input wire image_done,
	input wire out_full,
	input wire out_empty,
	input wire data_ready,   // From Master/Slave
	input wire sobel_pixel,
	input wire compBufferFill,
	output reg getMatrix,
	output reg sobel_complete,
	output reg nx_pixel_en,
	output reg read_enable, // To Master/Slave
	//output reg image_done,
	output reg pre_gray_start_en,
	output reg pre_gray_store_en,
	output reg out_pixel,
	output reg out_en,
	output reg write_out_enable // To Master/Slave
);


	typedef enum bit [4:0] {IDLE, GET_PIX_ADDR, FETCH_DATA, PRE_WAIT, STORE_PIX, WAIT, GRAYSCALE, CALC_BUFF, 
				WAIT2, GET_SOBEL_MATRIX, SOBEL_COMP, WAIT3, WAIT4, CHECK_OUT, STORE_OUT, CHECK_DONE, DONE, ENDDONE} stateType;
	stateType state;
	stateType next_state;
	reg storeOutPixel;
	reg needFill;
	

	// REGISTER LOGIC
	always_ff @ (posedge clk, negedge n_rst) begin : REG_LOGIC	
		if(n_rst == 1'b0) begin
			state <= IDLE;
		end else begin
		state <= next_state;
		end
	end
	
	// COMB LOGIC
	always_comb begin: NXT_LOGIC
		next_state = state;
		nx_pixel_en = 1'b0;
		read_enable = 1'b0;
		pre_gray_start_en = 1'b0;
		pre_gray_store_en = 1'b0;
		out_en = 1'b0;
		sobel_complete = 1'b0;
		write_out_enable = 1'b0;
		out_pixel = 0;
		getMatrix = 0;
		case(state)
			IDLE: begin
				if(start == 1'b1) 
					next_state = GET_PIX_ADDR;
			end GET_PIX_ADDR: begin
				nx_pixel_en = 1'b1;
				next_state = FETCH_DATA;
			end FETCH_DATA: begin
				if (addr_done == 1'b1) begin
					read_enable = 1'b1;
					pre_gray_start_en = 1;
					next_state = PRE_WAIT;
				end
			end PRE_WAIT: begin
				next_state = STORE_PIX;
			end STORE_PIX: begin
				if (data_ready == 1) begin
					pre_gray_store_en = 1'b1;				
					if(gray_en == 1'b1) 
						next_state = GRAYSCALE;
					else if(gray_en == 1'b0)
						next_state = GET_PIX_ADDR;
				end
			// gray_en gets asserted in STORE_PIX
			end WAIT: begin
				if(gray_en == 1'b1) 
					next_state = GRAYSCALE;
				else if(gray_en == 1'b0)
					next_state = GET_PIX_ADDR;
			end GRAYSCALE: begin
				if (gray_done == 1'b1) begin
					//getMatrix = 1;
					next_state = WAIT2;//CALC_BUFF; 				
				end
			end CALC_BUFF: begin 
				next_state = WAIT2;
			end WAIT2: begin
				getMatrix = 1;
				needFill = compBufferFill;
				if(computeSobel == 1'd1)
					next_state = GET_SOBEL_MATRIX;
				else if(computeSobel == 1'b0)
					next_state = GET_PIX_ADDR;
			end GET_SOBEL_MATRIX: begin
				if(sobel_ready == 1'b1)
					storeOutPixel = sobel_pixel; 
					next_state = CHECK_OUT;//SOBEL_COMP;
			end SOBEL_COMP: begin
				next_state = WAIT3;
			// WAIT FOR SOBEL ALOGORITHM TO FINISH
			end WAIT3: begin
				next_state = WAIT4;
			end WAIT4: begin
				next_state = CHECK_OUT;
			end CHECK_OUT: begin
				if (out_full == 0) begin 
					out_en = 1;
					out_pixel = storeOutPixel;
					
					next_state = CHECK_DONE;
				end
				else begin
					write_out_enable = 1;
					next_state = STORE_OUT;
				end
			end STORE_OUT: begin
				if (out_empty == 1) begin
					out_en = 1;
					out_pixel = storeOutPixel;
					next_state = CHECK_DONE;
				end
			end CHECK_DONE: begin
				if(image_done == 1'b0 && needFill == 1)
					next_state = GET_PIX_ADDR;
				else if (needFill == 0) begin
					next_state = WAIT2;
					//getMatrix = 1;
				end
				if(image_done == 1'b1)
					next_state = DONE;
			end DONE: begin
				if (out_empty == 1) 
					sobel_complete = 1;
				else 
					write_out_enable = 1;
					next_state = ENDDONE;
			end ENDDONE: begin
				sobel_complete = 1;
				if (out_empty == 1) 
					write_out_enable = 1;
			end
						
		endcase
	end
endmodule


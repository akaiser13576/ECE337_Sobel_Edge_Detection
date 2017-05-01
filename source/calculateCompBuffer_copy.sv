// $Id: $
// File name:   calculateCompBuffer.sv
// Created:     4/21/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Calculates the window for sobel operation.
module calculateCompBuffer(
	input wire clk,
	input wire n_rst,
	input wire grayed_done,
	input wire [3:0][7:0] grayed_pixels,
	input wire edge_detected,
	input wire getMatrix,
	//input wire [2:0][7:0][7:0] in_buffer,
	output reg computeSobel,
	output reg [2:0][7:0][7:0] out_buffer,
	//output reg fill_1st,
	//output reg fill_2nd,
	//output reg fill_edges,
	output reg [2:0] next_counter
);

typedef enum bit [3:0] {IDLE, FILL1, FILL2, FILL3, FILL4, FILL5, FILL6, FILL7, FILL8, INC, DEC, SHIFT} stateType;
stateType state;
stateType next_state;
reg shift_en, incdec, next_shift_en, next_incdec, edge_found, next_edge_found;
reg [2:0] counter;
reg [2:0][7:0][7:0] in_buffer;
reg computeSobel_prev;

// REGISTER LOGIC
always_ff @ (posedge clk, negedge n_rst) begin : REG_LOGIC	
	if(n_rst == 1'b0) begin
		state <= IDLE;
		counter <= 0;
		shift_en <= 0;
		incdec <= 1;
		edge_found <= 0;
		in_buffer  <= 		   {{8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0}};
		computeSobel_prev <= 0;
	end else begin
		state <= next_state;
		counter <= next_counter;
		shift_en <= next_shift_en;
		incdec <= next_incdec;
		edge_found <= next_edge_found;
		in_buffer <= out_buffer;
		computeSobel_prev <= computeSobel;
	end
end

always_comb begin: NXT_LOGIC
	next_state = state;
	computeSobel = computeSobel_prev;
	out_buffer  =  in_buffer;
	//out_buffer =   in_buffer;//'{'{0,0,0,0,0,0,0,0},
		       		 //'{0,0,0,0,0,0,0,0},
		      		 //'{0,0,0,0,0,0,0,0}};
 	next_edge_found = edge_found;
	next_counter = counter;
	next_shift_en = shift_en;
	next_incdec = incdec;
	//fill_1st = 0;
	//fill_2nd = 0;
	//fill_edges = 0;
	case(state)
		IDLE: begin
			//fill_1st = 1;
			next_state = FILL1;
		end
		FILL1: begin	
			computeSobel = 0;
			if (grayed_done == 1) begin
				//out_buffer[0][3:0][7:0] = grayed_pixels;
				out_buffer[2][7:4] = grayed_pixels;
				next_state = FILL2;
			end
			else begin
				next_state = FILL1;
			end
		end
		FILL2: begin
			if (grayed_done == 1) begin
				//out_buffer[1][3:0][7:0] = grayed_pixels;
				out_buffer[1][7:4] = grayed_pixels;
				next_state = FILL3;
			end
			else begin 
				next_state = FILL2;
			end
		end
		FILL3: begin
			if (grayed_done == 1) begin
				//out_buffer[2][3:0][7:0] = grayed_pixels;
				out_buffer[0][7:4] = grayed_pixels;
				if (incdec == 1 && shift_en == 0) 
					next_state = INC;
				else if (incdec == 0 && shift_en == 0) 
					next_state = DEC;
				else if (shift_en == 1) begin
					next_state = FILL6;
					//next_shift_en = 0;
				end
				if (edge_detected == 1)
					next_edge_found = 1;
			end
		end
		INC: begin
			if(computeSobel_prev == 1'b1)
				computeSobel = 0;
			else begin
				if (getMatrix == 1) begin
					computeSobel = 1;
					if (counter == 7) 
						next_counter = 0;
					else
						next_counter = counter + 1;
				end else if(next_counter == 0) begin
					fill = 1;
					next_state = FILL4;
					computeSobel = 1;
					next_counter = counter + 1;
				end else if (next_counter == 4 && edge_found == 0) begin
					fill = 1;
					next_counter = counter + 1;
					next_state = FILL1;
				end else if (next_counter == 4 && edge_found== 1) begin
					next_counter = counter + 1;
					next_edge_found = 0;
					next_state = SHIFT;
				end
			end
		end
		FILL4: begin
			computeSobel = 0;
			if (grayed_done == 1) begin
				//out_buffer = in_buffer[0][7:4][7:0];
				out_buffer[2][3:0] = grayed_pixels;
				next_state = FILL5;
			end
		end
		FILL5: begin
			if (grayed_done == 1) begin
				//out_buffer = in_buffer[1][7:4][7:0];
				out_buffer[1][3:0] = grayed_pixels;
				next_state = FILL6;
			end
		end
		FILL6: begin
			if (grayed_done == 1) begin
				//out_buffer = in_buffer[2][7:4][7:0];
				out_buffer[0][3:0] = grayed_pixels;
				if (shift_en == 1) begin		
					next_shift_en = 0;	
					computeSobel = 1;
				end
				if (edge_detected == 1) 
					next_edge_found = 1;
				if (incdec == 1) 
					next_state = INC;
				else if (incdec == 0) 
					next_state = DEC;
			end
		end
		DEC: begin
			if(computeSobel_prev == 1'b1)
				computeSobel = 0;
			else begin
				computeSobel = 1;
				if (counter == 0) 
					next_counter = 7;
				else
					next_counter = counter -1;
	
				if (next_counter == 4)
					fill = 1; 
					next_state = FILL1;
				else if (next_counter == 0 && edge_detected == 0) begin
					fill = 1;
					next_state = FILL4;
				end
				else if (next_counter == 0 && edge_detected == 1) begin
					next_state = SHIFT;
					next_edge_found = 0;
				end		
				else begin
					next_state = DEC;
				end
			end
		end
		SHIFT: begin
			computeSobel = 0;
			next_shift_en = 1;
			fill = 1;
			next_state = FILL3;

			out_buffer[2] = in_buffer[1];
			out_buffer[1] = in_buffer[0];
			if (incdec == 1) begin
				next_incdec = 0;
			end
			else begin
				next_incdec = 1;
			end
	
		end
	endcase
end

endmodule

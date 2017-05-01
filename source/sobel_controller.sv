// $Id: $
// File name:   sobel_controller.sv
// Created:     4/20/2017
// Author:      Imad Sheriff
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Controller to choose a 3x3 matrix for the Sobel Algorithm
module sobel_controller
(
	input wire clk,
	input wire n_rst,
	input wire [2:0] option,
	input wire [2:0][7:0][7:0] in_buffer,
	input wire computeSobel,
	output reg [2:0][2:0][7:0] sobel_matrix,
	output reg sobel_ready
);

typedef enum bit [3:0] {IDLE, COMP_1, COMP_2, COMP_3, COMP_4, COMP_5, COMP_6, COMP_7, COMP_8} stateType;
stateType state;
stateType next_state;
//reg next_sobel_ready;

// REGISTER LOGIC
always_ff @ (posedge clk, negedge n_rst) begin : REG_LOGIC	
	if(n_rst == 1'b0) begin
		state <= IDLE;
		//sobel_ready <= 0;
	end else begin
		state <= next_state;
		//sobel_ready <= next_sobel_ready;
	end
end

always_comb begin: NXT_LOGIC
	next_state = state;
	sobel_ready = 0;
	//next_sobel_ready = sobel_ready;
	sobel_matrix = '{'{0,0,0},
			'{0,0,0},
			'{0,0,0}};	
	case(state) 
		IDLE: begin
			//next_sobel_ready = 0;
			if (option == 0 && computeSobel == 1)
				next_state = COMP_1;
			else if (option == 1 && computeSobel == 1)
				next_state = COMP_2;
			else if (option == 2 && computeSobel == 1) 
				next_state = COMP_3;
			else if (option == 3 && computeSobel == 1) 
				next_state = COMP_4;
			else if (option == 4 && computeSobel == 1) 
				next_state = COMP_5;
			else if (option == 5 && computeSobel == 1) 
				next_state = COMP_6;
			else if (option == 6 && computeSobel == 1)
				next_state = COMP_7;
			else if (option == 7 && computeSobel == 1) 
				next_state = COMP_8;
		end
		COMP_1: begin
			sobel_matrix[2][2] = in_buffer[2][7];
			sobel_matrix[2][1] = in_buffer[2][6];
			sobel_matrix[2][0] = in_buffer[2][5];
			
			sobel_matrix[1][2] = in_buffer[1][7];
			sobel_matrix[1][1] = in_buffer[1][6];
			sobel_matrix[1][0] = in_buffer[1][5];
			
			sobel_matrix[0][2] = in_buffer[0][7];
			sobel_matrix[0][1] = in_buffer[0][6];
			sobel_matrix[0][0] = in_buffer[0][5];

			//sobel_matrix[1] = in_buffer[1][63:40];
			//sobel_matrix[0] = in_buffer[0][63:40];
			sobel_ready = 1;
			next_state = IDLE;
		end
		COMP_2: begin
			sobel_matrix[2][2] = in_buffer[2][6];
			sobel_matrix[2][1] = in_buffer[2][5];
			sobel_matrix[2][0] = in_buffer[2][4];
			
			sobel_matrix[1][2] = in_buffer[1][6];
			sobel_matrix[1][1] = in_buffer[1][5];
			sobel_matrix[1][0] = in_buffer[1][4];
			
			sobel_matrix[0][2] = in_buffer[0][6];
			sobel_matrix[0][1] = in_buffer[0][5];
			sobel_matrix[0][0] = in_buffer[0][4];

			//sobel_matrix[2] = in_buffer[2][55:32];
			//sobel_matrix[1] = in_buffer[1][55:32];
			//sobel_matrix[0] = in_buffer[0][55:32];
			//sobel_matrix = in_buffer[2:0][3:1];
			sobel_ready = 1;
			next_state = IDLE;
		end
		COMP_3: begin
			sobel_matrix[2][2] = in_buffer[2][5];
			sobel_matrix[2][1] = in_buffer[2][4];
			sobel_matrix[2][0] = in_buffer[2][3];
			
			sobel_matrix[1][2] = in_buffer[1][5];
			sobel_matrix[1][1] = in_buffer[1][4];
			sobel_matrix[1][0] = in_buffer[1][3];
			
			sobel_matrix[0][2] = in_buffer[0][5];
			sobel_matrix[0][1] = in_buffer[0][4];
			sobel_matrix[0][0] = in_buffer[0][3];

			//sobel_matrix[2] = in_buffer[2][47:24];
			///sobel_matrix[1] = in_buffer[1][47:24];
			//sobel_matrix[0] = in_buffer[0][47:24];
			//sobel_matrix = in_buffer[2:0][4:2];
			sobel_ready = 1;
			next_state = IDLE;
		end
		COMP_4: begin
			sobel_matrix[2][2] = in_buffer[2][4];
			sobel_matrix[2][1] = in_buffer[2][3];
			sobel_matrix[2][0] = in_buffer[2][2];
			
			sobel_matrix[1][2] = in_buffer[1][4];
			sobel_matrix[1][1] = in_buffer[1][3];
			sobel_matrix[1][0] = in_buffer[1][2];
			
			sobel_matrix[0][2] = in_buffer[0][4];
			sobel_matrix[0][1] = in_buffer[0][3];
			sobel_matrix[0][0] = in_buffer[0][2];

			//sobel_matrix[2] = in_buffer[2][39:16];	
			//sobel_matrix[1] = in_buffer[1][39:16];
			//sobel_matrix[0] = in_buffer[0][39:16];			
			//sobel_matrix = in_buffer[2:0][5:3];
			sobel_ready = 1;
			next_state = IDLE;
		end
		COMP_5: begin
			sobel_matrix[2][2] = in_buffer[2][3];
			sobel_matrix[2][1] = in_buffer[2][2];
			sobel_matrix[2][0] = in_buffer[2][1];
			
			sobel_matrix[1][2] = in_buffer[1][3];
			sobel_matrix[1][1] = in_buffer[1][2];
			sobel_matrix[1][0] = in_buffer[1][1];
			
			sobel_matrix[0][2] = in_buffer[0][3];
			sobel_matrix[0][1] = in_buffer[0][2];
			sobel_matrix[0][0] = in_buffer[0][1];

			//sobel_matrix[2] = in_buffer[2][31:8];
			//sobel_matrix[1] = in_buffer[1][31:8];
			//sobel_matrix[0] = in_buffer[0][31:8];
			//sobel_matrix = in_buffer[2:0][6:4];
			sobel_ready = 1;
			next_state = IDLE;
		end
		COMP_6: begin
			sobel_matrix[2][2] = in_buffer[2][2];
			sobel_matrix[2][1] = in_buffer[2][1];
			sobel_matrix[2][0] = in_buffer[2][0];
			
			sobel_matrix[1][2] = in_buffer[1][2];
			sobel_matrix[1][1] = in_buffer[1][1];
			sobel_matrix[1][0] = in_buffer[1][0];
			
			sobel_matrix[0][2] = in_buffer[0][2];
			sobel_matrix[0][1] = in_buffer[0][1];
			sobel_matrix[0][0] = in_buffer[0][0];

			//sobel_matrix[2] = in_buffer[2][23:0];
			//sobel_matrix[1] = in_buffer[1][23:0];
			///sobel_matrix[0] = in_buffer[0][23:0];
			//sobel_matrix = in_buffer[2:0][7:5];
			sobel_ready = 1;
			next_state = IDLE;
		end
		COMP_7: begin
			sobel_matrix[2][2] = in_buffer[2][1];
			sobel_matrix[2][1] = in_buffer[2][0];
			sobel_matrix[2][0] = in_buffer[2][7];
			
			sobel_matrix[1][2] = in_buffer[1][1];
			sobel_matrix[1][1] = in_buffer[1][0];
			sobel_matrix[1][0] = in_buffer[1][7];
			
			sobel_matrix[0][2] = in_buffer[0][1];
			sobel_matrix[0][1] = in_buffer[0][0];
			sobel_matrix[0][0] = in_buffer[0][7];

			//sobel_matrix[2] = {in_buffer[2][15:0], in_buffer[2][63:56]};
			//sobel_matrix[1] = {in_buffer[1][15:0], in_buffer[1][63:56]};
			//sobel_matrix[0] = {in_buffer[0][15:0], in_buffer[0][63:56]};
			sobel_ready = 1;
			next_state = IDLE;
		end
		COMP_8: begin
			sobel_matrix[2][2] = in_buffer[2][0];
			sobel_matrix[2][1] = in_buffer[2][7];
			sobel_matrix[2][0] = in_buffer[2][6];
			
			sobel_matrix[1][2] = in_buffer[1][0];
			sobel_matrix[1][1] = in_buffer[1][7];
			sobel_matrix[1][0] = in_buffer[1][6];
			
			sobel_matrix[0][2] = in_buffer[0][0];
			sobel_matrix[0][1] = in_buffer[0][7];
			sobel_matrix[0][0] = in_buffer[0][6];

			//sobel_matrix[2] = {in_buffer[2][7:0], in_buffer[2][63:48]};
			//sobel_matrix[1] = {in_buffer[1][7:0], in_buffer[1][63:48]};
			//sobel_matrix[0] = {in_buffer[0][7:0], in_buffer[0][63:48]};
			sobel_ready = 1;
			next_state = IDLE;
		end
	endcase
end

endmodule


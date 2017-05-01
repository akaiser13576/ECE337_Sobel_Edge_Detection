// $Id: $
// File name:   sobel.sv
// Created:     4/4/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Sobel Edge Algorithm Module
module sobel_edge
(
	// INPUTS
	input wire sobel_en,
	input wire [2:0][2:0][7:0] comp_matrix,
	// OUTPUTS
	output reg output_pixel,
	output wire sobel_done
);

	reg signed[15:0] f1_x, f2_x, f3_x, f4_x;
	reg signed [15:0] f1_y, f2_y, f3_y, f4_y;
	reg signed [15:0] g1_x, g2_x, g3_x;
 	reg unsigned [15:0] g_x;
	reg signed [15:0] g1_y, g2_y, g3_y;
	reg unsigned [15:0] g_y;
	reg signed [15:0] gradient;
	reg tmp_done;

	//reg signed [2:0][2:0][7:0] kernal_x = {{1, 0, -1},
					       //{2, 0, -2},
					       //{1, 0, -1}};

	//reg signed [2:0][2:0][7:0] kernal_y  = {{ 1,  2,  1},
					       // { 0,  0,  0},
					        //{-1, -2, -1}};
	always_comb begin	
		tmp_done = 1'b0;
		f1_x = (comp_matrix[2][0] ^ 16'b1111111111111111) + 1'b1; // Mult -1

		f2_x = {7'b0000000, comp_matrix[1][2], 1'b0};	// Mult 2

		f3_x = {7'b0000000, comp_matrix[1][0], 1'b0};	// Mult -2
		f3_x = (f3_x[15:0] ^ 16'b1111111111111111) + 1'b1;
	
		f4_x = (comp_matrix[0][0] ^ 16'b1111111111111111) + 1'b1; // Mult -1
		

		f1_y = {7'b0000000, comp_matrix[2][1], 1'b0};    // Mult 2

		f2_y = ({8'b00000000, comp_matrix[0][2]} ^ 16'b1111111111111111) + 1'b1; // Mult -1

		f3_y = {7'b0000000, comp_matrix[0][1], 1'b0};	// Mult -2
		f3_y = (f3_y[15:0] ^ 16'b1111111111111111) + 1'b1;

		f4_y = ({8'b00000000, comp_matrix[0][0]} ^ 16'b1111111111111111) + 1'b1; // Mult -1


		g1_x = f1_x + f2_x;
		g2_x = f3_x + f4_x;
		g3_x = comp_matrix[2][2] + comp_matrix[0][2];
		g_x = g1_x + g2_x + g3_x;				// X Gradient
		if (g_x[15] == 1'b1)
			g_x = (g_x[15:0] ^ 16'b1111111111111111) + 1'b1;
		else
			g_x = g_x[15:0];
		//$info("G_x: %0d", g_x);

		g1_y = f1_y + f2_y;
		g2_y = f3_y + f4_y;
		g3_y = comp_matrix[2][0] + comp_matrix[2][2];
		g_y = g1_y + g2_y + g3_y;				// Y Gradient	
		//$info("G_y: %0d", g_y);
		if (g_y[15] == 1'b1)
			g_y = (g_y[15:0] ^ 16'b1111111111111111) + 1'b1;
		else
			g_y = g_y[15:0];

		//gradient = g_x + g_y;	
		gradient = g_y + g_x;
		if (gradient[15] == 1'b1)
			gradient = (gradient[15:0] ^ 16'b1111111111111111) + 1'b1;
		else
			gradient = gradient[15:0];
		
	
		//$info("G: %0d", gradient);

		if(gradient > 16'd127) begin
			output_pixel = 1'b1;
			tmp_done = 1;
		end else begin
			output_pixel = 1'b0;
			tmp_done = 1;
		end
	end
	assign sobel_done = tmp_done;
endmodule

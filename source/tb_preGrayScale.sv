// $Id: $
// File name:   tb_preGrayScale.sv
// Created:     4/23/2017
// Author:      Imad Sheriff
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: 
`timescale 1ns / 100ps
module tb_preGrayScale
();
	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 20;
	
	// Shared Test Variables
	reg tb_clk;
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	
	integer tb_test_num;
	reg tb_n_rst;
	reg [31:0] tb_read_word;
	reg tb_start_en;
	reg tb_store_en;
	
	wire [3:0][23:0] tb_out_pixels;
	wire tb_gray_en;

	reg [3:0][23:0] tb_expected_out_pixels;
	reg tb_expected_gray_en;
	
	preGrayScale DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.read_word(tb_read_word),
		.start_en(tb_start_en),
		.store_en(tb_store_en),
		.out_pixels(tb_out_pixels),
		.gray_en(tb_gray_en)
	);

	// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst				= 1'b0;		
		tb_read_word = 32'd0;
		tb_start_en			= 0;  
		tb_store_en			= 0;
		tb_test_num 			= 0;
		// Power-on Reset of the DUT
		// Assume we start at negative edge. Immediately assert reset at first negative edge
		// without using clocking block in order to avoid metastable value warnings
		@(negedge tb_clk);
		tb_n_rst	<= 1'b0; 	// Need to actually toggle this in order for it to actually run dependent always blocks
                 

		//********* Test 1: Check for proper reset ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);

		tb_n_rst = 1;
		
		// Outputs:
		tb_expected_out_pixels = {24'd0, 24'd0, 24'd0, 24'd0};
		tb_expected_gray_en = 0;

		@(posedge tb_clk);
		#1

		// Check that the output is true
		if (tb_expected_out_pixels == tb_out_pixels)
		   $info("Case %0d:: PASSED Correct out_pixels value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect out_pixels value,  YOUR VALUE: %0d", tb_test_num, tb_expected_out_pixels);

		if (tb_expected_gray_en == tb_gray_en)
		   $info("Case %0d:: PASSED Correct gray_en value", tb_test_num);
		else // Test case failed 
		   $error("Case %0d:: FAILED - incorrect gray_en value,  YOUR VALUES: %0d", tb_test_num, tb_gray_en);

		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 2: 1st 32 bit word ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_read_word = 32'b11111111000000001010101011110000; //R: 11111111   G: 00000000  B: 10101010  R: 11110000
		tb_start_en = 1;
		@(posedge tb_clk);
		tb_start_en = 0;
		@(posedge tb_clk);
		tb_store_en = 1;
		@(posedge tb_clk);
		tb_store_en = 0;

		// Outputs:
		tb_expected_out_pixels = {24'b111111110000000010101010, 24'd0, 24'd0, 24'd0};
		tb_expected_gray_en = 0;

		@(posedge tb_clk);
		#1

		// Check that the output is true
		if (tb_expected_out_pixels == tb_out_pixels)
		   $info("Case %0d:: PASSED Correct out_pixels value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect out_pixels value,  YOUR VALUE: %0d", tb_test_num, tb_expected_out_pixels);

		if (tb_expected_gray_en == tb_gray_en)
		   $info("Case %0d:: PASSED Correct gray_en value", tb_test_num);
		else // Test case failed 
		   $error("Case %0d:: FAILED - incorrect gray_en value,  YOUR VALUES: %0d", tb_test_num, tb_gray_en);

		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 3: 2nd 32 bit word ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_read_word = 32'b00010011000000001010101010000111; //G: 00010011   B: 00000000  R: 10101010  G: 10000111
		tb_store_en = 1;
		@(posedge tb_clk);
		tb_store_en = 0;

		// Outputs:
		tb_expected_out_pixels = {24'b111111110000000010101010, 24'b111100000001001100000000, 24'd0, 24'd0};
		tb_expected_gray_en = 0;

		@(posedge tb_clk);
		#1

		// Check that the output is true
		if (tb_expected_out_pixels == tb_out_pixels)
		   $info("Case %0d:: PASSED Correct out_pixels value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect out_pixels value,  YOUR VALUE: %0d", tb_test_num, tb_expected_out_pixels);

		if (tb_expected_gray_en == tb_gray_en)
		   $info("Case %0d:: PASSED Correct gray_en value", tb_test_num);
		else // Test case failed 
		   $error("Case %0d:: FAILED - incorrect gray_en value,  YOUR VALUES: %0d", tb_test_num, tb_gray_en);

		@(posedge tb_clk);
		//@(posedge tb_clk);

		//********* Test 4: 3rd 32 bit word ***********
		tb_test_num = tb_test_num + 1;
		@(posedge tb_clk);
		
		// Inputs:
		tb_read_word = 32'b00010011000000001010101010000111; //B: 00010011   R: 00000000  G: 10101010  B: 10000111
		tb_store_en = 1;
		@(negedge tb_clk);
		tb_expected_gray_en = 1;
		
		if (tb_expected_gray_en == tb_gray_en)
		   $info("Case %0d:: PASSED Correct gray_en value", tb_test_num);
		else // Test case failed 
		   $error("Case %0d:: FAILED - incorrect gray_en value,  YOUR VALUES: %0d", tb_test_num, tb_gray_en);

		@(posedge tb_clk);
		tb_store_en = 0;

		// Outputs:
		tb_expected_out_pixels = {24'b111111110000000010101010, 24'b111100000001001100000000, 24'b101010101000011100010011, 24'b1010101010000111};
		//tb_expected_gray_en = 1;

		@(posedge tb_clk);
		#1

		// Check that the output is true
		if (tb_expected_out_pixels == tb_out_pixels)
		   $info("Case %0d:: PASSED Correct out_pixels value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect out_pixels value,  YOUR VALUE: %0d", tb_test_num, tb_expected_out_pixels);


		@(posedge tb_clk);
		@(posedge tb_clk);


	end
endmodule

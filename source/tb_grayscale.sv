// $Id: $
// File name:   tb_grayscale.sv
// Created:     4/11/2017
// Author:      Imad Sheriff
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Test bench for grayscale 

`timescale 1ns / 100ps
module tb_grayscale
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
	reg [3:0][23:0] tb_in_pixel_buffer; 
        reg tb_gray_en;

	wire tb_gray_done;
	wire [3:0][7:0] tb_gray_pixel;

	reg tb_expected_gray_done;
	reg [3:0][7:0] tb_expected_gray_pixel;

	grayscale DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.in_pixel_buffer(tb_in_pixel_buffer),
		.gray_en(tb_gray_en),
		.gray_pixel(tb_gray_pixel),
		.gray_done(tb_gray_done)
	);


	// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst				= 1'b0;		// Initialize to be inactive
		tb_gray_en				= 1'b0;		// Initialize to be idle
		tb_in_pixel_buffer			= '{24'd0,24'd0,24'd0, 24'd0};  // Initialize pre gray scale buffer to be 0
		tb_expected_gray_done			= 1'b0;
		tb_expected_gray_pixel 			= 32'd0;
		tb_test_num 				= 0;

		
		// Power-on Reset of the DUT
		// Assume we start at negative edge. Immediately assert reset at first negative edge
		// without using clocking block in order to avoid metastable value warnings
		@(negedge tb_clk);
		tb_n_rst	<= 1'b0; 	// Need to actually toggle this in order for it to actually run dependent always blocks
                 

		//********* Test 1: Check for proper reset ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);

		// Inputs
		tb_n_rst = 1'b1;
	   

		// Outputs
		tb_expected_gray_done = 0;
		tb_expected_gray_pixel = 32'd0;


                @(posedge tb_clk);
		#1
		// Check that the output is true
		if (tb_expected_gray_done == tb_gray_done)
		   $info("Case %0d:: PASSED Correct gray_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect gray_done value,  YOUR VALUE: %0d", tb_test_num, tb_gray_done);

		if (tb_expected_gray_pixel == tb_gray_pixel)
		   $info("Case %0d:: PASSED Correct gray_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect gray_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_gray_pixel);


		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 2: Check for correct gray scaled values, last pixel checks for overflow ***********
		tb_test_num = tb_test_num + 1;


		// Inputs
		tb_in_pixel_buffer ='{24'b000000011100000100001001,24'b000000011100000100001011,24'b000000011100000100001011,24'b111111111111111111111111};
		//			  | RED  ||Green |  | BLUE |     | RED  ||Green || BLUE |     | RED  ||Green || BLUE |     | RED  ||Green || BLUE |
		@(negedge tb_clk);
		tb_gray_en = 1;
		@(negedge tb_clk);
		//#10
	   

		

		// --------------------------------------- First pixel -----------------------------------------------------------
		// Outputs
		tb_expected_gray_done = 0;
		//tb_expected_gray_pixel = 8'd144;

                @(posedge tb_clk);
		#1
		// Check that the output is true
		/*if (tb_expected_gray_done == tb_gray_done)
		   $info("Case %0d First Pixel:: PASSED Correct gray_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d First Pixel:: FAILED - incorrect gray_done value,  YOUR VALUE: %0d", tb_test_num, tb_gray_done);

		if (tb_expected_gray_pixel == tb_gray_pixel)
		   $info("Case %0d First Pixel:: PASSED Correct gray_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d First Pixel:: FAILED - incorrect gray_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_gray_pixel);
		*/
		
		// --------------------------------------- Second pixel -----------------------------------------------------------
		// Outputs
		tb_expected_gray_done = 0;
		//tb_expected_gray_pixel = 8'd144;;

		@(negedge tb_clk);
		#1
		/* Check that the output is true
		if (tb_expected_gray_done == tb_gray_done)
		   $info("Case %0d Second Pixel:: PASSED Correct gray_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d Second Pixel:: FAILED - incorrect gray_done value,  YOUR VALUE: %0d", tb_test_num, tb_gray_done);

		if (tb_expected_gray_pixel == tb_gray_pixel)
		   $info("Case %0d Second Pixel:: PASSED Correct gray_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d Second Pixel:: FAILED - incorrect gray_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_gray_pixel);
		*/

		// --------------------------------------- Third pixel -----------------------------------------------------------
		// Outputs
		tb_expected_gray_done = 0;
		//tb_expected_gray_pixel = 8'd144;

		@(negedge tb_clk);
		#1
		/* Check that the output is true
		if (tb_expected_gray_done == tb_gray_done)
		   $info("Case %0d Third Pixel:: PASSED Correct gray_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d Third Pixel:: FAILED - incorrect gray_done value,  YOUR VALUE: %0d", tb_test_num, tb_gray_done);

		if (tb_expected_gray_pixel == tb_gray_pixel)
		   $info("Case %0d Third Pixel:: PASSED Correct gray_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d Third Pixel:: FAILED - incorrect gray_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_gray_pixel);
		*/

		// --------------------------------------- Fourth pixel -----------------------------------------------------------
		// Outputs
		tb_expected_gray_done = 0;
		

		@(negedge tb_clk);
		#1;
		// Check that the output is true
		/*if (tb_expected_gray_done == tb_gray_done)
		   $info("Case %0d Fourth Pixel:: PASSED Correct gray_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d Fourth Pixel:: FAILED - incorrect gray_done value,  YOUR VALUE: %0d", tb_test_num, tb_gray_done);

		if (tb_expected_gray_pixel == tb_gray_pixel)
		   $info("Case %0d Fourth Pixel:: PASSED Correct gray_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d Fourth Pixel:: FAILED - incorrect gray_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_gray_pixel);
		*/

		@(posedge tb_clk);
		@(posedge tb_clk);
		
		//********* Test 3: Check for correct gray done value ***********
		tb_test_num = tb_test_num + 1;
		tb_expected_gray_done = 1;
		tb_expected_gray_pixel = {8'd144, 8'd144, 8'd144, 8'd255};

		// Check that the output is true
		if (tb_expected_gray_done == tb_gray_done)
		   $info("Case %0d Fourth Pixel:: PASSED Correct gray_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d Fourth Pixel:: FAILED - incorrect gray_done value,  YOUR VALUE: %0d", tb_test_num, tb_gray_done);

		if (tb_expected_gray_pixel == tb_gray_pixel)
		   $info("Case %0d Fourth Pixel:: PASSED Correct gray_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d Fourth Pixel:: FAILED - incorrect gray_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_gray_pixel);

		if (tb_expected_gray_done == tb_gray_done)
		   $info("Case %0d:: PASSED Correct gray_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect gray_done value,  YOUR VALUE: %0d", tb_test_num, tb_gray_done);
	end
endmodule

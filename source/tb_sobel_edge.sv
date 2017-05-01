// $Id: $
// File name:   tb_sobel_edge.sv
// Created:     4/4/2017
// Author:      Imad Sheriff
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Test Bench For Sobel Edge Algorithm

`timescale 1ns / 100ps
module tb_sobel_edge
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
	reg tb_sobel_en;
	reg [2:0][2:0][7:0] tb_comp_matrix; 
        wire tb_output_pixel;
	wire tb_sobel_done;
	reg tb_expected_output_pixel;
	reg tb_expected_sobel_done;

	sobel_edge DUT
	(
		.sobel_en(tb_sobel_en),
		.comp_matrix(tb_comp_matrix),
		.output_pixel(tb_output_pixel),
		.sobel_done(tb_sobel_done)
	);


	// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_sobel_en				= 1'b0;		// Initialize to be idle
		tb_comp_matrix				= '{'{0,0,0},
							   '{0,0,0},
							   '{0,0,0}};
		tb_expected_output_pixel		= 1'b0;
		tb_expected_sobel_done 			= 1'b0;
		tb_test_num 				= 0;

		
		// Power-on Reset of the DUT
		// Assume we start at negative edge. Immediately assert reset at first negative edge
		// without using clocking block in order to avoid metastable value warnings
		@(negedge tb_clk);

                 


		//********* Test 1: Check for Sobel Calculation ***********
		tb_test_num = tb_test_num + 1;

		// Inputs
		tb_comp_matrix = '{'{1,1,1},
				  '{1,1,1},
				  '{1,1,1}};
		tb_sobel_en = 1'b0;
	        @(posedge tb_clk);
		tb_sobel_en = 1'b1;

		// Outputs
		tb_expected_sobel_done = 1;
		tb_expected_output_pixel = 0;


                @(posedge tb_clk);
		#1

		// Check that the output is true
		if (tb_expected_sobel_done == tb_sobel_done)
		   $info("Case %0d:: PASSED Correct sobel_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_done value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_done);

		if (tb_expected_output_pixel == tb_output_pixel)
		   $info("Case %0d:: PASSED Correct output_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect output_pixel value,  YOUR VALUE: %0d\n\n", tb_test_num, tb_output_pixel);

		@(posedge tb_clk);
		@(posedge tb_clk);


		//********* Test 2: Check for Sobel Calculation ***********
		tb_test_num = tb_test_num + 1;

		// Inputs
		tb_comp_matrix = '{'{255,255,255},
				  '{255,255,255},
				  '{255,255,255}};
		tb_sobel_en = 1'b0;
	        @(posedge tb_clk);
		tb_sobel_en = 1'b1;

		// Outputs
		tb_expected_sobel_done = 1;
		tb_expected_output_pixel = 0;


                @(posedge tb_clk);
		#1

		// Check that the output is true
		if (tb_expected_sobel_done == tb_sobel_done)
		   $info("Case %0d:: PASSED Correct sobel_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_done value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_done);

		if (tb_expected_output_pixel == tb_output_pixel)
		   $info("Case %0d:: PASSED Correct output_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect output_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_output_pixel);

		@(posedge tb_clk);
		@(posedge tb_clk);


		//********* Test 3: Check for Sobel Calculation - EDGE ***********
		tb_test_num = tb_test_num + 1;

		// Inputs
		tb_comp_matrix = '{'{0,156,200},
				  '{0,111,234},
				  '{0,123,178}};
		tb_sobel_en = 1'b0;
	        @(posedge tb_clk);
		tb_sobel_en = 1'b1;

		// Outputs
		tb_expected_sobel_done = 1;
		tb_expected_output_pixel = 1;


                @(posedge tb_clk);
		#1

		// Check that the output is true
		if (tb_expected_sobel_done == tb_sobel_done)
		   $info("Case %0d:: PASSED Correct sobel_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_done value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_done);

		if (tb_expected_output_pixel == tb_output_pixel)
		   $info("Case %0d:: PASSED Correct output_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect output_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_output_pixel);

		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 3: Check for Sobel Calculation - NOT AN EDGE***********
		tb_test_num = tb_test_num + 1;

		// Inputs
		tb_comp_matrix = '{'{10,10,10},
				  '{10,10,10},
				  '{10,10,10}};
		tb_sobel_en = 1'b0;
	        @(posedge tb_clk);
		tb_sobel_en = 1'b1;

		// Outputs
		tb_expected_sobel_done = 1;
		tb_expected_output_pixel = 0;


                @(posedge tb_clk);
		#1

		// Check that the output is true
		if (tb_expected_sobel_done == tb_sobel_done)
		   $info("Case %0d:: PASSED Correct sobel_done value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_done value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_done);

		if (tb_expected_output_pixel == tb_output_pixel)
		   $info("Case %0d:: PASSED Correct output_pixel value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect output_pixel value,  YOUR VALUE: %0d", tb_test_num, tb_output_pixel);

		@(posedge tb_clk);
		@(posedge tb_clk);

	end
endmodule

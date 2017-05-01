// $Id: $
// File name:   tb_sobel_controller.sv
// Created:     4/20/2017
// Author:      Imad Sheriff
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Test Bench for the Matrix input to the Sobel Algorithm
`timescale 1ns / 100ps
module tb_sobel_controller
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
	reg [2:0][7:0][7:0] tb_in_buffer; 
        reg [2:0] tb_option;
	reg tb_computeSobel;

	wire [2:0][2:0][7:0] tb_sobel_matrix;
	wire tb_sobel_ready;

	reg [2:0][2:0][7:0] tb_expected_sobel_matrix;
	reg tb_expected_sobel_ready;

	sobel_controller DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.option(tb_option),
		.in_buffer(tb_in_buffer),
		.computeSobel(tb_computeSobel),
		.sobel_matrix(tb_sobel_matrix),
		.sobel_ready(tb_sobel_ready)
	);
	
	// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst				= 1'b0;		
		tb_in_buffer				= '{'{0,0,0,0,0,0,0,0},
							  '{0,0,0,0,0,0,0,0},
						          '{0,0,0,0,0,0,0,0}};
		tb_option			= 0;  
		tb_computeSobel			= 0;
		tb_test_num 			= 0;

		
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
		tb_expected_sobel_matrix = '{'{8'd0,8'd0,8'd0},
					     '{8'd0,8'd0,8'd0},
					     '{8'd0,8'd0,8'd0}};
		tb_expected_sobel_ready = 1'd0;


                @(posedge tb_clk);
		#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);

		@(posedge tb_clk);
		@(posedge tb_clk);
		
		//********* Test 2: Check for option 0 ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_in_buffer =              {{8'd100, 8'd100, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd100, 8'd100, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd100, 8'd100, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0}};
		tb_option = 0;
		@(posedge tb_clk);
		tb_computeSobel = 1;
		@(posedge tb_clk);
		tb_computeSobel = 0;
		@(negedge tb_clk);
		

		// Outputs:
		tb_expected_sobel_matrix = {{8'd100, 8'd100, 8'd100},
				   {8'd100, 8'd100, 8'd100},
				   {8'd100, 8'd100, 8'd100}};
		tb_expected_sobel_ready = 1;
		
		//#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);
		
		tb_expected_sobel_ready = 0;
		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 3: Check for option 1 ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_in_buffer =              {{8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0}};
		tb_option = 1;
		@(posedge tb_clk);
		tb_computeSobel = 1;
		@(posedge tb_clk);
		tb_computeSobel = 0;
		@(negedge tb_clk);
		

		// Outputs:
		tb_expected_sobel_matrix = {{8'd55, 8'd50, 8'd100},
				   {8'd55, 8'd50, 8'd100},
				   {8'd55, 8'd50, 8'd100}};
		tb_expected_sobel_ready = 1;
		
		//#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);

		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 4: Check for option 2 ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_in_buffer =              {{8'd0, 8'd55, 8'd50, 8'd100, 8'd10, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd10, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd010, 8'd0, 8'd0, 8'd0}};
		tb_option = 2;
		@(posedge tb_clk);
		tb_computeSobel = 1;
		@(posedge tb_clk);
		tb_computeSobel = 0;
		@(negedge tb_clk);
		

		// Outputs:
		tb_expected_sobel_matrix = {{8'd50, 8'd100, 8'd10},
				   {8'd50, 8'd100, 8'd10},
				   {8'd50, 8'd100, 8'd10}};
		tb_expected_sobel_ready = 1;
		
		//#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);

		@(posedge tb_clk);
		@(posedge tb_clk);
		
		//********* Test 5: Check for option 3 ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_in_buffer =              {{8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0}};
		tb_option = 3;
		@(posedge tb_clk);
		tb_computeSobel = 1;
		@(posedge tb_clk);
		tb_computeSobel = 0;
		@(negedge tb_clk);
		

		// Outputs:
		tb_expected_sobel_matrix = {{8'd100, 8'd0, 8'd0},
				   {8'd100, 8'd0, 8'd0},
				   {8'd100, 8'd0, 8'd0}};
		tb_expected_sobel_ready = 1;
		
		//#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);

		@(posedge tb_clk);
		@(posedge tb_clk);


		//********* Test 6: Check for option 4 ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_in_buffer =              {{8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd20, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd20, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd20, 8'd0, 8'd0}};
		tb_option = 4;
		@(posedge tb_clk);
		tb_computeSobel = 1;
		@(posedge tb_clk);
		tb_computeSobel = 0;
		@(negedge tb_clk);
		

		// Outputs:
		tb_expected_sobel_matrix = {{8'd0, 8'd20, 8'd0},
				   {8'd0, 8'd20, 8'd0},
				   {8'd0, 8'd20, 8'd0}};
		tb_expected_sobel_ready = 1;
		
		//#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);

		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 7: Check for option 5 ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_in_buffer =              {{8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd20, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd20, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd20, 8'd0, 8'd0}};
		tb_option = 5;
		@(posedge tb_clk);
		tb_computeSobel = 1;
		@(posedge tb_clk);
		tb_computeSobel = 0;
		@(negedge tb_clk);
		

		// Outputs:
		tb_expected_sobel_matrix = {{8'd20, 8'd0, 8'd0},
				   {8'd20, 8'd0, 8'd0},
				   {8'd20, 8'd0, 8'd0}};
		tb_expected_sobel_ready = 1;
		
		//#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);

		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 8: Check for option 6 ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_in_buffer =              {{8'd5, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd5, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd5, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0}};
		tb_option = 6;
		@(posedge tb_clk);
		tb_computeSobel = 1;
		@(posedge tb_clk);
		tb_computeSobel = 0;
		@(negedge tb_clk);
		

		// Outputs:
		tb_expected_sobel_matrix = {{8'd0, 8'd0, 8'd5},
				   {8'd0, 8'd0, 8'd5},
				   {8'd0, 8'd0, 8'd5}};
		tb_expected_sobel_ready = 1;
		
		//#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);

		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 9: Check for option 7 ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		
		// Inputs:
		tb_in_buffer =              {{8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd55, 8'd50, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0}};
		tb_option = 7;
		@(posedge tb_clk);
		tb_computeSobel = 1;
		@(posedge tb_clk);
		tb_computeSobel = 0;
		@(negedge tb_clk);
		

		// Outputs:
		tb_expected_sobel_matrix = {{8'd0, 8'd0, 8'd55},
				   {8'd0, 8'd0, 8'd55},
				   {8'd0, 8'd0, 8'd55}};
		tb_expected_sobel_ready = 1;
		
		//#1
		// Check that the output is true
		if (tb_expected_sobel_matrix == tb_sobel_matrix)
		   $info("Case %0d:: PASSED Correct sobel_matrix value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_matrix values,  YOUR VALUE: %0d", tb_test_num, tb_sobel_matrix);

		if (tb_expected_sobel_ready == tb_sobel_ready)
		   $info("Case %0d:: PASSED Correct sobel_ready value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobel_ready value,  YOUR VALUE: %0d", tb_test_num, tb_sobel_ready);

		@(posedge tb_clk);
		@(posedge tb_clk);

	end
endmodule

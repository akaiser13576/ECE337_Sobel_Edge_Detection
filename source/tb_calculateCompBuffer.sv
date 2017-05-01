// $Id: $
// File name:   tb_calculateCompBuffer.sv
// Created:     4/21/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Test bench for calculateCompBuff.
`timescale 1ns / 100ps
module tb_calculateCompBuffer
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
	reg tb_grayed_done;
	reg [3:0][7:0] tb_grayed_pixels; 
        reg tb_edge_detected;
	//reg [2:0][7:0][7:0] tb_in_buffer;
	reg tb_getMatrix;	

	wire tb_computeSobel;
	wire [2:0][7:0][7:0] tb_out_buffer;
	//wire tb_fill_1st;
	//wire tb_fill_2nd;
	//wire tb_fill_edges;
	wire [2:0] tb_next_counter;

	reg tb_expected_computeSobel;
	reg [2:0][7:0][7:0]tb_expected_out_buffer;
	//reg tb_expected_fill_1st;	
	//reg tb_expected_fill_2nd;
	//reg tb_expected_fill_edges;
	reg [2:0] tb_expected_next_counter;

	calculateCompBuffer DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.grayed_done(tb_grayed_done),
		.grayed_pixels(tb_grayed_pixels),
		.edge_detected(tb_edge_detected),
		.getMatrix(tb_getMatrix),
		//.in_buffer(tb_in_buffer),
		.computeSobel(tb_computeSobel),
		.out_buffer(tb_out_buffer),
		//.fill_1st(tb_fill_1st),
		//.fill_2nd(tb_fill_2nd),
		//.fill_edges(tb_fill_edges),
		.next_counter(tb_next_counter)
	);

	// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst				= 1'b0;		// Initialize to be inactive
		tb_test_num 				= 0;
		tb_grayed_done 				= 0;
		tb_grayed_pixels 			= {8'd255, 8'd255, 8'd255, 8'd255};
		tb_edge_detected 				= 0;
		tb_getMatrix				= 0;
		//tb_in_buffer				= {{8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
		//					   {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
		//					   {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0}};
		
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
		tb_expected_computeSobel = 0;
		tb_expected_out_buffer  =  {{8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0}};


                @(posedge tb_clk);
		#1
				if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER values,  YOUR VALUES: %0d", tb_test_num, tb_out_buffer);


		@(posedge tb_clk);
		@(posedge tb_clk);

		//********* Test 2: Check for proper filling ***********
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);

		//-----------  FILL 1 ------------
		tb_grayed_pixels = {8'd255, 8'd255, 8'd255, 8'd255};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd255, 8'd255, 8'd255, 8'd255, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0,     8'd0,   8'd0,   8'd0, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0,     8'd0,   8'd0,   8'd0, 8'd0, 8'd0, 8'd0, 8'd0}};
		
		@(posedge tb_clk);
		#1

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 1 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 1 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);
		

		//-----------  FILL 2 ------------
		tb_grayed_pixels = {8'd200, 8'd200, 8'd200, 8'd200};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd255, 8'd255, 8'd255, 8'd255, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd200, 8'd200, 8'd200, 8'd200, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd0,     8'd0,   8'd0,   8'd0, 8'd0, 8'd0, 8'd0, 8'd0}};

		@(posedge tb_clk);
		#1
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 2 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 2 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);
		
	
		//-----------  FILL 3 ------------
		tb_grayed_pixels = {8'd100, 8'd100, 8'd100, 8'd100};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd255, 8'd255, 8'd255, 8'd255, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd200, 8'd200, 8'd200, 8'd200, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd100,     8'd100,   8'd100,   8'd100, 8'd0, 8'd0, 8'd0, 8'd0}};

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 3 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 3 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);

	
		//-----------  INCREMENT  ------------
		tb_expected_computeSobel = 1;
		tb_expected_out_buffer  =  {{8'd255, 8'd255, 8'd255, 8'd255, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd200, 8'd200, 8'd200, 8'd200, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd100,     8'd100,   8'd100,   8'd0, 8'd0, 8'd0, 8'd0, 8'd0}};
		@(negedge tb_clk);

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_computeSobel == tb_computeSobel)
		   $info("Case %0d:: PASSED Correct COMPUTE SOBEL Value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect COMPUTE SOBEL Value,  YOUR VALUES: %0d", tb_test_num, tb_computeSobel);
		@(posedge tb_clk);
		
		//-----------  FILL 4 ------------
		tb_expected_computeSobel = 0;
		tb_grayed_pixels = {8'd111, 8'd111, 8'd111, 8'd111};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd255, 8'd255, 8'd255, 8'd255, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd200, 8'd200, 8'd200, 8'd200, 8'd0, 8'd0, 8'd0, 8'd0},
					    {8'd100, 8'd100, 8'd100, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0}};
		
		@(posedge tb_clk);
		#1

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 4 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 4 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);


		//-----------  FILL 5 ------------
		tb_grayed_pixels = {8'd222, 8'd222, 8'd222, 8'd222};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd255, 8'd255, 8'd255, 8'd255, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd200, 8'd200, 8'd200, 8'd200, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd100, 8'd100, 8'd100, 8'd100, 8'd0, 8'd0, 8'd0, 8'd0}};

		@(posedge tb_clk);
		#1
	
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 5 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 5 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);
		
			
		//-----------  FILL 6 ------------
		tb_grayed_pixels = {8'd101, 8'd101, 8'd101, 8'd101};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd255, 8'd255, 8'd255, 8'd255, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd200, 8'd200, 8'd200, 8'd200, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd100, 8'd100, 8'd100, 8'd100, 8'd101, 8'd101, 8'd101, 8'd101}};

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 6 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 6 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);


		//-----------  INCREMENT ------------
		@(posedge tb_clk);
		tb_getMatrix = 1'b1;
		@(posedge tb_clk);
		tb_getMatrix = 1'b0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		tb_getMatrix = 1'b1;
		@(posedge tb_clk);
		tb_getMatrix = 1'b0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		tb_getMatrix = 1'b1;
		@(posedge tb_clk);
		tb_getMatrix = 1'b0;
		@(posedge tb_clk);
		@(posedge tb_clk);
		tb_expected_computeSobel = 1;
		tb_expected_out_buffer  =  {{8'd255, 8'd255, 8'd255, 8'd255, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd200, 8'd200, 8'd200, 8'd200, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd100, 8'd100, 8'd100, 8'd100, 8'd101, 8'd101, 8'd101, 8'd101}};

		@(negedge tb_clk);
		
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_computeSobel == tb_computeSobel)
		   $info("Case %0d:: PASSED Correct sobelDone Value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobelDone Value,  YOUR VALUES: %0d", tb_test_num, tb_computeSobel);
		@(posedge tb_clk);
		
		//-----------  FILL 1 ------------
		tb_expected_computeSobel = 0;
		tb_grayed_pixels = {8'd123, 8'd123, 8'd123, 8'd123};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd123, 8'd123, 8'd123, 8'd123, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd200, 8'd200, 8'd200, 8'd200, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd100, 8'd100, 8'd100, 8'd100, 8'd101, 8'd101, 8'd101, 8'd101}};
		
		@(posedge tb_clk);
	
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 1 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - ROW 1 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);


		//-----------  FILL 2 ------------
		tb_grayed_pixels = {8'd131, 8'd131, 8'd131, 8'd131};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  ={{8'd123, 8'd123, 8'd123, 8'd123, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd131, 8'd131, 8'd131, 8'd131, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd100, 8'd100, 8'd100, 8'd100, 8'd101, 8'd101, 8'd101, 8'd101}};

		@(posedge tb_clk);
		#1
	
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 2 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 2 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);
		

	
		//-----------  FILL 3 ------------
		tb_grayed_pixels = {8'd211, 8'd211, 8'd211, 8'd211};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  ={{8'd123, 8'd123, 8'd123, 8'd123, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd131, 8'd131, 8'd131, 8'd131, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd101, 8'd101, 8'd101, 8'd101}};

		@(posedge tb_clk);
		#1

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - ROW 1 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - ROW 1 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);

		
		//-----------  INCREMENT ------------
		@(posedge tb_clk);
		@(posedge tb_clk);
		tb_expected_out_buffer  ={{8'd123, 8'd123, 8'd123, 8'd123, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd131, 8'd131, 8'd131, 8'd131, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd101, 8'd101, 8'd101, 8'd101}};
		tb_expected_computeSobel = 1;

		@(negedge tb_clk);
	
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_computeSobel == tb_computeSobel)
		   $info("Case %0d:: PASSED Correct sobelDone Value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobelDone Value,  YOUR VALUES: %0d", tb_test_num, tb_computeSobel);
		@(posedge tb_clk);
		tb_expected_computeSobel = 0;
	
		//-----------  FILL 4 ------------
		tb_expected_computeSobel = 0;
		tb_grayed_pixels = {8'd124, 8'd124, 8'd124, 8'd124};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  ={{8'd123, 8'd123, 8'd123, 8'd123, 8'd124, 8'd124, 8'd124, 8'd124},
					    {8'd131, 8'd131, 8'd131, 8'd131, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd101, 8'd101, 8'd101, 8'd101}};
		
		@(posedge tb_clk);
		#1

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 4 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 4 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);


		//-----------  FILL 5 ------------
		tb_grayed_pixels = {8'd155, 8'd155, 8'd155, 8'd155};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd123, 8'd123, 8'd123, 8'd123, 8'd124, 8'd124, 8'd124, 8'd124},
					    {8'd131, 8'd131, 8'd131, 8'd131, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd101, 8'd101, 8'd101, 8'd101}};
		@(posedge tb_clk);
		#1
	
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 5 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 5 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);
		
			
		//-----------  FILL 6 ------------
		tb_grayed_pixels = {8'd122, 8'd122, 8'd122, 8'd122};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		tb_edge_detected = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd123, 8'd123, 8'd123, 8'd123, 8'd124, 8'd124, 8'd124, 8'd124},
					    {8'd131, 8'd131, 8'd131, 8'd131, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd122, 8'd122, 8'd122, 8'd122}};

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 6 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 6 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);
		
		//------------ SHIFT --------------
		@(posedge tb_clk);
		tb_expected_out_buffer  =  {{8'd131, 8'd131, 8'd131, 8'd131, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd122, 8'd122, 8'd122, 8'd122}};

		@(posedge tb_clk);
		#1
		@(posedge tb_clk);
		#1
		@(posedge tb_clk);
		@(negedge tb_clk);
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - SHIFT Values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - SHIFT values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);

		
		//-----------  FILL 3 ------------
		tb_grayed_pixels = {8'd202, 8'd202, 8'd202, 8'd202};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd131, 8'd131, 8'd131, 8'd131, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd202, 8'd202, 8'd202, 8'd202, 8'd122, 8'd122, 8'd122, 8'd122}};

		@(posedge tb_clk);
		#1

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 3 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 3 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);

		//-----------  FILL 6 ------------
		tb_grayed_pixels = {8'd34, 8'd34, 8'd34, 8'd34};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd131, 8'd131, 8'd131, 8'd131, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd202, 8'd202, 8'd202, 8'd202, 8'd34, 8'd34, 8'd34, 8'd34}};

		tb_expected_next_counter = 3'd5;
		
		
		if(tb_expected_next_counter == tb_next_counter)	
		   $info("Case %0d:: PASSED Correct NEXT COUNTER - FILL 6 value", tb_test_num);
		else	
		   $error("Case %0d:: FAILED - incorrect NEXT COUNT - FILL 6 value,  YOUR VALUE: %0d", tb_test_num, tb_next_counter);	

		@(negedge tb_clk);
		#1

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 6 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 6 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);

		
		//----------- DECREMENT ----------;
		tb_expected_out_buffer  =  {{8'd131, 8'd131, 8'd131, 8'd131, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd202, 8'd202, 8'd202, 8'd202, 8'd34, 8'd34, 8'd34, 8'd34}};
		tb_expected_computeSobel = 1;

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_computeSobel == tb_computeSobel)
		   $info("Case %0d:: PASSED Correct sobelDone Value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobelDone Value,  YOUR VALUES: %0d", tb_test_num, tb_computeSobel);
		@(posedge tb_clk);
		tb_expected_computeSobel = 0;
	

		
		//-----------  FILL 1 ------------
		tb_expected_computeSobel = 0;
		tb_grayed_pixels = {8'd44, 8'd44, 8'd44, 8'd44};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd44, 8'd44, 8'd44, 8'd44, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd202, 8'd202, 8'd202, 8'd202, 8'd34, 8'd34, 8'd34, 8'd34}};
		
		@(posedge tb_clk);
	
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 1 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - ROW 1 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);


		//-----------  FILL 2 ------------
		tb_grayed_pixels = {8'd22, 8'd22, 8'd22, 8'd22};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd44, 8'd44, 8'd44, 8'd44, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd22, 8'd22, 8'd22, 8'd22, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd202, 8'd202, 8'd202, 8'd202, 8'd34, 8'd34, 8'd34, 8'd34}};

		@(posedge tb_clk);
		#1
	
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 2 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 2 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);
		

		
		//-----------  FILL 3 ------------
		tb_grayed_pixels = {8'd2, 8'd2, 8'd2, 8'd2};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		tb_edge_detected = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd44, 8'd44, 8'd44, 8'd44, 8'd155, 8'd155, 8'd155, 8'd155},
					    {8'd22, 8'd22, 8'd22, 8'd22, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd2, 8'd2, 8'd2, 8'd2, 8'd34, 8'd34, 8'd34, 8'd34}};
		@(posedge tb_clk);
		#1

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 3 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 3 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);

		//------------ SHIFT --------------
		@(posedge tb_clk);
		tb_expected_out_buffer  =  {{8'd22, 8'd22, 8'd22, 8'd22, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd2, 8'd2, 8'd2, 8'd2, 8'd34, 8'd34, 8'd34, 8'd34},
					    {8'd2, 8'd2, 8'd2, 8'd2, 8'd34, 8'd34, 8'd34, 8'd34}};

		@(posedge tb_clk);
		#1
		@(posedge tb_clk);
		#1
		@(posedge tb_clk);
		@(negedge tb_clk);
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - SHIFT Values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - SHIFT values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);


		//-----------  FILL 3 ------------
		tb_grayed_pixels = {8'd145, 8'd145, 8'd145, 8'd145};
		@(posedge tb_clk);
		tb_grayed_done = 1;
		@(posedge tb_clk);
		tb_grayed_done = 0;
		tb_expected_out_buffer  =  {{8'd22, 8'd22, 8'd22, 8'd22, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd2, 8'd2, 8'd2, 8'd2, 8'd34, 8'd34, 8'd34, 8'd34},
					    {8'd145, 8'd145, 8'd145, 8'd145, 8'd34, 8'd34, 8'd34, 8'd34}};

		@(posedge tb_clk);
		#1

		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 3 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 3 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4]);

		//-----------  FILL 6 ------------
		tb_grayed_pixels = {8'd21, 8'd21, 8'd21, 8'd21};
		@(posedge tb_clk);
		
		tb_expected_computeSobel = 1'b1;
		@(negedge tb_clk);
	
		tb_expected_out_buffer  =  {{8'd22, 8'd22, 8'd22, 8'd22, 8'd122, 8'd122, 8'd122, 8'd122},
					    {8'd2, 8'd2, 8'd2, 8'd2, 8'd34, 8'd34, 8'd34, 8'd34},
					    {8'd145, 8'd145, 8'd145, 8'd145, 8'd21, 8'd21, 8'd21, 8'd21}};
		tb_grayed_done = 1;
		tb_expected_next_counter = 3'd0;
		
		
		if(tb_expected_next_counter == tb_next_counter)	
		   $info("Case %0d:: PASSED Correct NEXT COUNTER - FILL 6 value", tb_test_num);
		else	
		   $error("Case %0d:: FAILED - incorrect NEXT COUNT - FILL 6 value,  YOUR VALUE: %0d", tb_test_num, tb_next_counter);	
	
		@(negedge tb_clk);
		#1
		tb_grayed_done = 0;
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_out_buffer == tb_out_buffer)
		   $info("Case %0d:: PASSED Correct OUT BUFFER - FILL 6 values", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect OUT BUFFER - FILL 6 values,  YOUR VALUES: %0d, %0d, %0d, %0d", tb_test_num, tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0]);

		if (tb_expected_computeSobel == tb_computeSobel)
		   $info("Case %0d:: PASSED Correct COMPUTE SOBEL Value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect COMPUTE SOBEL Value,  YOUR VALUES: %0d", tb_test_num, tb_computeSobel);
		tb_expected_computeSobel = 1'b0;

	
		//-----------  INCREMENT ------------
		tb_expected_out_buffer  ={{8'd123, 8'd123, 8'd123, 8'd123, 8'd111, 8'd111, 8'd111, 8'd111},
					    {8'd131, 8'd131, 8'd131, 8'd131, 8'd222, 8'd222, 8'd222, 8'd222},
					    {8'd211, 8'd211, 8'd211, 8'd211, 8'd101, 8'd101, 8'd101, 8'd101}};
		tb_expected_computeSobel = 1;
	
		$info("%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d,\n  %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d\n", tb_out_buffer[2][7], tb_out_buffer[2][6], tb_out_buffer[2][5], tb_out_buffer[2][4], tb_out_buffer[2][3], tb_out_buffer[2][2], tb_out_buffer[2][1], tb_out_buffer[2][0], tb_out_buffer[1][7], tb_out_buffer[1][6], tb_out_buffer[1][5], tb_out_buffer[1][4], tb_out_buffer[1][3], tb_out_buffer[1][2], tb_out_buffer[1][1], tb_out_buffer[1][0], tb_out_buffer[0][7], tb_out_buffer[0][6], tb_out_buffer[0][5], tb_out_buffer[0][4], tb_out_buffer[0][3], tb_out_buffer[0][2], tb_out_buffer[0][1], tb_out_buffer[0][0]);
		// Check that the output is true
		if (tb_expected_computeSobel == tb_computeSobel)
		   $info("Case %0d:: PASSED Correct sobelDone Value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect sobelDone Value,  YOUR VALUES: %0d", tb_test_num, tb_computeSobel);
		@(posedge tb_clk);
		tb_expected_computeSobel = 0;
		
		
	end

		




endmodule

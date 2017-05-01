// $Id: $
// File name:   tb_window_slider.sv
// Created:     4/23/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Test bench for window slider.
`timescale 1ns / 100ps
module tb_window_slider
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
		
	// INPUTS
	reg tb_n_rst;
	reg tb_nx_pixel_en;
	reg [31:0] tb_image_start_addr;
        
	// OUTPUTS
	wire tb_next_edge_detected;
	wire [31:0] tb_next_calc_address;
	wire tb_addr_done;
	wire tb_next_last_pix_read;	

	// EXPECTED
	reg tb_expected_next_edge_detected;
	reg [31:0] tb_expected_next_calc_address;
	reg tb_expected_addr_done;

	window_slider DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.nx_pixel_en(tb_nx_pixel_en),
		.image_start_addr(tb_image_start_addr),
		.next_edge_detected(tb_next_edge_detected),
		.addr_done(tb_addr_done),
		.next_calc_address(tb_next_calc_address),
		.next_last_pix_read(tb_next_last_pix_read)
	);

	// Default Configuration Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst				= 1'b0;		// Initialize to be inactive
		tb_test_num 				= 0;
		tb_nx_pixel_en 				= 0;
		tb_image_start_addr 			= 32'h0;
		
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
	   	tb_nx_pixel_en = 0;

		// Outputs
		tb_expected_addr_done = 0; 


                @(posedge tb_clk);
		#1
		if (tb_expected_addr_done == tb_addr_done)
		   $info("Case %0d:: PASSED Correct ADDR DONE value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect ADDR DONE value,  YOUR VALUES: %0d", tb_test_num, tb_addr_done);

	
		//********* Test 2: Check for proper calculation of first row - addr 1***********
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;

		tb_expected_next_calc_address = 32'd0 + tb_image_start_addr;
		@(posedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 1 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);

		//********* Test 3: Check for proper calculation of first row - addr 2 ***********
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;
		tb_expected_next_calc_address = 32'd1 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 1 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);

		//********* Test 4: Check for proper calculation of first row - addr 3 ***********
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;
		tb_expected_next_calc_address = 32'd2 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 1 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);	

		//********* Test 5: Check for proper calculation of second row - addr 1 ***********
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;
		tb_expected_next_calc_address = 32'd480 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 2 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);

		//********* Test 6: Check for proper calculation of second row - addr 2 ***********
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;
		tb_expected_next_calc_address = 32'd481 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 2 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);	

		//********* Test 7: Check for proper calculation of second row - addr 3 ***********
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;
		tb_expected_next_calc_address = 32'd482 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 2 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);	

		//********* Test 8: Check for proper calculation of third row - addr 1 ***********
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;
		tb_expected_next_calc_address = 32'd960 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 3 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);

		//********* Test 9: Check for proper calculation of third row - addr 2 ***********
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;
		tb_expected_next_calc_address = 32'd961 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 3 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);	

		//********* Test 10: Check for proper calculation of third row - addr 3 ***********
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_nx_pixel_en = 1;
		tb_expected_next_calc_address = 32'd962 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 3 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);

		//********* Test 10: Check for proper calculation of first - addr 1 ***********
		tb_nx_pixel_en = 0;
		@(posedge tb_clk);
		tb_test_num = tb_test_num + 1;
		@(negedge tb_clk);
		@(posedge tb_clk);
		tb_nx_pixel_en = 1;
		@(posedge tb_clk);
		tb_expected_next_calc_address = 32'd3 + tb_image_start_addr;
		@(negedge tb_clk);

		// Check for proper values
		if (tb_expected_next_calc_address == tb_next_calc_address)
		   $info("Case %0d:: PASSED Correct CALC ADDR 1 value", tb_test_num);
		else // Test case failed
		   $error("Case %0d:: FAILED - incorrect CALC ADDR 3 value,  YOUR VALUES: %0d", tb_test_num, tb_next_calc_address);
	end

	
endmodule

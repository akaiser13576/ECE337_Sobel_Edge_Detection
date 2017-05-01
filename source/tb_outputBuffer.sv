// $Id: $
// File name:   tb_outputBuffer.sv
// Created:     4/18/2017
// Author:      Pradyumna Modukuru
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Test bench for output buffer
`timescale 1ns / 10ps
module tb_outputBuffer();
	localparam CLK_PERIOD	= 2.5;
	//input declarations
	reg tb_clk, tb_n_rst, tb_edge_pixel, tb_out_en, tb_write_out_en, tb_img_done;
	
	//module test data inputs
	reg [31:0] tb_endpixel;

	//module test data outputs
	reg [31:0] tb_out_pixel, tb_write_addr;
	reg tb_out_empty, tb_out_full;

	//expected output declarations
	reg [31:0] exp_out_pixel, exp_write_addr;
	reg exp_out_empty, exp_out_full;

	//clock generation
	always begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//portmap
	outputBuffer OutBuff(.clk(tb_clk),
				.n_rst(tb_n_rst),
				.edge_pixel(tb_edge_pixel),
				.out_en(tb_out_en),
				.write_out_enable(tb_write_out_en),
				.endpixel(tb_endpixel),
				.out_pixel(tb_out_pixel),
				.write_addr(tb_write_addr),
				.out_empty(tb_out_empty),
				.out_full(tb_out_full),
				.img_done(tb_img_done) );

	int i = 0;
	integer index;
	int testarray[32];
	integer testcase;
	initial begin
		//initializations

		//inputs
		tb_n_rst = 1;
		tb_edge_pixel = 0;
		tb_out_en = 0;
		tb_write_out_en = 0;
		tb_endpixel = 0;
		tb_img_done = 0;
		
		//outputs
		tb_write_addr = 0;
		tb_out_pixel = 32'b11111111111111111111111111111111;
		tb_out_empty = 0;
		tb_out_full = 0;

		//expected
		exp_write_addr = 0;
		exp_out_pixel = 0;
		exp_out_empty = 0;
		exp_out_full = 0;

		//test case 1: test reset
		//i = i + 1;
		i = -1;
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		tb_n_rst = 1'b0;
		exp_write_addr = 0;
		exp_out_pixel = 0;
		exp_out_empty = 0;
		exp_out_full = 0;

		#CLK_PERIOD

		//test write_addr
		if (exp_write_addr == tb_write_addr) begin
			$info("Test case %d write_addr passed",i);
		end
		else begin
			$error("Test case %d write_addr failed",i);
		end
		//test out_pixel
		if (exp_out_pixel == tb_out_pixel) begin
			$info("Test case %d out_pixel passed",i);
		end
		else begin
			$error("Test case %d out_pixel failed",i);
		end
		//test out_empty
		if (exp_out_empty == tb_out_empty) begin
			$info("Test case %d out_empty passed",i);
		end
		else begin
			$error("Test case %d out_empty failed",i);
		end
		//test out_full
		if (exp_out_full == tb_out_full) begin
			$info("Test case %d out_full passed",i);
		end
		else begin
			$error("Test case %d out_full failed",i);
		end


		//test case 2: test 32 shifts into buffer
		$info("Test Case %d\n", i);
		i = i + 1;
		#CLK_PERIOD

		//inputs
		tb_n_rst = 1;
		tb_edge_pixel = 0;
		tb_out_en = 0;
		tb_write_out_en = 0;
		tb_endpixel = 0;

		//test array
		for (index = 0; index < 32; index = index + 1)
		begin
			testarray[index] = 1;
		end
		

		tb_n_rst = 1'b1;
		exp_write_addr = 0;
		exp_out_pixel = 32'd0;
		//exp_out_pixel = 32'b11111111111111111111111111111111;
		exp_out_empty = 0;
		exp_out_full = 1;
		
		#CLK_PERIOD

		for (index = 0; index < 32; index = index + 1)
		begin
			tb_edge_pixel = testarray[index];
			tb_out_en = 1;
			#CLK_PERIOD;
			tb_out_en = 0;
			#CLK_PERIOD;
		end

		tb_write_out_en = 1;

		#CLK_PERIOD

		tb_write_out_en = 0;

		//test write_addr
		if (exp_write_addr == tb_write_addr) begin
			$info("Test case %d write_addr passed",i);
		end
		else begin
			$error("Test case %d write_addr failed",i);
		end
		//test out_pixel
		if (exp_out_pixel == tb_out_pixel) begin
			$info("Test case %d out_pixel passed",i);
		end
		else begin
			$error("Test case %d out_pixel failed",i);
		end
		//test out_empty
		if (exp_out_empty == tb_out_empty) begin
			$info("Test case %d out_empty passed",i);
		end
		else begin
			$error("Test case %d out_empty failed",i);
		end
		//test out_full
		if (exp_out_full == tb_out_full) begin
			$info("Test case %d out_full passed",i);
		end
		else begin
			$error("Test case %d out_full failed",i);
		end

		





		//test case 3- check for 20th column shift
		for (testcase = 0; testcase < 18; testcase = testcase + 1)
		begin
		$info("Test case %d ran", i);
		i = i + 1;
		#CLK_PERIOD

		//inputs
		tb_n_rst = 1;
		tb_edge_pixel = 0;
		tb_out_en = 0;
		tb_write_out_en = 0;
		tb_endpixel = 0;

		//test array
		for (index = 0; index < 32; index = index + 1)
		begin
			testarray[index] = testcase % 2;
		end
		

		tb_n_rst = 1'b1;
		exp_write_addr = 0;
		exp_out_pixel = 32'd0;
		//exp_out_pixel = 32'b11111111111111111111111111111111;
		exp_out_empty = 0;
		exp_out_full = 1;
		
		#CLK_PERIOD

		for (index = 0; index < 32; index = index + 1)
		begin
			tb_edge_pixel = testarray[index];
			tb_out_en = 1;
			#CLK_PERIOD;
			tb_out_en = 0;
			#CLK_PERIOD;
		end

		tb_write_out_en = 1;

		//wait 1 clock cycle before output
		#CLK_PERIOD
		

		tb_write_out_en = 0;

		end
		#CLK_PERIOD


		


		//Test case 20
		i = i + 1;
		//inputs
		tb_n_rst = 1;
		tb_edge_pixel = 0;
		tb_out_en = 0;
		tb_write_out_en = 0;
		tb_endpixel = 0;

		tb_img_done = 1;

		//test array
		for (index = 0; index < 32; index = index + 1)
		begin
			testarray[index] = 1;
		end
		

		tb_n_rst = 1'b1;
		exp_write_addr = 0;
		exp_out_pixel = 32'd0;
		//exp_out_pixel = 32'b11111111111111111111111111111111;
		exp_out_empty = 0;
		exp_out_full = 1;
		
		#CLK_PERIOD

		for (index = 0; index < 32; index = index + 1)
		begin
			tb_edge_pixel = testarray[index];
			tb_out_en = 1;
			#CLK_PERIOD;
			tb_out_en = 0;
			#CLK_PERIOD;
		end

		tb_write_out_en = 1;

		#CLK_PERIOD

		//test write_addr
		if (exp_write_addr == tb_write_addr) begin
			$info("Test case %d write_addr passed",i);
		end
		else begin
			$error("Test case %d write_addr failed",i);
		end
		//test out_pixel
		if (exp_out_pixel == tb_out_pixel) begin
			$info("Test case %d out_pixel passed",i);
		end
		else begin
			$error("Test case %d out_pixel failed",i);
		end
		//test out_empty
		if (exp_out_empty == tb_out_empty) begin
			$info("Test case %d out_empty passed",i);
		end
		else begin
			$error("Test case %d out_empty failed",i);
		end
		//test out_full
		if (exp_out_full == tb_out_full) begin
			$info("Test case %d out_full passed",i);
		end
		else begin
			$error("Test case %d out_full failed",i);
		end

		//img_done test case
		i = i + 1;
		//inputs
		tb_n_rst = 1;
		tb_edge_pixel = 0;
		tb_out_en = 0;
		tb_write_out_en = 0;
		tb_endpixel = 0;

		//test array
		for (index = 0; index < 32; index = index + 1)
		begin
			testarray[index] = 1;
		end
		

		tb_n_rst = 1'b1;
		exp_write_addr = 0;
		exp_out_pixel = 32'd0;
		//exp_out_pixel = 32'b11111111111111111111111111111111;
		exp_out_empty = 0;
		exp_out_full = 1;
		
		#CLK_PERIOD

		for (index = 0; index < 32; index = index + 1)
		begin
			tb_edge_pixel = testarray[index];
			tb_out_en = 1;
			#CLK_PERIOD;
			tb_out_en = 0;
			#CLK_PERIOD;
		end

		tb_write_out_en = 1;

		#CLK_PERIOD

		//test write_addr
		if (exp_write_addr == tb_write_addr) begin
			$info("Test case %d write_addr passed",i);
		end
		else begin
			$error("Test case %d write_addr failed",i);
		end
		//test out_pixel
		if (exp_out_pixel == tb_out_pixel) begin
			$info("Test case %d out_pixel passed",i);
		end
		else begin
			$error("Test case %d out_pixel failed",i);
		end
		//test out_empty
		if (exp_out_empty == tb_out_empty) begin
			$info("Test case %d out_empty passed",i);
		end
		else begin
			$error("Test case %d out_empty failed",i);
		end
		//test out_full
		if (exp_out_full == tb_out_full) begin
			$info("Test case %d out_full passed",i);
		end
		else begin
			$error("Test case %d out_full failed",i);
		end
							
			

	end

endmodule

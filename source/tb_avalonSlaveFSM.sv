// $Id: $
// File name:   tb_avalonSlaveFSM.sv
// Created:     4/11/2017
// Author:      Pradyumna Modukuru
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Testbench for Avalon Slave module
`timescale 1ns / 10ps
module tb_avalonSlaveFSM();
	localparam CLK_PERIOD	= 2.5;
	//input declarations
	reg tb_clk, tb_n_rst, tb_read, tb_write;
	
	//module test data inputs
	reg [31:0] tb_address, tb_writedata;

	//module test data outputs
	reg [31:0] tb_readdata, tb_startpixel, tb_endpixel;
	reg tb_status, tb_control;

	//expected output declarations
	reg exp_status, exp_control;
	reg [31:0] exp_readdata, exp_startpixel, exp_endpixel;

	//clock generation
	always begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//portmap
	avalonSlaveFSM SLAVE(.clk(tb_clk),
				.n_rst(tb_n_rst),
				.write(tb_write),
				.read(tb_read),
				.address(tb_address),
				.writedata(tb_writedata),
				.readdata(tb_readdata),
				.startpixel(tb_startpixel),
				.endpixel(tb_endpixel),
				.control(tb_control),
				.status(tb_status)	);

	int i = 0;
	initial begin
		//initializations

		//inputs
		tb_n_rst = 0;
		tb_read = 0;
		tb_write = 0;
		tb_address = 0;
		tb_writedata = 0;
		
		//outputs
		tb_readdata = 0;
		tb_startpixel = 0;
		tb_endpixel = 0;
		tb_status = 0;
		tb_control = 0;

		//expected
		exp_readdata = 0;
		exp_startpixel = 0;
		exp_endpixel = 0;
		exp_status = 0;
		exp_control = 0;

		//test case 1: test reset
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		i = i + 1;
		tb_n_rst = 1'b0;
		exp_readdata = 0;
		exp_startpixel = 0;
		exp_endpixel = 0;
		exp_status = 0;
		exp_control = 0;

		#CLK_PERIOD
		#CLK_PERIOD
		//test readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end
		//test startpixel
		if (exp_startpixel == tb_startpixel) begin
			$info("Test case %d startpixel passed",i);
		end
		else begin
			$error("Test case %d startpixel failed",i);
		end
		//test endpixel
		if (exp_endpixel == tb_endpixel) begin
			$info("Test case %d endpixel passed",i);
		end
		else begin
			$error("Test case %d endpixel failed",i);
		end
		//test status
		if (exp_status == tb_status) begin
			$info("Test case %d status passed",i);
		end
		else begin
			$error("Test case %d status failed",i);
		end
		//test control
		if (exp_control == tb_control) begin
			$info("Test case %d control passed",i);
		end
		else begin
			$error("Test case %d control failed",i);
		end

		//test case 2: test write to startpixel
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		//inputs
		tb_n_rst = 1;
		tb_read = 0;
		tb_write = 1;
		tb_address = 32'd1;
		tb_writedata = 32'd4444;

		i = i + 1;
		exp_readdata = 0;
		exp_startpixel = 32'd4444;
		exp_endpixel = 0;
		exp_status = 0;
		exp_control = 0;

		#CLK_PERIOD
		#CLK_PERIOD
		//test readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end
		//test startpixel
		if (exp_startpixel == tb_startpixel) begin
			$info("Test case %d startpixel passed",i);
		end
		else begin
			$error("Test case %d startpixel failed",i);
		end
		//test endpixel
		if (exp_endpixel == tb_endpixel) begin
			$info("Test case %d endpixel passed",i);
		end
		else begin
			$error("Test case %d endpixel failed",i);
		end
		//test status
		if (exp_status == tb_status) begin
			$info("Test case %d status passed",i);
		end
		else begin
			$error("Test case %d status failed",i);
		end
		//test control
		if (exp_control == tb_control) begin
			$info("Test case %d control passed",i);
		end
		else begin
			$error("Test case %d control failed",i);
		end

		//test case 3: test write to endpixel
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		//inputs
		tb_n_rst = 1;
		tb_read = 0;
		tb_write = 1;
		tb_address = 32'd2;
		tb_writedata = 32'd6666;

		i = i + 1;
		exp_readdata = 0;
		exp_startpixel = 32'd4444;
		exp_endpixel = 32'd6666;
		exp_status = 0;
		exp_control = 0;

		#CLK_PERIOD
		#CLK_PERIOD
		//test readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end
		//test startpixel
		if (exp_startpixel == tb_startpixel) begin
			$info("Test case %d startpixel passed",i);
		end
		else begin
			$error("Test case %d startpixel failed",i);
		end
		//test endpixel
		if (exp_endpixel == tb_endpixel) begin
			$info("Test case %d endpixel passed",i);
		end
		else begin
			$error("Test case %d endpixel failed",i);
		end
		//test status
		if (exp_status == tb_status) begin
			$info("Test case %d status passed",i);
		end
		else begin
			$error("Test case %d status failed",i);
		end
		//test control
		if (exp_control == tb_control) begin
			$info("Test case %d control passed",i);
		end
		else begin
			$error("Test case %d control failed",i);
		end

	//test case 4: test write to control
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		//inputs
		tb_n_rst = 1;
		tb_read = 0;
		tb_write = 1;
		tb_address = 32'd4;
		tb_writedata = 32'd1;

		i = i + 1;
		exp_readdata = 0;
		exp_startpixel = 32'd4444;
		exp_endpixel = 32'd6666;
		exp_status = 0;
		exp_control = 1;

		#CLK_PERIOD
		#CLK_PERIOD
		//test readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end
		//test startpixel
		if (exp_startpixel == tb_startpixel) begin
			$info("Test case %d startpixel passed",i);
		end
		else begin
			$error("Test case %d startpixel failed",i);
		end
		//test endpixel
		if (exp_endpixel == tb_endpixel) begin
			$info("Test case %d endpixel passed",i);
		end
		else begin
			$error("Test case %d endpixel failed",i);
		end
		//test status
		if (exp_status == tb_status) begin
			$info("Test case %d status passed",i);
		end
		else begin
			$error("Test case %d status failed",i);
		end
		//test control
		if (exp_control == tb_control) begin
			$info("Test case %d control passed",i);
		end
		else begin
			$error("Test case %d control failed",i);
		end
		
	//test case 5: test write to control
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		//inputs
		tb_n_rst = 1;
		tb_read = 0;
		tb_write = 1;
		tb_address = 32'd4;
		tb_writedata = 32'd1;

		i = i + 1;
		exp_readdata = 0;
		exp_startpixel = 32'd4444;
		exp_endpixel = 32'd6666;
		exp_status = 0;
		exp_control = 1;

		#CLK_PERIOD
		#CLK_PERIOD
		//test readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end
		//test startpixel
		if (exp_startpixel == tb_startpixel) begin
			$info("Test case %d startpixel passed",i);
		end
		else begin
			$error("Test case %d startpixel failed",i);
		end
		//test endpixel
		if (exp_endpixel == tb_endpixel) begin
			$info("Test case %d endpixel passed",i);
		end
		else begin
			$error("Test case %d endpixel failed",i);
		end
		//test status
		if (exp_status == tb_status) begin
			$info("Test case %d status passed",i);
		end
		else begin
			$error("Test case %d status failed",i);
		end
		//test control
		if (exp_control == tb_control) begin
			$info("Test case %d control passed",i);
		end
		else begin
			$error("Test case %d control failed",i);
		end

	//test case 6: test read from status
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		//inputs
		tb_n_rst = 1;
		tb_read = 1;
		tb_write = 0;
		tb_address = 32'd3;
		tb_writedata = 0;

		i = i + 1;
		exp_readdata = 1;
		exp_startpixel = 32'd4444;
		exp_endpixel = 32'd6666;
		exp_status = 1;
		exp_control = 1;

		#CLK_PERIOD
		#CLK_PERIOD
		//test readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end
		//test startpixel
		if (exp_startpixel == tb_startpixel) begin
			$info("Test case %d startpixel passed",i);
		end
		else begin
			$error("Test case %d startpixel failed",i);
		end
		//test endpixel
		if (exp_endpixel == tb_endpixel) begin
			$info("Test case %d endpixel passed",i);
		end
		else begin
			$error("Test case %d endpixel failed",i);
		end
		//test status
		if (exp_status == tb_status) begin
			$info("Test case %d status passed",i);
		end
		else begin
			$error("Test case %d status failed",i);
		end
		//test control
		if (exp_control == tb_control) begin
			$info("Test case %d control passed",i);
		end
		else begin
			$error("Test case %d control failed",i);
		end
		
	end



endmodule

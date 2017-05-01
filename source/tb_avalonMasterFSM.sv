// $Id: $
// File name:   tb_avalonMasterFSM.sv
// Created:     4/13/2017
// Author:      Nivedita Nighojkar
// Lab Section: 337-006
// Version:     1.0  Initial Design Entry
// Description: master test bench for avalon

`timescale 1ns / 10ps
module tb_avalonMasterFSM();
	localparam CLK_PERIOD	= 2.5;
	//input declarations
	reg tb_clk, tb_n_rst; 
	reg [31:0] tb_readdata;
	
	//module test data inputs
	reg tb_readen, tb_writen;
	reg [31:0] tb_wdata, tb_inaddr;

	//module test data outputs
	reg tb_read, tb_write, tb_dataready;
	reg [31:0] tb_address, tb_writedata;

	//expected output declarations
	reg exp_read, exp_write, exp_dataready;
	reg [31:0] exp_address, exp_writedata;

	//clock generation
	always begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//portmap
	avalonMasterFSM MASTER(   .clk(tb_clk),
				.n_rst(tb_n_rst),
				.write(tb_write),
				.read(tb_read),
				.address(tb_address),
				.writedata(tb_writedata),
				.readdata(tb_readdata),
				.readen(tb_readen),
				.writen(tb_writen),
				.wdata(tb_wdata),
				.inaddr(tb_inaddr),	
				.dataready(tb_dataready) );

	int i = 0;
	initial begin
		//initializations

		//inputs
		tb_n_rst = 0;
		tb_readen = 0;
		tb_writen = 0;
		tb_readdata = 0;
		tb_wdata = 0;
		tb_inaddr = 0;
		
		//outputs
		tb_read = 0;
		tb_write = 0;
		tb_dataready = 0;
		tb_address = 0;
		tb_writedata = 0;

		//expected
		exp_read = 0;
		exp_write = 0;
		exp_dataready = 0;
		exp_address = 0;
		exp_writedata = 0;

		//test case 1: test reset
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		i = i + 1;
		tb_n_rst = 1'b0;
		exp_read = 0;
		exp_write = 0;
		exp_dataready = 0;
		exp_address = 0;
		exp_writedata = 0;

		#CLK_PERIOD
		#CLK_PERIOD
		//test read
		if (exp_read == tb_read) begin
			$info("Test case %d read passed",i);
		end
		else begin
			$error("Test case %d read failed",i);
		end
		//test write
		if (exp_write == tb_write) begin
			$info("Test case %d write passed",i);
		end
		else begin
			$error("Test case %d write failed",i);
		end
		//test dataready
		if (exp_dataready == tb_dataready) begin
			$info("Test case %d dataready passed",i);
		end
		else begin
			$error("Test case %d dataready failed",i);
		end
		//test address
		if (exp_address == tb_address) begin
			$info("Test case %d address passed",i);
		end
		else begin
			$error("Test case %d address failed",i);
		end
		//test writedata
		if (exp_writedata == tb_writedata) begin
			$info("Test case %d writedata passed",i);
		end
		else begin
			$error("Test case %d writedata failed",i);
		end

		//test case 2: test read
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		i = i + 1;
		
		//inputs
		tb_n_rst = 1'b1;
		tb_readen = 1;
		tb_writen = 0;
		tb_readdata = 0;
		tb_wdata = 0;
		tb_inaddr = 0;
		
		//expected outputs
		exp_read = 1;
		exp_write = 0;
		exp_dataready = 0;
		exp_address = 0;
		exp_writedata = 0;

		#CLK_PERIOD
		#CLK_PERIOD
		//test read
		if (exp_read == tb_read) begin
			$info("Test case %d read passed",i);
		end
		else begin
			$error("Test case %d read failed",i);
		end
		//test write
		if (exp_write == tb_write) begin
			$info("Test case %d write passed",i);
		end
		else begin
			$error("Test case %d write failed",i);
		end
		//test dataready
		if (exp_dataready == tb_dataready) begin
			$info("Test case %d dataready passed",i);
		end
		else begin
			$error("Test case %d dataready failed",i);
		end
		//test address
		if (exp_address == tb_address) begin
			$info("Test case %d address passed",i);
		end
		else begin
			$error("Test case %d address failed",i);
		end
		//test writedata
		if (exp_writedata == tb_writedata) begin
			$info("Test case %d writedata passed",i);
		end
		else begin
			$error("Test case %d writedata failed",i);
		end

		//test case 3: test read
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		i = i + 1;
		
		//inputs
		tb_n_rst = 1'b1;
		tb_readen = 1;
		tb_writen = 0;
		tb_readdata = 32'd5656;
		tb_wdata = 0;
		tb_inaddr = 0;
		
		//expected outputs
		exp_read = 1;
		exp_write = 0;
		exp_dataready = 1;
		exp_address = 0;
		exp_writedata = 0;

		#CLK_PERIOD
		#CLK_PERIOD
		//test read
		if (exp_read == tb_read) begin
			$info("Test case %d read passed",i);
		end
		else begin
			$error("Test case %d read failed",i);
		end
		//test write
		if (exp_write == tb_write) begin
			$info("Test case %d write passed",i);
		end
		else begin
			$error("Test case %d write failed",i);
		end
		//test dataready
		if (exp_dataready == tb_dataready) begin
			$info("Test case %d dataready passed",i);
		end
		else begin
			$error("Test case %d dataready failed",i);
		end
		//test address
		if (exp_address == tb_address) begin
			$info("Test case %d address passed",i);
		end
		else begin
			$error("Test case %d address failed",i);
		end
		//test writedata
		if (exp_writedata == tb_writedata) begin
			$info("Test case %d writedata passed",i);
		end
		else begin
			$error("Test case %d writedata failed",i);
		end

		//test case 4: test write
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		i = i + 1;
		
		//inputs
		tb_n_rst = 1'b1;
		tb_readen = 0;
		tb_writen = 1;
		tb_readdata = 32'd5656;
		tb_wdata = 32'd4444;
		tb_inaddr = 32'd6767;
		
		//expected outputs
		exp_read = 0;
		exp_write = 1;
		exp_dataready = 0;
		exp_address = 32'd6767;
		exp_writedata = 32'd4444;

		#CLK_PERIOD
		#CLK_PERIOD
		//test read
		if (exp_read == tb_read) begin
			$info("Test case %d read passed",i);
		end
		else begin
			$error("Test case %d read failed",i);
		end
		//test write
		if (exp_write == tb_write) begin
			$info("Test case %d write passed",i);
		end
		else begin
			$error("Test case %d write failed",i);
		end
		//test dataready
		if (exp_dataready == tb_dataready) begin
			$info("Test case %d dataready passed",i);
		end
		else begin
			$error("Test case %d dataready failed",i);
		end
		//test address
		if (exp_address == tb_address) begin
			$info("Test case %d address passed",i);
		end
		else begin
			$error("Test case %d address failed",i);
		end
		//test writedata
		if (exp_writedata == tb_writedata) begin
			$info("Test case %d writedata passed",i);
		end
		else begin
			$error("Test case %d writedata failed",i);
		end




	end

endmodule

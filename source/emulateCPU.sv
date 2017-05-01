initial
begin

//step 1: PREP SRAM and INPUT/OUTPUT Arrays

//step 2: Emulate CPU on Avalon Bus


localparam CLK_PERIOD	= 2.5;
	
	//clock generation
	always begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end


//registers
	reg [31:0] tb_slave_writedata;
	reg [31:0] tb_slave_addr;
	reg [31:0] tb_slave_readdata;
	reg slave_read, slave_write;
	


//write to startpixel
	tb_slave_writedata = //startpixel array address (addr of input image) ;
	tb_slave_addr = 1;
	tb_slave_write = 1;

	#CLK_PERIOD
	#CLK_PERIOD

	tb_slave_write = 0;

	#CLK_PERIOD

//write to endpixel
	tb_slave_writedata = //endpixel array address (addr of output image) ;
	tb_slave_addr = 2;
	tb_slave_write = 1;

	#CLK_PERIOD
	#CLK_PERIOD

	tb_slave_write = 0;

	#CLK_PERIOD

//write to status (initialization)
	tb_slave_writedata = 0;
	tb_slave_addr = 4;
	tb_slave_write = 1;

	#CLK_PERIOD
	#CLK_PERIOD

	tb_slave_write = 0;

	#CLK_PERIOD 

//write to control
	tb_slave_writedata = 1;
	tb_slave_addr = 3;
	tb_slave_write = 1;

	#CLK_PERIOD
	#CLK_PERIOD

	tb_slave_write = 0;

	#CLK_PERIOD


//step 3: wait for sobel to complete 
	while (status == 0) begin
		#CLK_PERIOD;
	end

//postprocessing



end

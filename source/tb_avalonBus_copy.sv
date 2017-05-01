// $Id: $
// File name:   tb_avalonBus.sv
// Created:     4/26/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Overall test bench for Avalon Bus operations.
module tb_avalonBus();

	parameter INPUT_FILENAME 	= "./docs/test4.bmp";
	parameter RESULT_FILENAME	= "~/ece337/ECE_337_Project/ECE-337-Project/docs/sobel_1.bmp";
	
	// Define file io offset constants
	localparam SEEK_START	= 0;
	localparam SEEK_CUR	= 1;
	localparam SEEK_END	= 2;
	
	// Bitmap file based parameters
	localparam BMP_HEADER_SIZE_BYTES = 14;	// The length of the BMP file header field in Bytes
	localparam PIXEL_ARR_PTR_ADDR	 = BMP_HEADER_SIZE_BYTES - 4;
	localparam DIB_HEADER_C1_SIZE	 = 40; // The length of the expected BITMAPINFOHEADER DIB header
	localparam DIB_HEADER_C2_SIZE	 = 12; // The length of the expected BITMAPCOREHEADER DIB header

	// Define local constants
	localparam NUM_VAL_BITS	= 8;
	localparam MAX_VAL_BIT	= NUM_VAL_BITS - 1;
	localparam CHECK_DELAY	= 1ns; // ???
	localparam CLK_PERIOD	= 20ns;

	// Test bench dut port signals
	reg tb_clk;
	reg tb_n_rst;
	reg tb_slave_read;
	reg tb_slave_write;
	reg [31:0] tb_slave_writedata;
	reg [31:0] tb_slave_addr;
	wire [31:0] tb_slave_readdata;

	// Master
	reg [31:0] tb_master_readdata;
	wire tb_master_read;
	wire tb_master_write;
	wire [31:0] tb_master_addr;
	wire [31:0] tb_master_writedata;
	wire tb_sobel_complete;
	
	// Declare Image Processing Test Bench Variables
	integer r;  // Loop variable for working with rows of pixels
	integer c;  // Loop variable for working with pixels in a row
	integer clr; // Loop variable for color
	integer cnt; // Counter to keep track of index in 1D image
	reg [7:0] tmp_byte;			// temp variable for read/writing bytes from/to files
	integer in_file;			// Input file handle
	integer res_file;			// Result file handle
	string  curr_res_filename;
	integer num_rows;			// The number of rows of pixels in the image file
	integer num_cols;			// The number of pixels pwer row in the image file
	integer num_pad_bytes;			// The number of padding bytes at the end of each row
	reg [2:0][7:0] in_pixel_val;	// The raw bytes read from the input file
	reg res_pixel_val;		// The sobel values for the result file
	integer i;			// Loop variable for misc. for loops
	integer quiet_catch; // Just used to remove warnings about not capturing the value of the file function returns

	// The bitmap file header is 14 Bytes
	reg [(BMP_HEADER_SIZE_BYTES - 1):0][7:0] in_bmp_file_header;
	reg [(BMP_HEADER_SIZE_BYTES - 1):0][7:0] res_bmp_file_header;
	reg [31:0] in_image_data_ptr;		// The starting byte address of the pixel array in the input file
	reg [31:0] res_image_data_ptr;	// The starting byte address of the pixel array in the result file
	// The normal/supported DIB header is 40 Bytes
	reg [(DIB_HEADER_C1_SIZE - 1):0][7:0] dib_header;
	reg [31:0] dib_header_size;	// The dib header size is a 32-bit unsigned integer
	reg [31:0] image_width;			// The image width (pixels) is a 32-bit signed integer
	reg [31:0] image_height;		// The image height (pixels) is a 32-bit signed integer
	reg [15:0] num_pixel_bits;	// The number of pixels per bit (1, 4, 8, 16, 24, 32) is an unsigned integer
	reg [31:0] compression_mode;// The type of compression used (this test bench doesn't support compression)
	// Pixel array stuff
	integer row_size_bytes;	// Used to store the calculated row size for the pixel array
	//reg [640*480*3:0][7:0] tb_image1D;
	reg [40*40*3:0][7:0] tb_image1D;
	//                                  reg [640*480:0] tb_outImage1D;
	//reg [640*480:0][7:0] tb_outImage1D;
	reg [40*40:0][7:0] tb_outImage1D;
	// 2-D Filter approach buffers
	//reg [7:0] tb_image1D [];
	reg [2:0][7:0] tb_input_image [][];	
	//reg tb_outImage1D [];
	task reset_dut;
	begin
		// Activate the design's reset (does not need to be synchronize with clock)
		tb_n_rst = 1'b0;
		
		// Wait for a couple clock cycles
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		// Release the reset
		@(negedge tb_clk);
		tb_n_rst = 1;
		
		// Wait for a while before activating the design
		@(posedge tb_clk);
		@(posedge tb_clk);
	end
	endtask

	// Clock gen block
	always
	begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2.0);
	end

	// DUT Portmap
	avalonBus AV_BUS(.clk(tb_clk),
			 .n_rst(tb_n_rst),
			.slave_read(tb_slave_read),
			.slave_write(tb_slave_write),
			.slave_writedata(tb_slave_writedata),
			.slave_addr(tb_slave_addr),
			.slave_readdata(tb_slave_readdata),
			.master_readdata(tb_master_readdata),
			.master_read(tb_master_read),
			.master_write(tb_master_write),
			.master_addr(tb_master_addr),
			.master_writedata(tb_master_writedata),
			.sobel_complete(tb_sobel_complete)
			);
	
	// Task for extracting the input file's header info
	task read_input_header;
	begin
		// Open the input file
		in_file = $fopen(INPUT_FILENAME, "rb");
		// Read in the Bitmap file header information (data is stored in little-endian (LSB first) format)
		for(i = 0; i < BMP_HEADER_SIZE_BYTES; i = i + 1) // Read the data in LSB format
		begin
			// Read a byte at a time
			quiet_catch = $fscanf(in_file,"%c" , in_bmp_file_header[i]);
		end
		// Extract the pixel array pointer (contains the file byte offset of the first byte of the pixel array)
		in_image_data_ptr[31:0] = in_bmp_file_header[(BMP_HEADER_SIZE_BYTES - 1):PIXEL_ARR_PTR_ADDR]; // The pixel array pointer is a 4 byte unsigned integer at the end of the header
		// Read in the DIB header information (LSB format)
		quiet_catch = $fscanf(in_file,"%c" , dib_header[0]);
		quiet_catch = $fscanf(in_file,"%c" , dib_header[1]);
		quiet_catch = $fscanf(in_file,"%c" , dib_header[2]);
		quiet_catch = $fscanf(in_file,"%c" , dib_header[3]);
		dib_header_size = dib_header[3:0];
		if(DIB_HEADER_C1_SIZE == dib_header_size)
		begin
			$display("Input bitmap file uses the BITMAPINFOHEADER type of DIB header");
			for(i = 4; i < dib_header_size; i = i + 1) // Read data in LSB format
			begin
				// Read a byte at a time
				quiet_catch = $fscanf(in_file,"%c" , dib_header[i]);
			end
			
			// Exract useful values from the header
			image_width				= dib_header[7:4];		// image width is bytes 4-7
			image_height			= dib_header[11:8];		// image height is bytes 8-11
			num_pixel_bits		= dib_header[15:14];	// number of bits per pixel is bytes 14 & 15
			compression_mode	= dib_header[19:16];	// compression mode is bytes 16-19
			
			if(16'd24 != num_pixel_bits)
				$fatal("This input file is using a pixel size (%0d)that is not supported, only 24bpp is supported", num_pixel_bits);
			
			
		end
		else if(DIB_HEADER_C2_SIZE == dib_header_size)
		begin
			$display("Input bitmap file uses the BITMAPCOREHEADER  type of DIB header");
			for(i = 4; i < dib_header_size; i = i + 1) // Read data in LSB format
			begin
				// Read a byte at a time
				quiet_catch = $fscanf(in_file,"%c" , dib_header[i]);
			end
			
			// Exract useful values from the header
			image_width			= {16'd0,dib_header[5:4]};	// image width is bytes 4 & 5
			image_height		= {16'd0,dib_header[7:6]};	// image height is bytes 6 & 7
			num_pixel_bits	= dib_header[11:10];				// number of bits per pixel is bytes 10 & 11
			
			if(16'd24 != num_pixel_bits)
				$fatal("This input file is using a pixel size (%0d)that is not supported, only 24bpp is supported", num_pixel_bits);
		end
		else
		begin
			$fatal("Unsupported DIB header size of %0d found in input file", dib_header_size);
		end
		
		// Shouldn't need a color palette -> skip it
		res_image_data_ptr = BMP_HEADER_SIZE_BYTES + dib_header_size;
		
		// Should be at the start of the image data (there shoudln't be a color palette)
		// Skip padding if needed
		if($ftell(in_file) != in_image_data_ptr)
			quiet_catch = $fseek(in_file, in_image_data_ptr, SEEK_START);
	end
	endtask


	// Task to populate the input image buffer
	task extract_input_image;
	begin
		// Calculate image data row size
		row_size_bytes = (((num_pixel_bits * image_width) + 31) / 32) * 4;
		// Calculate the number of rows in the pixel array
		num_rows = image_height;
		// Calculate the number of pixels per row
		num_cols = image_width;
		// Calculate the number of padding bytes per row
		num_pad_bytes	= row_size_bytes - (num_cols * 3);
		tb_input_image = new[num_rows];
		for(r = 0; r < num_rows; r = r + 1)
		begin
			tb_input_image[r] = new[num_cols];
			for(c = 0; c < num_cols; c = c + 1)
			begin
				// Get the input pixel value from the file (LSB format)
				quiet_catch = $fscanf(in_file, "%c", tb_input_image[r][c][0]);
				quiet_catch = $fscanf(in_file, "%c", tb_input_image[r][c][1]);
				quiet_catch = $fscanf(in_file, "%c", tb_input_image[r][c][2]);
			end
			// Finished a row of pixels
			// Skip past any padding bytes in the input file (get to the next row)
			quiet_catch = $fseek(in_file, num_pad_bytes, SEEK_CUR);
			// Ready to start working on the next row of pixels
		end
		
		
		// Done with pixel array section of input and row-dimension 1-D pass
		// Done with input file
		$fclose(in_file);
	end
	endtask
	
	task do_sobel;
	begin
		//write to startpixel
		tb_slave_writedata = 32'h00000000; //startpixel array address (addr of input image) ;
		tb_slave_addr = 1;
		tb_slave_write = 1;
		
		#CLK_PERIOD;
		
		#CLK_PERIOD;
	
		tb_slave_write = 0;
	
		#CLK_PERIOD;
	
		//write to endpixel
		tb_slave_writedata = 32'h80000000;//endpixel array address (addr of output image) ;
		tb_slave_addr = 2;
		tb_slave_write = 1;
	
		#CLK_PERIOD;
		#CLK_PERIOD;
	
		tb_slave_write = 0;
	
		#CLK_PERIOD;
		
		//write to status (initialization)
		tb_slave_writedata = 0;
		tb_slave_addr = 3;
		tb_slave_write = 1;
	
		#CLK_PERIOD;
		#CLK_PERIOD;
	
		tb_slave_write = 0;
	
		#CLK_PERIOD;
	
		//write to control
		tb_slave_writedata = 1;
		tb_slave_addr = 4;
		tb_slave_write = 1;
	
		#CLK_PERIOD;
		#CLK_PERIOD;
	
		tb_slave_write = 0;
	
		#CLK_PERIOD;
		//step 3	: wait for sobel to complete 
		for (cnt = 0; cnt < (num_rows*num_cols)+50; cnt = cnt + 1) begin
			if (tb_master_addr[31] == 0 && tb_master_read == 1) begin
				tb_master_readdata = {tb_image1D[tb_master_addr[30:0] << 2], tb_image1D[(tb_master_addr[30:0] << 2)+1], tb_image1D[(tb_master_addr[30:0] << 2)+2], tb_image1D[(tb_master_addr[30:0] << 2)+3]};
				//tb_master_readdata = {tb_image1D[tb_master_addr[30:0]], tb_image1D[(tb_master_addr[30:0])+1], tb_image1D[(tb_master_addr[30:0])+2], tb_image1D[(tb_master_addr[30:0])+3]};
			end else if(tb_master_addr[31] == 1 && tb_master_write == 1) begin
				//tb_outImage1D[tb_master_addr[30:0] + 31:tb_master_addr[30:0]] = tb_master_writedata;
				tb_outImage1D[tb_master_addr[30:0]] = tb_master_writedata[31:24];
				tb_outImage1D[tb_master_addr[30:0] + 1] = tb_master_writedata[23:16];
				tb_outImage1D[tb_master_addr[30:0] + 2] = tb_master_writedata[15:8];
				tb_outImage1D[tb_master_addr[30:0] + 3] = tb_master_writedata[7:0];
			end 			
			#CLK_PERIOD;
		end
	end
	endtask
	// Test bench process
	initial
	begin
		// Initial values
		tb_n_rst = 1'b1;

		//reset_dut;
		// Wait for some time before starting test cases
		#(1ns);
		
		// Read the input header
		read_input_header;
		
		// Populate the input buffer and close up the input file
		extract_input_image;


		cnt = 0;
		//reg [num_rows*num_cols*3:0] [7:0] tb_image1D;
		//reg [num_rows*num_cols:0] tb_outImage1D;
		//tb_image1D = new[num_rows*num_cols*3];
		//tb_outImage1D = new[num_rows*num_cols];
		//reg [7:0][num_rows*num_col] array;
		//array[0][0] = 8'd10;
		
		for (r = num_rows - 1; r >= 0; r = r - 1) begin
			for (c = 0; c < num_cols; c = c + 1) begin
				for (clr = 2; clr >= 0; clr = clr - 1) begin
					tb_image1D[cnt] = tb_input_image[r][c][clr];
					cnt = cnt + 1;
				end
			end
		end
		#(1ns);
		/*
		//Print out first 10 values	
		for(i = (num_cols * 54) + 139; i < (num_cols * 54) + 142; i = i + 3) begin
			$info("Pixel %0d Red: %d", i/ 3, tb_image1D[i]);
			$info("Pixel %0d Green: %d", i/3, tb_image1D[i+1]);
			$info("Pixel %0d Blue: %d", i/3, tb_image1D[i+2]);
			$info("-----------------------------------------------");
		end
		*/
		
		$info("First 32 Bits: %0d", {tb_image1D[0], tb_image1D[1], tb_image1D[2], tb_image1D[3]});
		$info("Second 32 Bits: %0d", {tb_image1D[4], tb_image1D[5], tb_image1D[6], tb_image1D[7]});
		$info("Third 32 Bits: %0d", {tb_image1D[8], tb_image1D[9], tb_image1D[10], tb_image1D[11]});
		$info("Fourth 32 Bits: %0d", {tb_image1D[120], tb_image1D[121], tb_image1D[122], tb_image1D[123]});
		$info("Fifth 32 Bits: %0d", {tb_image1D[124], tb_image1D[125], tb_image1D[126], tb_image1D[127]});
		$info("Sixth 32 Bits: %0d", {tb_image1D[128], tb_image1D[129], tb_image1D[130], tb_image1D[131]});
		$info("Seventh 32 Bits: %0d", {tb_image1D[240], tb_image1D[241], tb_image1D[242], tb_image1D[243]});
		$info("Eigth 32 Bits: %0d", {tb_image1D[244], tb_image1D[245], tb_image1D[246], tb_image1D[247]});
		$info("Ninth 32 Bits: %0d", {tb_image1D[248], tb_image1D[249], tb_image1D[250], tb_image1D[251]});
		// Activate the design's reset (does not need to be synchronize with clock)
		tb_n_rst = 1'b0;
		
		// Wait for a couple clock cycles
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		// Release the reset
		@(negedge tb_clk);
		tb_n_rst = 1;
		
		// Wait for a while before activating the design
		@(posedge tb_clk);
		@(posedge tb_clk);


		do_sobel;
		$info("DONE");
		/*
		#(1ms);
		if (tb_sobel_complete) begin
			for(cnt = 0; cnt < 40; cnt = cnt + 1) begin
				$info("Out Sobel %0d - %0d: %d", cnt, cnt+8, tb_outImage1D[cnt]);
			end
		end*/
		//postprocessing
	
		
	end
endmodule
	
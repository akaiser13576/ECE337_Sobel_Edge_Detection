// $Id: $
// File name:   tb_avalonBus.sv
// Created:     4/26/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Overall test bench for Avalon Bus operations.
`timescale 1ns / 100ps
module tb_avalonBus();

	parameter INPUT_FILENAME 	= "./docs/test2.bmp";
	parameter RESULT_FILENAME	= "./docs/sobel_rocket.bmp";
	
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
	reg [640*480*3:0][7:0] tb_image1D;
	//reg [40*40*3:0][7:0] tb_image1D;
	//                                  reg [640*480:0] tb_outImage1D;
	reg [(638*478 - 1):0] tb_outImage1D;
	//reg [40*40:0][7:0] tb_outImage1D;
	//reg [40*40:0] tb_outImage1D;
	// 2-D Filter approach buffers
	//reg [7:0] tb_image1D [];
	reg [2:0][7:0] tb_input_image [][];	
	//reg tb_outImage1D [];

	//init test array
	reg testarray[640 * 478];
	//reg temparray[640 * 478]; CHANGED
	reg [(640 * 478 - 1): 0] temparray;
	reg [7:0] pparray[80 * 480];
	//reg [7:0] output2D [480][640][3]; CHANGED
	reg [2:0][7:0] output2D [480][640];

	//int i = 0;
	int row = 0;
	int col = 0;


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
	
	// Task for generating the output file's header info to match the input one's
	task generate_output_header;
		input string filename;
	begin
		// Open the result file
		curr_res_filename = filename;
		res_file = $fopen(filename, "wb");
		// Create the bmp file header field (shouldn't change from input file, except for potetinally the image data ptr field)
		res_bmp_file_header = in_bmp_file_header;
		// Correct the image data ptr for discarding the color palette when allowed
		res_bmp_file_header[(BMP_HEADER_SIZE_BYTES - 1):PIXEL_ARR_PTR_ADDR] = res_image_data_ptr;
		// Write the bitmap header field to the result file
		for(i = 0; i < BMP_HEADER_SIZE_BYTES; i = i + 1) // Write data in LSB format
		begin
			// Write a byte at a time
			$fwrite(res_file, "%c", res_bmp_file_header[i]);
		end
		// Create the DIB header for the result file (shouldn't change from input file)
		for(i = 0; i < dib_header_size; i = i + 1) // Write data in LSB format
		begin
			// Write a byte at a time
			$fwrite(res_file, "%c", dib_header[i]);
		end
		
		// Should be at the start of the image data (there shoudln't be a color palette)
		// Skip padding if needed
		if($ftell(res_file) != res_image_data_ptr)
			quiet_catch = $fseek(res_file, res_image_data_ptr, SEEK_START);
	end
	endtask
	
	// Task for dumping an image buffer to the currently open result file
	task dump_image_buffer_to_file;
		//input reg [7:0] image_buffer[480][640][3]; CHANGED
		input reg [2:0][7:0] image_buffer[480][640]; 
	begin
		// Populate the image data in the result file
		//for(r = 0; r < num_rows; r = r + 1)
		for(r = num_rows - 1; r >= 0; r = r - 1)
		begin
			for(c = 0; c < num_cols; c = c + 1)
			begin
				// Done filtering each color portion of the pixel -> store full pixel to the file (LSB Format)
				$fwrite(res_file, "%c", image_buffer[r][c][0]);
				$fwrite(res_file, "%c", image_buffer[r][c][1]);
				$fwrite(res_file, "%c", image_buffer[r][c][2]);
			end
			// Finished a row of pixels
			// Add padding bytes to result file (advance it to the next row)
			quiet_catch = $fseek(res_file, num_pad_bytes, SEEK_CUR);
		end
		
		// Done with result file
		// Create end of file marker
		$fwrite(res_file, "%c", 8'd0);
		// Done with result file
		$fclose(res_file);
		$info("Done generating filtered file '%s' from input file '%s'", curr_res_filename, INPUT_FILENAME);
	end
	endtask
	
	task do_sobel;
	begin
		tb_slave_read = 1'b0;
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
		cnt = 0;
		//step 3	: wait for sobel to complete 
		while (tb_sobel_complete == 0) begin 
			
			if (tb_master_addr[31] == 0 && tb_master_read == 1) begin
				tb_master_readdata = {tb_image1D[tb_master_addr[30:0] << 2], tb_image1D[(tb_master_addr[30:0] << 2)+1], tb_image1D[(tb_master_addr[30:0] << 2)+2], tb_image1D[(tb_master_addr[30:0] << 2)+3]};
				//tb_master_readdata = {tb_image1D[tb_master_addr[30:0]], tb_image1D[(tb_master_addr[30:0])+1], tb_image1D[(tb_master_addr[30:0])+2], tb_image1D[(tb_master_addr[30:0])+3]};
			end else if(tb_master_addr[31] == 1 && tb_master_write == 1) begin
				//tb_outImage1D[tb_master_addr[30:0] + 31:tb_master_addr[30:0]] = tb_master_writedata;
				
				tb_outImage1D[tb_master_addr[30:0]] = tb_master_writedata[31];//, tb_master_writedata[30]:24];
				//if(cnt == 0 || cnt == 1)
				//$info("TB_OUTIMAGE1D[0]: %0d", tb_outImage1D[0]);
				tb_outImage1D[tb_master_addr[30:0] + 1] = tb_master_writedata[30];//tb_master_writedata[23:16];
				tb_outImage1D[tb_master_addr[30:0] + 2] = tb_master_writedata[29];//tb_master_writedata[15:8];
				tb_outImage1D[tb_master_addr[30:0] + 3] = tb_master_writedata[28];//tb_master_writedata[7:0];	
				tb_outImage1D[tb_master_addr[30:0] + 4] = tb_master_writedata[27];
				tb_outImage1D[tb_master_addr[30:0] + 5] = tb_master_writedata[26];
				tb_outImage1D[tb_master_addr[30:0] + 6] = tb_master_writedata[25];
				tb_outImage1D[tb_master_addr[30:0] + 7] = tb_master_writedata[24];
				tb_outImage1D[tb_master_addr[30:0] + 8] = tb_master_writedata[23];
				tb_outImage1D[tb_master_addr[30:0] + 9] = tb_master_writedata[22];
				tb_outImage1D[tb_master_addr[30:0] + 10] = tb_master_writedata[21];
				tb_outImage1D[tb_master_addr[30:0] + 11] = tb_master_writedata[20];
				tb_outImage1D[tb_master_addr[30:0] + 12] = tb_master_writedata[19];
				tb_outImage1D[tb_master_addr[30:0] + 13] = tb_master_writedata[18];
				tb_outImage1D[tb_master_addr[30:0] + 14] = tb_master_writedata[17];
				tb_outImage1D[tb_master_addr[30:0] + 15] = tb_master_writedata[16];
				tb_outImage1D[tb_master_addr[30:0] + 16] = tb_master_writedata[15];
				tb_outImage1D[tb_master_addr[30:0] + 17] = tb_master_writedata[14];
				tb_outImage1D[tb_master_addr[30:0] + 18] = tb_master_writedata[13];
				tb_outImage1D[tb_master_addr[30:0] + 19] = tb_master_writedata[12];
				tb_outImage1D[tb_master_addr[30:0] + 20] = tb_master_writedata[11];
				tb_outImage1D[tb_master_addr[30:0] + 21] = tb_master_writedata[10];
				tb_outImage1D[tb_master_addr[30:0] + 22] = tb_master_writedata[9];
				tb_outImage1D[tb_master_addr[30:0] + 23] = tb_master_writedata[8];
				tb_outImage1D[tb_master_addr[30:0] + 24] = tb_master_writedata[7];
				tb_outImage1D[tb_master_addr[30:0] + 25] = tb_master_writedata[6];
				tb_outImage1D[tb_master_addr[30:0] + 26] = tb_master_writedata[5];
				tb_outImage1D[tb_master_addr[30:0] + 27] = tb_master_writedata[4];
				tb_outImage1D[tb_master_addr[30:0] + 28] = tb_master_writedata[3];
				tb_outImage1D[tb_master_addr[30:0] + 29] = tb_master_writedata[2];
				tb_outImage1D[tb_master_addr[30:0] + 30] = tb_master_writedata[1];
				tb_outImage1D[tb_master_addr[30:0] + 31] = tb_master_writedata[0];
				cnt = cnt + 1;
			end 			
			#CLK_PERIOD;
		end
		/*
		for (cnt = 0; cnt < (num_rows*num_cols)+50; cnt = cnt + 1) begin
			if (tb_master_addr[31] == 0 && tb_master_read == 1) begin
				tb_master_readdata = {tb_image1D[tb_master_addr[30:0] << 2], tb_image1D[(tb_master_addr[30:0] << 2)+1], tb_image1D[(tb_master_addr[30:0] << 2)+2], tb_image1D[(tb_master_addr[30:0] << 2)+3]};
				//tb_master_readdata = {tb_image1D[tb_master_addr[30:0]], tb_image1D[(tb_master_addr[30:0])+1], tb_image1D[(tb_master_addr[30:0])+2], tb_image1D[(tb_master_addr[30:0])+3]};
			end else if(tb_master_addr[31] == 1 && tb_master_write == 1) begin
				//tb_outImage1D[tb_master_addr[30:0] + 31:tb_master_addr[30:0]] = tb_master_writedata;
				tb_outImage1D[tb_master_addr[30:0]] = tb_master_writedata[31];//, tb_master_writedata[30]:24];
				tb_outImage1D[tb_master_addr[30:0] + 1] = tb_master_writedata[30];//tb_master_writedata[23:16];
				tb_outImage1D[tb_master_addr[30:0] + 2] = tb_master_writedata[29];//tb_master_writedata[15:8];
				tb_outImage1D[tb_master_addr[30:0] + 3] = tb_master_writedata[28];//tb_master_writedata[7:0];	
				tb_outImage1D[tb_master_addr[30:0] + 4] = tb_master_writedata[27];
				tb_outImage1D[tb_master_addr[30:0] + 5] = tb_master_writedata[26];
				tb_outImage1D[tb_master_addr[30:0] + 6] = tb_master_writedata[25];
				tb_outImage1D[tb_master_addr[30:0] + 7] = tb_master_writedata[24];
				tb_outImage1D[tb_master_addr[30:0] + 8] = tb_master_writedata[23];
				tb_outImage1D[tb_master_addr[30:0] + 9] = tb_master_writedata[22];
				tb_outImage1D[tb_master_addr[30:0] + 10] = tb_master_writedata[21];
				tb_outImage1D[tb_master_addr[30:0] + 11] = tb_master_writedata[20];
				tb_outImage1D[tb_master_addr[30:0] + 12] = tb_master_writedata[19];
				tb_outImage1D[tb_master_addr[30:0] + 13] = tb_master_writedata[18];
				tb_outImage1D[tb_master_addr[30:0] + 14] = tb_master_writedata[17];
				tb_outImage1D[tb_master_addr[30:0] + 15] = tb_master_writedata[16];
				tb_outImage1D[tb_master_addr[30:0] + 16] = tb_master_writedata[15];
				tb_outImage1D[tb_master_addr[30:0] + 17] = tb_master_writedata[14];
				tb_outImage1D[tb_master_addr[30:0] + 18] = tb_master_writedata[13];
				tb_outImage1D[tb_master_addr[30:0] + 19] = tb_master_writedata[12];
				tb_outImage1D[tb_master_addr[30:0] + 20] = tb_master_writedata[11];
				tb_outImage1D[tb_master_addr[30:0] + 21] = tb_master_writedata[10];
				tb_outImage1D[tb_master_addr[30:0] + 22] = tb_master_writedata[9];
				tb_outImage1D[tb_master_addr[30:0] + 23] = tb_master_writedata[8];
				tb_outImage1D[tb_master_addr[30:0] + 24] = tb_master_writedata[7];
				tb_outImage1D[tb_master_addr[30:0] + 25] = tb_master_writedata[6];
				tb_outImage1D[tb_master_addr[30:0] + 26] = tb_master_writedata[5];
				tb_outImage1D[tb_master_addr[30:0] + 27] = tb_master_writedata[4];
				tb_outImage1D[tb_master_addr[30:0] + 28] = tb_master_writedata[3];
				tb_outImage1D[tb_master_addr[30:0] + 29] = tb_master_writedata[2];
				tb_outImage1D[tb_master_addr[30:0] + 30] = tb_master_writedata[1];
				tb_outImage1D[tb_master_addr[30:0] + 31] = tb_master_writedata[0];
				
			end 			
			#CLK_PERIOD;
		end*/
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
		$info("DONEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
		@(posedge tb_clk);
		@(posedge tb_clk);
		if (tb_sobel_complete == 1) begin
			$info("DONE");
			for(cnt = 0; cnt < 32; cnt = cnt + 1) begin
				$info("Out Sobel %0d - %0d: %d", cnt, cnt+8, tb_outImage1D[cnt]);
			end
	
			$display("tb_outImageID");
			for (i = 0; i < 10; i = i + 1)
			begin
			$display("Row %d", i);
			$display("Row %d first 2 bits %d", i, {tb_outImage1D[i*640], tb_outImage1D[i*640+1]} );
			$display("Row %d rand middle 2 bits: %d", i, {tb_outImage1D[i*640 + 300], tb_outImage1D[i*640 + 301]});
			$display("Row %d last 2 bits: %d %d", i, tb_outImage1D[i*640 + 638], tb_outImage1D[i*640 + 639] );
			end
			
			$display("index 477: %d", tb_outImage1D[477]);
			$display("index 478: %d", tb_outImage1D[478]);
			$display("index 479: %d", tb_outImage1D[479]);
			$display("index 478 2nd row: %d", tb_outImage1D[477 + 640]);
			$display("index 478 2nd row: %d", tb_outImage1D[478 + 640]);
			$display("index 479 2nd row: %d", tb_outImage1D[479 + 640]);

						

			$display("\n");
			
			row = 0;
			col = 0;
			
			//init first and last 2 bits of each row
			for (i = 0; i < 640*478; i = i + 1) 
			begin
				col = i % 640;
	
				//track row and col
				if (i != 0 && i % 640 == 0)
				begin
					row = row + 1;
					//col = 0;
				end
	
				//init first and last bits of each row to 0
				if (col == 0)
				begin
					temparray[i] = 0;
					temparray[i+1] = 0;
				end
				else if (col == 639)
				begin
					temparray[i] = 0;
					temparray[i-1] = 0;
				end
				
			end
	
			$display("TEMPARRAY DATA 1");
			for (i = 0; i < 10; i = i + 1)
			begin
			$display("Row %d", i);
			$display("Row %d first 2 bits %d", i, {temparray[i*640], temparray[i*640+1]} );
			$display("Row %d rand middle 2 bits: %d", i, {temparray[i*640 + 300], temparray[i*640 + 301]});
			$display("Row %d last 2 bits: %d", i, {temparray[i*640 + 638], temparray[i*640 + 639]} );
			end
			$display("\n");
	
			row = 0;
			col = 0;
			//copy and format testdata
			for (i = 0; i < 640*478; i = i + 1) 
			begin
				col = i % 640;
	
				//track row and col
				if (i != 0 && i % 640 == 0)
				begin
					row = row + 1;
					//col = 0;
				end
				
				if (row % 2 == 0)
				begin
					if (col != 639 || col != 638) begin
						temparray[i+1] = tb_outImage1D[i];
					end
	
				end
				else if (row % 2 == 1)
				begin
					if (col != 0 || col != 1)
					begin
						temparray[i-1] = tb_outImage1D[i];
					end
				end
				
			end
	
			$display("TEMPARRAY DATA");
			for (i = 0; i < 10; i = i + 1)
			begin
			$display("Row %d", i);
			$display("Row %d first 2 bits %d", i, {temparray[i*640], temparray[i*640+1]} );
			$display("Row %d rand middle 2 bits: %d", i, {temparray[i*640 + 300], temparray[i*640 + 301]});
			$display("Row %d last 2 bits: %d", i, {temparray[i*640 + 638], temparray[i*640 + 639]} );
			end
			$display("\n");
	
			
			//output 24 bit wide 2D array
			$display("index 477: %d", temparray[477]);
			$display("index 478: %d", temparray[478]);
			$display("index 479: %d", temparray[479]);

			$display("index 477 2nd row: %d", temparray[477 + 640]);
			$display("index 478 2nd row: %d", temparray[478 + 640]);
			$display("index 479 2nd row: %d", temparray[479 + 640]);

	
	
			//add 0 border to top of image
			row = 0;
			for (col = 0; col < 640; col = col + 1) begin
				output2D[row][col][0] = 8'd0;
				output2D[row][col][1] = 8'd0;
				output2D[row][col][2] = 8'd0;
			end
	
			//copy in image data in 24 bit format
			row = 0;
			col = 0;
	
			for (row = 1; row < 480; row = row + 1) begin
				for (col = 0; col < 640; col = col + 1) begin
					if (temparray[(row-1)*640 + col] == 1)
					begin
						output2D[row][col][0] = 8'b11111111;
						output2D[row][col][1] = 8'b11111111;
						output2D[row][col][2] = 8'b11111111;
					end
					else if (temparray[(row-1)*640 + col] == 0)
					begin
						output2D[row][col][0] = 8'b00000000;
						output2D[row][col][1] = 8'b00000000;
						output2D[row][col][2] = 8'b00000000;
					end
				end
			end
	
			//add 0 border to bottom of image
			row = 479;
			for (col = 0; col < 640; col = col + 1) begin
				output2D[row][col][0] = 8'd0;
				output2D[row][col][1] = 8'd0;
				output2D[row][col][2] = 8'd0;
			end

			$display("index 477 : %b", output2D[1][477]);
			$display("index 478: %b", output2D[1][478]);
			$display("index 479: %b", output2D[1][479]);
			$display("index 477 2nd row: %b", output2D[2][477]);
			$display("index 478 2nd row: %b", output2D[2][478]);
			$display("index 479 2nd row: %b", output2D[2][479]);
		

			generate_output_header(RESULT_FILENAME);
			dump_image_buffer_to_file(output2D);
			
			
			
				
		end
			//postprocessing
		
			
	end	
endmodule	
		
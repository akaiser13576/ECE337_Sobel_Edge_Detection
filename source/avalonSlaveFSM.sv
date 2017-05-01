// $Id: $
// File name:   avalonSlaveFSM.sv
// Created:     4/7/2017
// Author:      Pradyumna Modukuru
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: FSM for the Avalon Slave

module avalonSlaveFSM(
	input wire clk, read, write, n_rst,  //active high 
	input wire [31:0] address, writedata,
	output reg [31:0] readdata,

	//global registers
	output reg [31:0] startpixel, //1
	output reg [31:0] endpixel,  //2
	output reg [31:0] status,   //3 (1 is busy , 0 is not) 
	output reg [31:0] control  //4
);

typedef enum bit [1:0] {IDLE,READ,WRITE} stateType;

stateType current;
stateType next;

reg [31:0] nextstart, nextend;
reg nextstatus, nextcontrol;

//state register
always_ff @ (posedge clk, negedge n_rst)
begin
	if( n_rst == 1'b0)
        begin
		current <= IDLE;
		startpixel <= 0;
		endpixel <= 0;
		status <= 0;
		control <= 0;	
	end
		
	else
	begin	
		current <= next;
		startpixel <= nextstart;
		endpixel <= nextend;
		status <= nextstatus;
		control <= nextcontrol;	
	end
end


//FSM
always_comb
begin
	next = current;

	case(current)
	//1 cycle to check address and enables
	IDLE:
		if (write && address == 32'd1)
		begin
			next = WRITE;
		end
		else if (write && address == 32'd2)
		begin
			next = WRITE;
		end
		else if (read && address == 32'd3)
		begin
			next = READ;
		end
		else if (write && address == 32'd3)
		begin
			next = WRITE;
		end
		else if (write && address == 32'd4)
		begin
			next = WRITE;
		end
	WRITE:
		begin
			next = IDLE;
		end
	READ:
		begin
			if (read && address == 32'd3)
			begin
				next = READ;
			end
			else begin
				next = IDLE;
			end
		end
	
	endcase

end

//comb logic
always_comb
begin
	nextstart = startpixel;
	nextend = endpixel;
	nextcontrol = control;
	nextstatus = status;
	readdata = 0;

	case(current)
	/*IDLE:
	begin
		nextstatus = 0;
	end*/
	WRITE:
	begin
		//nextstatus = 1;
		if (address == 32'd1)
		begin
			nextstart = writedata;
		end
		else if (address == 32'd2)
		begin	
			nextend = writedata;
		end
		else if (address == 32'd4)
		begin
	 		nextcontrol = writedata;
		end
		else if (address == 32'd3)
		begin
			nextstatus = writedata;
		end
	end
	READ:
	begin
		//nextstatus = 1;
		if (address == 32'd3)
		begin
			readdata = nextstatus;
		end

	end
	endcase
end

endmodule

// $Id: $
// File name:   avalonMasterFSM.sv
// Created:     4/11/2017
// Author:      Pradyumna Modukuru
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Avalon Master FSM

module avalonMasterFSM(
	input wire clk, n_rst,  //active high 
	input wire [31:0] readdata,

	//inputs from controller
	input wire readen, writen,
	input [31:0] wdata,
	input [31:0] inaddr, //comes from controller-- location to write wdata to in SRAM or to read from in SRAM

	output reg read, write, dataready,
	output reg [31:0] address, writedata

);

typedef enum bit [2:0] {IDLE,READ,READDATA1,READDATA2,WRITE,WRITEDATA} stateType;

stateType current;
stateType next;

//state register
always_ff @ (posedge clk, negedge n_rst)
begin
	if( n_rst == 1'b0)
        begin
		current <= IDLE;
	end
		
	else
	begin	
		current <= next;
	end
end

//FSM
always_comb
begin
	next = current;

	case(current)
	//1 cycle to assert read/write and data signals
	IDLE:
	begin
		if (readen)
		begin
			next = READ;
		end
		else if (writen)
		begin	
			next = WRITE;
		end
	end
	WRITE:
		begin
			next = WRITEDATA;
		end
	READ:
		begin
			next = READDATA1;
		end
	READDATA1:
		begin
			next = READDATA2;
		end
	READDATA2:
		begin
			next = IDLE;
		end
	WRITEDATA:
		begin
			next = IDLE;
		end	
	endcase

end

//comb logic
always_comb
begin
	read = 0;
	write = 0;
	writedata = 0;
	address = 0;
	dataready = 0;

	case(current)
	IDLE:
	begin
		address = inaddr;
	end

	WRITE:
	begin
		write = 1;
		writedata = wdata;
		address = inaddr;
	end
	READ:
	begin
		read = 1;
		address = inaddr;
	end
	READDATA1:
	begin
		read = 1;
		//dataready = 1;
		address = inaddr;
	end
	READDATA2:
	begin
		//read = 1;
		dataready = 1;
		address = inaddr;
	end
	WRITEDATA:
	begin
		write = 1;
		writedata = wdata;
		address = inaddr;
	end
	endcase
end

endmodule

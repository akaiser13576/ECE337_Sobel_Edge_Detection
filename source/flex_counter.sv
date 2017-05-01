// $Id: $
// File name:   flex_counter.sv
// Created:     2/3/2017
// Author:      Pradyumna Modukuru
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter Specifications

module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire n_rst, clear, count_enable, clk,
	input wire [NUM_CNT_BITS-1:0] rollover_val,
	output wire [NUM_CNT_BITS-1:0] count_out,
	output wire rollover_flag
);

reg [NUM_CNT_BITS-1:0] count_reg;
reg [NUM_CNT_BITS-1:0] next_cnt;
reg roll_reg, next_roll;

always_ff @(posedge clk, negedge n_rst)
begin
	if (n_rst == 1'b0) begin
		count_reg <= '0;
	end
	else begin
		count_reg <= next_cnt;
	end
end

always_ff @(posedge clk, negedge n_rst)
begin
	if (n_rst == 1'b0) begin
		roll_reg <= '0;
	end
	else begin
		roll_reg <= next_roll;
	end
end

always_comb begin
	next_roll = rollover_flag;
	next_cnt = count_out;

	if (clear == 1'b1) begin
		next_cnt = '0;
		next_roll = '0;
	end
	else if (count_enable == 1'b1) begin
		if (count_out == rollover_val - 1) begin
			next_roll = 1'b1;
		end
		else begin
			next_roll = 1'b0;
		end
		
		if (count_out == rollover_val) begin
			next_cnt = 1'b1;
		end
		else begin
			next_cnt = next_cnt + 1;
		end
	end
	else 
	begin
		if (count_out == rollover_val) begin
			next_roll = 1'b1;
		end
		else begin
			next_roll = 1'b0;
		end
	end
end


assign count_out = count_reg;
assign rollover_flag = roll_reg;

endmodule
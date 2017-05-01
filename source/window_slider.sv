// $Id: $
// File name:   window_slider.sv
// Created:     4/23/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Window slider for calculating next set of addresses.
module window_slider(
	input wire clk,
	input wire n_rst,
	input wire nx_pixel_en,
	input wire [31:0] image_start_addr,
	//output reg edge_detected,
	output reg next_edge_detected,
	output reg addr_done,
	output reg [31:0] next_calc_address,
	output reg next_last_pix_read
);

	reg [7:0] col_cnt;
	reg [8:0] row_cnt;
	reg [1:0] matrix_cnt;
	reg [31:0] calc_address;
		
	reg [7:0] next_col_cnt;
	reg [8:0] next_row_cnt;
	reg [1:0] next_matrix_cnt;
	//reg next_calc_address;

	//reg [31:0] start_addr_1, start_addr2, start_addr3, new_row_addr1, new_row_addr2;
	typedef enum bit [4:0] {IDLE, CALC1, DONE1, CALC2, DONE2, CALC3, DONE3, INCDEC_COL, DONEINCDEC, NEW_ROW1, DONEN1, NEW_ROW2, DONEN2, INC_ROW, DONEINC_ROW, DONE, ENDDONE} stateType;
	stateType state;
	stateType next_state;
	reg incdec; // 0 = moving to the right, 1 = moving to the left
	reg next_incdec;
	reg addr_done_prev;
	reg [31:0] calc_tmp1, calc_tmp2, calc_tmp3, calc_tmp4;
	//reg hit_edge;
	reg edge_detected, last_pix_read;
	reg getAddr, next_getAddr;
	
	// REGISTER LOGIC
	always_ff @ (posedge clk, negedge n_rst) begin : REG_LOGIC	
		if(n_rst == 1'b0) begin
			state <= IDLE;
			col_cnt <= 0;
			row_cnt <= 0;
			matrix_cnt <= 0;
			calc_address <= 0;
			edge_detected <= 0;
			incdec <= 0;
			last_pix_read <= 0;
			addr_done_prev <= 0;
			getAddr <= 0;
			//start_addr_1 start_addr2, start_addr3, new_row_addr1, new_row_addr2 <= 0;
			
		end else begin
			state <= next_state;
		        col_cnt <= next_col_cnt;
			row_cnt <= next_row_cnt;
			matrix_cnt <= next_matrix_cnt;
			calc_address <= next_calc_address;
			edge_detected <= next_edge_detected;
			incdec <= next_incdec;
			last_pix_read <= next_last_pix_read;
			addr_done_prev <= addr_done;
			getAddr <= next_getAddr;
		end
	end

	// NEXT STATE LOGIC
	always_comb begin: NXT_LOGIC
		next_getAddr = getAddr;
		next_state = state;
		next_col_cnt = col_cnt;
		next_row_cnt = row_cnt;
		next_matrix_cnt = matrix_cnt;
		next_calc_address = calc_address;
		calc_tmp1 = 0;
		calc_tmp2 = 0;
		calc_tmp3 = 0;
		calc_tmp4 = 0;
		addr_done = addr_done_prev;
		//hit_edge = 0;
		next_edge_detected = edge_detected;
		next_incdec = incdec;
		next_last_pix_read = last_pix_read;
	
		//calc_address = 0;
		//nx_address = 0;
		
		case(state)
			IDLE: begin 	
				if(nx_pixel_en == 1 && edge_detected == 0 ) begin
					next_state = CALC1;
					next_getAddr = 1;
				end else if(nx_pixel_en == 1 && edge_detected == 1) begin
					next_state = NEW_ROW1;
					next_edge_detected = 0;
					next_getAddr = 1;
				end else begin
					next_getAddr = 0;
					next_state = IDLE;
				end
			end CALC1: begin	
				if(addr_done_prev == 1'b1)
					addr_done = 0;
				else if (nx_pixel_en == 1 || getAddr == 1) begin
					next_getAddr = 0;	
					if(matrix_cnt == 0) begin // NEED TO CALC INITIAL VALS
						calc_tmp1 = 32'h000001E0 * row_cnt; //(h01E0 = 480)
						//calc_tmp1 = 32'd30 * row_cnt;
						calc_tmp2 = 32'h00000003 * col_cnt;
						calc_tmp3 = image_start_addr + calc_tmp1;
						next_calc_address = calc_tmp2 + calc_tmp3;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONE1;
						//addr_done = 1'b1;
					end else if(matrix_cnt == 2) begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = 2'b00;
						next_state = DONE2;
						//addr_done = 1'b1;
					end else begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONE1;
						//addr_done = 1'b1;
					end				
				end
			end DONE1: begin
				addr_done = 1;
				next_state = CALC1;
			end DONE2: begin
				addr_done = 1;
				next_state = CALC2;
			end DONE3: begin
				addr_done = 1;
				next_state = CALC3;
			end DONEINCDEC: begin
				addr_done = 1;
				next_state = INCDEC_COL;
			end DONEN1: begin
				addr_done = 1;
				next_state = NEW_ROW1;
			end DONEN2: begin
				addr_done = 1;
				next_state = NEW_ROW2;
			end DONEINC_ROW: begin
				addr_done = 1;
				next_state = INC_ROW;
			end CALC2: begin
				if(addr_done_prev == 1'b1)
					addr_done = 1'b0;	
				else if (nx_pixel_en == 1) begin
					if(matrix_cnt == 0) begin // NEED TO CALC INITIAL VAL - ADD 1 ROW (h01E0 = 480)
						next_calc_address = calc_address + 32'd478;
						//next_calc_address = calc_address + 32'd28;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONE2;
						//addr_done = 1'b1;
					end else if(matrix_cnt == 2) begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = 2'b00;
						next_state = DONE3;
						//addr_done = 1'b1;
					end else begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONE2;
						//addr_done = 1'b1;
					end
				end	
			end CALC3: begin
				if(addr_done_prev == 1'b1)
					addr_done = 1'b0;
				else if (nx_pixel_en == 1) begin	
					if(matrix_cnt == 0) begin // NEED TO CALC INITIAL VAL - ADD 1 ROW (h01E0 = 480)
						next_calc_address = calc_address + 32'd478;
						//next_calc_address = calc_address + 32'd28;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONE3;
						//addr_done = 1'b1;
					end else if(matrix_cnt == 2) begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = 2'b00;
						next_state = DONEINCDEC;
						//addr_done = 1'b1;
					end else begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONE3;
						//addr_done = 1'b1;
					end 
					if(row_cnt == 477 && col_cnt == 0 && matrix_cnt == 2) begin // At the last pixel now
					//if(row_cnt == 37 && col_cnt == 0 && matrix_cnt == 2) begin // At the last pixel now
						//next_last_pix_read = 1'b1;
						next_state = ENDDONE;
					end
				end	
			end INCDEC_COL: begin
				if (addr_done_prev == 1'b1) 
					addr_done = 1'b0;
				else if(incdec == 0) begin // Moving to the right
					if(col_cnt == 159) begin // Hit an edge and reverse
					//if(col_cnt == 9) begin // Hit an edge and reverse
						next_col_cnt = 157; 
						//next_col_cnt = 7;
						next_incdec = 1;
						//hit_edge = 1;
						next_edge_detected = 1;
						next_state = IDLE;
					end else begin
						next_col_cnt = col_cnt + 1; // Go right
						next_state = IDLE;
					end
				end else begin // Moving to the left
					if(col_cnt == 0) begin  // Hit an edge and reverse
						next_col_cnt = 2;
						next_incdec = 0;
						//hit_edge = 1;
						next_edge_detected = 1;
						next_state = IDLE;
					end else begin
						next_col_cnt = col_cnt - 1; // Go left
						next_state = IDLE;
					end
				end
			end NEW_ROW1: begin
				if(addr_done_prev == 1'b1)
					addr_done = 1'b0;
				else if (nx_pixel_en == 1 || getAddr == 1) begin	
					next_getAddr = 0;
					if(matrix_cnt == 0 && incdec == 1) begin // NEED TO CALC INITIAL VAL -- Moving down on right edge
						next_calc_address = calc_address + 32'd475;
						//next_calc_address = calc_address + 32'd25;	
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONEN1;
						//addr_done = 1'b1;
					end else if(matrix_cnt == 0 && incdec == 0) begin // NEED TO CALC INITIAL VAL -- Moving down on left edge
						next_calc_address = calc_address + 32'd478;
						//next_calc_address = calc_address + 32'd28;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONEN1;
						//addr_done = 1'b1;
					end else if(matrix_cnt == 2) begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = 2'b00;
						next_state = DONEN2;
						//addr_done = 1'b1;
					end else begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONEN1;
						//addr_done = 1'b1;
					end	
				end
			end NEW_ROW2: begin
				if(addr_done_prev == 1'b1)
					addr_done = 1'b0;
				else if (nx_pixel_en == 1) begin	
					if(matrix_cnt == 0) begin // NEED TO CALC INITIAL VAL
						next_calc_address = calc_address + 32'd1;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONEN2;
						//addr_done = 1'b1;
					end else if(matrix_cnt == 2) begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = 2'b00;
						next_state = DONEINC_ROW;
						//addr_done = 1'b1;
					end else begin // ONLY NEED TO UPDATE BY 1
						next_calc_address = calc_address + 32'h00000001;
						next_matrix_cnt = matrix_cnt + 2'b01;
						next_state = DONEN2;
						//addr_done = 1'b1;
					end
				end	
			end INC_ROW: begin
				if (addr_done_prev == 1'b1) 
					addr_done = 1'b0;
				else begin	
					next_row_cnt = row_cnt + 1;
					next_state = IDLE;
				end
			end ENDDONE: begin
				addr_done = 1;
				next_last_pix_read = 1;
				next_state = DONE;
			end DONE: begin
				if (addr_done_prev == 1) 
					addr_done = 0;
				next_last_pix_read = 1;
			end
		endcase
	end
endmodule

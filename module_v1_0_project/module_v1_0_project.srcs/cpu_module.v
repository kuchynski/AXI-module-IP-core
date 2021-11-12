`timescale 1ns / 1ps
module cpu_module #(
)(
	input clk,
	input rstn,

	input[31:0] CHANGE_SLV_REG_NUMBER_WRITE,
	inout[31:0] CHANGE_SLV_REG_NUMBER_READ,
	input CHANGE_SLV_REG_EVENT_WRITE,
	input CHANGE_SLV_REG_EVENT_READ,
	input[31:0] ADDRESS_MY,
	input[31:0] ADDRESS_SCHEDULER,
	input TIMER_IRQ,
	input[63:0] time_value,

	input irq_tx,
	input irq_rx,
	input[1:0] kind_work,
	input[63:0] RECEIVE_DATA,
	input[12:0] RECEIVE_ADDRESS,
	output[63:0] SEND_DATA,
	input[12:0] SEND_ADDRESS,
	input RECEIVE_VALID,

	output[31:0] mst_data,
	output reg[1:0] mst_prior_dg,
	output[31:0] mst_address,
	output reg[31:0] mst_data_time,
	output reg mst_start,
	output reg mst_start_time,
	input mst_stop
);

	wire[10:0] size_datagram = 63;
	reg[2:0] data_run = 0;
	reg[2:0] state, state_return;
	reg[7:0] count_dg;
	reg[31:0] period_dg;

	assign mst_address = ADDRESS_SCHEDULER;
	wire[31:0] my_address_0 = ADDRESS_MY + 32'h000;
	wire[31:0] my_address_1 = ADDRESS_MY + 32'h800;
	assign mst_data = (mst_prior_dg)? {my_address_1[31:11], size_datagram[10:0]} : {my_address_0[31:11], size_datagram[10:0]};

	always@(posedge clk) begin
		if(!rstn) begin
			mst_start <= 0;
			mst_start_time <= 0;
			mst_data_time <= 0;
			count_dg <= 0;
			state <= 0;
		end else begin
			if(ADDRESS_SCHEDULER == 0 || ADDRESS_MY == 0) begin
				count_dg <= 0;
				mst_start <= 0;
				mst_start_time <= 0;
			end else begin
				case(state)
					0: begin
						mst_start_time <= 0;
						if(kind_work == 0) begin
							if(irq_rx) begin
								mst_start <= 1;
								state_return <= 0;
								state <= 1; 
							end
						end else if(kind_work == 1) begin
							if(TIMER_IRQ) begin
								mst_prior_dg <= 0;
								mst_start <= 1;
								state_return <= 0;
								state <= 1; 
							end
						end else if(kind_work == 2) begin
							if(TIMER_IRQ) begin
								mst_data_time <= time_value[31:0];
								count_dg <= 10;
								period_dg <= 1300;
								state <= 3;
							end
						end
					end
					1: begin // dg
						mst_start <= 0;
						mst_start_time <= 0;
						if(mst_stop)
							state <= state_return; 
					end
					2: begin
						mst_prior_dg <= 0;
						state_return <= 4;
						mst_start <= 1;
						state <= 1; 
					end
					4: begin
						mst_prior_dg <= 1;
						state_return <= 7;
						mst_start <= 1;
						state <= 1; 
					end
					7: begin
						mst_prior_dg <= 1;
						state_return <= 6;
						mst_start <= 1;
						state <= 1; 
					end
					5: begin
						mst_prior_dg <= 0;
						state_return <= 0;
						mst_start <= 1;
						state <= 1; 
					end
					3: begin
						count_dg <= count_dg - 1;
						if(count_dg > 0) begin
							mst_data_time <= mst_data_time + period_dg;
							state_return <= 2;
							mst_start_time <= 1;
							state <= 1; 
						end else
							state <= 0; 
					end
					6: begin
						mst_data_time <= mst_data_time + 3000;
						state_return <= 5;
						mst_start_time <= 1;
						state <= 1;
					end
				endcase
			end
		end
	end

	always@(posedge clk) begin
		if(RECEIVE_VALID && (RECEIVE_ADDRESS == 2) && (kind_work == 0))
			data_run <= RECEIVE_DATA[18:16] + 1;
	end

	assign SEND_DATA =  (SEND_ADDRESS == 13'h000)? 64'h0033010100000008 :
//						(SEND_ADDRESS == 1)? {45'h0, data_run[2:0], 16'h0} :
						(SEND_ADDRESS == 13'h001)? {46'h0, 2'h0, 16'h0} :
						(SEND_ADDRESS == 13'h100)? 64'h0033010100000008 :
						(SEND_ADDRESS == 13'h101)? {46'h0, 2'h1, 16'h0} : 64'h0;

endmodule

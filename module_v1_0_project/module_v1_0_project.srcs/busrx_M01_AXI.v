module module_v1_0_M00_AXI #
(
	parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,// Base address of targeted slave
	parameter integer C_M_AXI_BURST_LEN	= 256,// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_ID_WIDTH	= 1,// Thread ID Width
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,// Width of Address Bus
	parameter integer C_M_AXI_DATA_WIDTH	= 32,// Width of Data Bus
	parameter integer C_M_AXI_AWUSER_WIDTH	= 1,// Width of User Write Address Bus
	parameter integer C_M_AXI_WUSER_WIDTH	= 1// Width of User Write Data Bus
) 
(
	output wire[31:0] data0,
	output wire[31:0] data1,
	output wire[31:0] data2,
		
	input wire  M_AXI_ACLK,// Global Clock Signal.
	input wire  M_AXI_ARESETN,// Global Reset Singal. This Signal is Active Low
	
	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,// Master Interface Write Address ID
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,// Master Interface Write Address
	output wire [7 : 0] M_AXI_AWLEN,// Burst length. The burst length gives the exact number of transfers in a burst
	output wire [2 : 0] M_AXI_AWSIZE,// Burst size. This signal indicates the size of each transfer in the burst
	output wire [1 : 0] M_AXI_AWBURST,
	output wire  M_AXI_AWLOCK,
	output wire [3 : 0] M_AXI_AWCACHE,
	output wire [2 : 0] M_AXI_AWPROT,
	output wire [3 : 0] M_AXI_AWQOS,// Quality of Service, QoS identifier sent for each write transaction.
	output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
	output wire  M_AXI_AWVALID,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,// Master Interface Write Data.
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
	output wire  M_AXI_WLAST,// Write last. This signal indicates the last transfer in a write burst.
	output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,// Optional User-defined signal in the write data channel.
	output wire  M_AXI_WVALID,
	output wire  M_AXI_BREADY,
	input wire  M_AXI_WREADY,
	input wire  M_AXI_AWREADY,
	input wire  M_AXI_BVALID,

	input[31:0]mst_data,
	input[31:0]mst_data_time,
	input[31:0]mst_address,
	input[1:0] mst_prior_dg,
	input mst_start,
	input mst_start_time,
	output reg mst_stop
);

	function integer clogb2 (input integer bit_depth);
	begin
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
			bit_depth = bit_depth >> 1;
	end
	endfunction

	reg mst_exec_state;
	reg[1:0] state;
	reg[1:0] prior;

	assign M_AXI_AWID	= 'b0;
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	assign M_AXI_AWCACHE	= 4'b0011;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WUSER	= 'b0;
	assign M_AXI_BREADY	= 1;
	assign M_AXI_AWLEN	= 0;
	assign M_AXI_AWADDR	= (state == 2)? mst_address + 32'h0 : mst_address + 32'h014 + {28'h0, prior, 2'h0};
	assign M_AXI_WDATA = (state == 2)? mst_data_time : mst_data;
	assign M_AXI_AWVALID = mst_exec_state;
	assign M_AXI_WLAST = mst_exec_state;
	assign M_AXI_WVALID = mst_exec_state;

	always@(posedge M_AXI_ACLK) begin
		if(!M_AXI_ARESETN) begin
			mst_exec_state <= 0;
			mst_stop <= 0;
			state <= 0;
		end else begin
			case(state)
				0: begin
					mst_stop <= 0;
					if(mst_start) begin
						prior <= mst_prior_dg;
						mst_exec_state <= 1;
						//M_AXI_AWADDR <= mst_address + 32'h014;
						//M_AXI_WDATA <= mst_data;
						state <= 1;
					end else if(mst_start_time) begin
						mst_exec_state <= 1;
						// M_AXI_AWADDR <= mst_address;
						// M_AXI_WDATA <= mst_data_time;
						state <= 2;
					end
				end
				1: begin
					if(M_AXI_WREADY) begin
						mst_exec_state <= 0;
						state <= 3;
					end
				end
				2: begin
					if(M_AXI_WREADY) begin
						mst_exec_state <= 0;
						state <= 3;
					end
				end
				3: begin
					mst_stop <= 1;
					state <= 0;
				end
			endcase
		end
	end

endmodule
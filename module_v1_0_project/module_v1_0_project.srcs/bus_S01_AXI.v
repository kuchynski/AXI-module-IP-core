module module_v1_0_S01_AXI #
(
	parameter integer C_S_AXI_DATA_WIDTH	= 64,// Width of S_AXI data bus
	parameter integer C_S_AXI_ADDR_WIDTH	= 32,// Width of S_AXI address bus
	parameter integer C_S_AXI_ID_WIDTH      = 2, // Thread ID Width
	parameter integer C_S_AXI_ARUSER_WIDTH	= 1,
	parameter integer C_S_AXI_AWUSER_WIDTH  = 1,
	parameter integer C_S_AXI_WUSER_WIDTH   = 8,
	parameter integer C_S_AXI_RUSER_WIDTH = 8,
	parameter integer C_S_AXI_BUSER_WIDTH = 1
)
(
	output reg irq_tx,
	output wire irq_rx,
	input[31:0] CHANGE_SLV_REG_NUMBER_WRITE,
	inout[31:0] CHANGE_SLV_REG_NUMBER_READ, 
	input CHANGE_SLV_REG_EVENT_WRITE,
	input CHANGE_SLV_REG_EVENT_READ,
	output[31:0] data_r0,
	output[31:0] data_r1,
	output[31:0] data_r2,
	output[31:0] data_r3,
	output[31:0] data_r4,
	output[31:0] data_r5,
	output[63:0] RECEIVE_DATA,
	output[12:0] RECEIVE_ADDRESS,
	input[63:0] SEND_DATA,
	output[12:0] SEND_ADDRESS,
	output RECEIVE_VALID,
	//input[1:0] priority,

	input wire  S_AXI_ACLK,// Global Clock Signal
	input wire  S_AXI_ARESETN,// Global Reset Signal. This Signal is Active LOW
	input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,// Write address (issued by master, acceped by Slave)
	input wire [2 : 0] S_AXI_AWPROT,
	input wire  S_AXI_AWVALID,
	output reg S_AXI_AWREADY, //write
	input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,// Write data (issued by master, acceped by Slave)
	input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
	input wire  S_AXI_WVALID,
	output reg  S_AXI_WREADY, //write
	output wire [1 : 0] S_AXI_BRESP,
	input wire S_AXI_WLAST, //write
	output reg  S_AXI_BVALID, //write
	input wire  S_AXI_BREADY,
	input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,// Read address (issued by master, acceped by Slave)
	input wire [2 : 0] S_AXI_ARPROT,
	input wire  S_AXI_ARVALID,
	output wire  S_AXI_ARREADY,//read
	output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,// Read data (issued by slave)
	output wire [1 : 0] S_AXI_RRESP,
	output reg  S_AXI_RVALID, //read
	output wire  S_AXI_RLAST, //read
	input wire  S_AXI_RREADY,
	input wire [7:0] S_AXI_AWLEN,
	input wire [7:0] S_AXI_ARLEN,
	output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
	output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID
);

	assign S_AXI_BRESP	= 0;
	assign S_AXI_RRESP  = 0;
	assign S_AXI_BID	= 'b0;
	assign S_AXI_RID	= 'b0;
	assign S_AXI_ARREADY = !S_AXI_RVALID;  
	assign S_AXI_RLAST = S_AXI_RVALID && (axi_araddr >= axi_araddr_end);

	reg[12:0]  axi_araddr, axi_araddr_end;
	reg[12:0]  axi_awaddr;
	reg[7:0]   axi_len;
	reg[1:0] state_rx; 
	wire valid_qword = S_AXI_WVALID && S_AXI_WREADY;

	always @(posedge S_AXI_ACLK) begin
		if(!S_AXI_ARESETN) begin
			axi_awaddr      <= 0;
			S_AXI_AWREADY   <= 0;
			S_AXI_WREADY    <= 0;
			S_AXI_BVALID    <= 0;
			axi_araddr      <= 0;
			axi_araddr_end  <= 0;
			S_AXI_RVALID    <= 0;
			axi_len         <= 0;
			state_rx <= 0;
		end else begin
			case(state_rx)
				0: begin
					axi_awaddr <= 0;
					S_AXI_WREADY <= 0;
					S_AXI_BVALID <= 0;
					if(S_AXI_AWVALID) begin
						S_AXI_AWREADY <= 1;
						axi_len <= S_AXI_AWLEN;
						state_rx <= 1;
					end else begin
						S_AXI_AWREADY <= 0;
					end
				end
				1: begin
					S_AXI_AWREADY <= 0;
					S_AXI_WREADY <= 1;
					if(valid_qword)
						axi_awaddr <= axi_awaddr + 1;
					S_AXI_BVALID <= (S_AXI_WLAST && S_AXI_WREADY)? 1 : 0;
					if(S_AXI_BVALID && S_AXI_BREADY)
						state_rx <= 2;
				end
				2: begin
					S_AXI_WREADY <= 0;
					S_AXI_BVALID <= 0;
					state_rx <= 3;
				end
				3:
					state_rx <= 0;
				default :
					state_rx <= 0;
			endcase

			if(S_AXI_ARVALID && !S_AXI_RVALID) begin
				axi_araddr      <= S_AXI_ARADDR[15:3];
				axi_araddr_end  <= S_AXI_ARADDR[15:3] +  {5'h0, S_AXI_ARLEN};
				S_AXI_RVALID    <=  1;
			end else begin
				if(S_AXI_RVALID && S_AXI_RREADY)
					axi_araddr  <= axi_araddr + 1;
				if(S_AXI_RLAST)
					S_AXI_RVALID <= 0;
			end
		end
	end

	reg[2:0] set_irq_rx;
	reg[63:0] data_0, data_1, data_2;

	assign data_r0 = data_0[31:0];
	assign data_r1 = data_0[63:32];
	assign data_r2 = data_1[31:0];
	assign data_r3 = data_1[63:32];
	assign data_r4 = data_2[31:0];
	assign data_r5 = data_2[63:32];

	assign irq_rx = (set_irq_rx)? 1 : 0;
	assign S_AXI_RDATA = SEND_DATA;
	assign SEND_ADDRESS = axi_araddr;
	assign RECEIVE_DATA = S_AXI_WDATA;
	assign RECEIVE_ADDRESS = axi_awaddr;
	assign RECEIVE_VALID = valid_qword;

	always@(posedge S_AXI_ACLK) begin
		if(!S_AXI_ARESETN) begin
			set_irq_rx <= 0;
		end else begin
			if(valid_qword && (axi_awaddr == 0))
				data_0 <= S_AXI_WDATA;
			if(valid_qword && (axi_awaddr == 1))
				data_1 <= S_AXI_WDATA;
			if(valid_qword && (axi_awaddr == 2))
				data_2 <= S_AXI_WDATA;
 
			set_irq_rx[0] <= ((state_rx == 3) && (data_0[31:16] == 16'h0500))? 1 : 0; // timeout
			set_irq_rx[1] <= ((state_rx == 3) && (data_0[31:16] == 16'h0F00))? 1 : 0; // receive dg
			set_irq_rx[2] <= (CHANGE_SLV_REG_EVENT_WRITE && (CHANGE_SLV_REG_NUMBER_WRITE == 1))? 1 : 0; // start from ARM
		end
	end

endmodule

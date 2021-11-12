module module_v1_0 #(
	// Parameters of Axi Slave Bus Interface S00_AXI
	parameter integer C_S00_AXI_DATA_WIDTH	= 32,
	parameter integer C_S00_AXI_ADDR_WIDTH    = 8,

	parameter integer C_S01_AXI_DATA_WIDTH	= 64,
	parameter integer C_S01_AXI_ADDR_WIDTH    = 32,
	parameter integer C_S01_AXI_BURST_LEN	= 16,
	parameter integer C_S01_AXI_ID_WIDTH = 2,
	parameter integer C_S01_AXI_ARUSER_WIDTH = 1,
	parameter integer C_S01_AXI_AWUSER_WIDTH = 1,
	parameter integer C_S01_AXI_WUSER_WIDTH = 8,
	parameter integer C_S01_AXI_RUSER_WIDTH = 8,
	parameter integer C_S01_AXI_BUSER_WIDTH = 1,

	// Parameters of Axi Master Bus Interface M00_AXI
	parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
	parameter integer C_M00_AXI_BURST_LEN	= 16,
	parameter integer C_M00_AXI_ID_WIDTH	= 1,
	parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M00_AXI_DATA_WIDTH	= 32,
	parameter integer C_M00_AXI_AWUSER_WIDTH	= 1,
	parameter integer C_M00_AXI_ARUSER_WIDTH	= 1,
	parameter integer C_M00_AXI_WUSER_WIDTH	= 1,
	parameter integer C_M00_AXI_RUSER_WIDTH	= 1,
	parameter integer C_M00_AXI_BUSER_WIDTH	= 1
)
(
	output wire IRQ,
	input wire TIMER_IRQ,
	input wire[63:0] time_value,

	input wire  s00_axi_aclk,
	input wire  s00_axi_aresetn,
	input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
	input wire [2 : 0] s00_axi_awprot,
	input wire  s00_axi_awvalid,
	output wire  s00_axi_awready,
	input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
	input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
	input wire  s00_axi_wvalid,
	output wire  s00_axi_wready,
	output wire [1 : 0] s00_axi_bresp,
	output wire  s00_axi_bvalid,
	input wire  s00_axi_bready,
	input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
	input wire [7 : 0] s00_axi_arprot,
	input wire  s00_axi_arvalid,
	output wire  s00_axi_arready,
	output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
	output wire [1 : 0] s00_axi_rresp,
	output wire  s00_axi_rvalid,
	input wire  s00_axi_rready,

	input wire  s01_axi_aclk,
	input wire  s01_axi_aresetn,
	input wire [C_S01_AXI_ADDR_WIDTH-1 : 0] s01_axi_awaddr,
	input wire [2 : 0] s01_axi_awprot,
	input wire  s01_axi_awvalid,
	output wire  s01_axi_awready,
	input wire [C_S01_AXI_DATA_WIDTH-1 : 0] s01_axi_wdata,
	input wire [(C_S01_AXI_DATA_WIDTH/8)-1 : 0] s01_axi_wstrb,
	input wire  s01_axi_wvalid,
	output wire  s01_axi_wready,
	output wire [1 : 0] s01_axi_bresp,
	input wire s01_axi_wlast,
	output wire  s01_axi_bvalid,
	input wire  s01_axi_bready,
	input wire [C_S01_AXI_ADDR_WIDTH-1 : 0] s01_axi_araddr,
	input wire [7 : 0] s01_axi_arprot,
	input wire  s01_axi_arvalid,
	output wire [C_S01_AXI_DATA_WIDTH-1 : 0] s01_axi_rdata,
	output wire [1 : 0] s01_axi_rresp,
	output wire  s01_axi_rvalid,
	output wire  s01_axi_arready,	
	output wire s01_axi_rlast,
	input wire  s01_axi_rready,
	input wire [7 : 0] s01_axi_arlen,
	input wire [7 : 0] s01_axi_awlen,
	input wire [C_S01_AXI_ID_WIDTH-1 : 0] s01_axi_awid,
	output wire [C_S01_AXI_ID_WIDTH-1 : 0] s01_axi_bid,
	input wire [C_S01_AXI_ID_WIDTH-1 : 0] s01_axi_arid,
	output wire [C_S01_AXI_ID_WIDTH-1 : 0] s01_axi_rid,

	// Ports of Axi Master Bus Interface M00_AXI
	input wire  m00_axi_aclk,
	input wire  m00_axi_aresetn,
	output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
	output wire [7 : 0] m00_axi_awlen,
	output wire [2 : 0] m00_axi_awsize,
	output wire [1 : 0] m00_axi_awburst,
	output wire  m00_axi_awlock,
	output wire [3 : 0] m00_axi_awcache,
	output wire [2 : 0] m00_axi_awprot,
	output wire [3 : 0] m00_axi_awqos,
	output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser,
	output wire  m00_axi_awvalid,
	input wire  m00_axi_awready,
	output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
	output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
	output wire  m00_axi_wlast,
	output wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser,
	output wire  m00_axi_wvalid,
	input wire  m00_axi_wready,
	input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
	input wire [1 : 0] m00_axi_bresp,
	input wire [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser,
	input wire  m00_axi_bvalid,
	output wire  m00_axi_bready,
	output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
	output wire [7 : 0] m00_axi_arlen,
	output wire [2 : 0] m00_axi_arsize,
	output wire [1 : 0] m00_axi_arburst,
	output wire  m00_axi_arlock,
	output wire [3 : 0] m00_axi_arcache,
	output wire [2 : 0] m00_axi_arprot,
	output wire [3 : 0] m00_axi_arqos,
	output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser,
	output wire  m00_axi_arvalid,
	input wire  m00_axi_arready,
	input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
	input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
	input wire [1 : 0] m00_axi_rresp,
	input wire  m00_axi_rlast,
	input wire [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser,
	input wire  m00_axi_rvalid,
	output wire  m00_axi_rready
);

	wire[31:0] SLV_REG0, SLV_REG1, SLV_REG2, SLV_REG3, SLV_REG4, SLV_REG5, SLV_REG6, SLV_REG7, SLV_REG8, IRQ_DATA;
	wire[1:0] kind_work = SLV_REG3[3:2];
	wire priority = SLV_REG3[1:0];
	wire[31:0] datac0, datac1, datac2, datac3, datac4, datac5, datac6, datac7;
	wire[31:0] data0, data1, data2;
	wire[31:0] data_r0, data_r1, data_r2, data_r3;
	wire[31:0] CHANGE_SLV_REG_NUMBER_WRITE, CHANGE_SLV_REG_NUMBER_READ;
	wire CHANGE_SLV_REG_EVENT_WRITE, CHANGE_SLV_REG_EVENT_READ;
	wire[31:0] mst_data, mst_data_time;
	wire[1:0] mst_prior_dg;
	wire[31:0] mst_address;
	wire mst_start, mst_start_time, mst_stop;
	wire irq_tx, irq_rx;
	wire[63:0] RECEIVE_DATA, SEND_DATA;
	wire[12:0] RECEIVE_ADDRESS, SEND_ADDRESS;
	wire RECEIVE_VALID;

	cpu_module # (
	) cpu_module_v1_0_S00_AXI_inst (
		.clk(s00_axi_aclk),
		.rstn(s00_axi_aresetn),

		.TIMER_IRQ(TIMER_IRQ),
		.time_value(time_value),
		.ADDRESS_MY(SLV_REG0),
		.ADDRESS_SCHEDULER(SLV_REG1),
		.irq_tx(irq_tx), 
		.irq_rx(irq_rx),
		.kind_work(kind_work),
		.RECEIVE_DATA(RECEIVE_DATA),
		.RECEIVE_ADDRESS(RECEIVE_ADDRESS),
		.SEND_DATA(SEND_DATA),
		.SEND_ADDRESS(SEND_ADDRESS),
		.RECEIVE_VALID(RECEIVE_VALID),

		.mst_data(mst_data),
		.mst_prior_dg(mst_prior_dg),
		.mst_data_time(mst_data_time),
		.mst_address(mst_address),
		.mst_start(mst_start),
		.mst_start_time(mst_start_time),
		.mst_stop(mst_stop)
	);

// Instantiation of Axi Bus Interface S00_AXI
	module_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) module_v1_0_S00_AXI_inst (
		.CHANGE_SLV_REG_EVENT_WRITE(CHANGE_SLV_REG_EVENT_WRITE),
		.CHANGE_SLV_REG_EVENT_READ(CHANGE_SLV_REG_EVENT_READ),
		.CHANGE_SLV_REG_NUMBER_WRITE(CHANGE_SLV_REG_NUMBER_WRITE),
		.CHANGE_SLV_REG_NUMBER_READ(CHANGE_SLV_REG_NUMBER_READ),
		.IRQ_DATA(IRQ_DATA),
		.SLV_REG0(SLV_REG0), 
		.SLV_REG1(SLV_REG1),
		.SLV_REG2(SLV_REG2),
		.SLV_REG3(SLV_REG3),
		.SLV_REG4(SLV_REG4),
		.MST_REG0(datac0),
		.MST_REG1(datac1),
		.MST_REG2(datac2),
		.MST_REG3(datac3),
		.MST_REG4(datac4),
		.MST_REG5(datac5),
		.MST_REG6(datac6),

		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

// Instantiation of Axi Bus Interface S01_AXI
		module_v1_0_S01_AXI # ( 
			.C_S_AXI_DATA_WIDTH(C_S01_AXI_DATA_WIDTH),
			.C_S_AXI_ADDR_WIDTH(C_S01_AXI_ADDR_WIDTH),
			.C_S_AXI_ID_WIDTH(C_S01_AXI_ID_WIDTH),
			.C_S_AXI_ARUSER_WIDTH(C_S01_AXI_ARUSER_WIDTH),
			.C_S_AXI_AWUSER_WIDTH(C_S01_AXI_AWUSER_WIDTH),
			.C_S_AXI_WUSER_WIDTH(C_S01_AXI_WUSER_WIDTH),
			.C_S_AXI_RUSER_WIDTH(C_S01_AXI_RUSER_WIDTH),
			.C_S_AXI_BUSER_WIDTH(C_S01_AXI_BUSER_WIDTH)
		) module_v1_0_S01_AXI_inst (

			.RECEIVE_DATA(RECEIVE_DATA),
			.RECEIVE_ADDRESS(RECEIVE_ADDRESS),
			.SEND_DATA(SEND_DATA),
			.SEND_ADDRESS(SEND_ADDRESS),
			.RECEIVE_VALID(RECEIVE_VALID),
			.irq_tx(irq_tx), 
			.irq_rx(irq_rx),
			.data_r0(datac1),
			.data_r1(datac2),
			.data_r2(datac3),
			.data_r3(datac4),
			.data_r4(datac5),
			.data_r5(datac6),
			.CHANGE_SLV_REG_EVENT_WRITE(CHANGE_SLV_REG_EVENT_WRITE),
			.CHANGE_SLV_REG_EVENT_READ(CHANGE_SLV_REG_EVENT_READ),
			.CHANGE_SLV_REG_NUMBER_WRITE(CHANGE_SLV_REG_NUMBER_WRITE),
			.CHANGE_SLV_REG_NUMBER_READ(CHANGE_SLV_REG_NUMBER_READ),

			.S_AXI_ACLK(s01_axi_aclk),
			.S_AXI_ARESETN(s01_axi_aresetn),
			.S_AXI_AWADDR(s01_axi_awaddr),
			.S_AXI_AWPROT(s01_axi_awprot),
			.S_AXI_AWVALID(s01_axi_awvalid),
			.S_AXI_AWREADY(s01_axi_awready),
			.S_AXI_WDATA(s01_axi_wdata),
			.S_AXI_WSTRB(s01_axi_wstrb),
			.S_AXI_WVALID(s01_axi_wvalid),
			.S_AXI_WREADY(s01_axi_wready),
			.S_AXI_BRESP(s01_axi_bresp),
			.S_AXI_WLAST(s01_axi_wlast),
			.S_AXI_BVALID(s01_axi_bvalid),
			.S_AXI_BREADY(s01_axi_bready),
			.S_AXI_ARADDR(s01_axi_araddr),
			.S_AXI_ARPROT(s01_axi_arprot),
			.S_AXI_ARVALID(s01_axi_arvalid),
			.S_AXI_RDATA(s01_axi_rdata),
			.S_AXI_RRESP(s01_axi_rresp),
			.S_AXI_RVALID(s01_axi_rvalid),
			.S_AXI_ARREADY(s01_axi_arready),
			.S_AXI_RLAST(s01_axi_rlast),
			.S_AXI_RREADY(s01_axi_rready),
			.S_AXI_ARLEN(s01_axi_arlen),
			.S_AXI_AWLEN(s01_axi_awlen),
			.S_AXI_BID(s01_axi_bid),
			.S_AXI_RID(s01_axi_rid)
		);

// Instantiation of Axi Bus Interface M00_AXI
	module_v1_0_M00_AXI # ( 
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M00_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M00_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M_AXI_AWUSER_WIDTH(C_M00_AXI_AWUSER_WIDTH),
		.C_M_AXI_WUSER_WIDTH(C_M00_AXI_WUSER_WIDTH)
	) module_v1_0_M00_AXI_inst (

		.mst_data(mst_data),
		.mst_prior_dg(mst_prior_dg),
		.mst_data_time(mst_data_time),
		.mst_address(mst_address),
		.mst_start(mst_start),
		.mst_start_time(mst_start_time),
		.mst_stop(mst_stop),
		.data0(data_r0),
		.data1(data_r1),
		.data2(data_r2),

		.M_AXI_ACLK(m00_axi_aclk),
		.M_AXI_ARESETN(m00_axi_aresetn),
		.M_AXI_AWID(m00_axi_awid),
		.M_AXI_AWADDR(m00_axi_awaddr),
		.M_AXI_AWLEN(m00_axi_awlen),
		.M_AXI_AWSIZE(m00_axi_awsize),
		.M_AXI_AWBURST(m00_axi_awburst),
		.M_AXI_AWLOCK(m00_axi_awlock),
		.M_AXI_AWCACHE(m00_axi_awcache),
		.M_AXI_AWPROT(m00_axi_awprot),
		.M_AXI_AWQOS(m00_axi_awqos),
		.M_AXI_AWUSER(m00_axi_awuser),
		.M_AXI_AWVALID(m00_axi_awvalid),
		.M_AXI_AWREADY(m00_axi_awready),
		.M_AXI_WDATA(m00_axi_wdata),
		.M_AXI_WSTRB(m00_axi_wstrb),
		.M_AXI_WLAST(m00_axi_wlast),
		.M_AXI_WUSER(m00_axi_wuser),
		.M_AXI_WVALID(m00_axi_wvalid),
		.M_AXI_WREADY(m00_axi_wready),
		.M_AXI_BVALID(m00_axi_bvalid),
		.M_AXI_BREADY(m00_axi_bready)
	);

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2026 13:39:34
// Design Name: 
// Module Name: top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module
(
    input clk,
    input areset,

  //axi write address
    input  [31:0] s_axi_awaddr,
    input         s_axi_awvalid,
    output        s_axi_awready,

  // axi write data
    input  [31:0] s_axi_wdata,
    input  [3:0]  s_axi_wstrb,
    input         s_axi_wvalid,
    output        s_axi_wready,

    // axi write response
    output [1:0]  s_axi_bresp,
    output        s_axi_bvalid,
    input         s_axi_bready,
// axi read address
    input  [31:0] s_axi_araddr,
    input         s_axi_arvalid,
    output        s_axi_arready,

// axi read data
    output [31:0] s_axi_rdata,
    output        s_axi_rvalid,
    output [1:0]  s_axi_rrespo,
    input         s_axi_rready
);

wire [127:0] plaintext;
wire [127:0] key;

wire [127:0] data_reg;
wire [127:0] key_reg;

wire [127:0] ciphertext;

wire [31:0] control;
wire [31:0] status;

wire key_valid;
wire data_valid;

wire load_pipeline;
wire pipeline_done;

wire start;
wire busy;
wire done;

  
  
  // axi instantiation
AXI u_axi
(
    .clk(clk),
    .areset(areset),

    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),

    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),

    .s_axi_rdata(s_axi_rdata),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rrespo(s_axi_rrespo),
    .s_axi_rready(s_axi_rready),

    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),

    .ciphertext(ciphertext),

    .key(key),
    .plaintext(plaintext),

    .status(status),

    .control(control),

    .key_valid(key_valid),
    .data_valid(data_valid),

    .aes_done(done)
);
  // aes controller 
aes_controller u_controller
(
    .clk(clk),
    .areset(areset),

    .control(control),

    .plaintext(plaintext),
    .key(key),

    .data_valid(data_valid),
    .key_valid(key_valid),

    .pipeline_done(pipeline_done),

    .ciphertext(ciphertext),

    .load_pipeline(load_pipeline),

    .data_reg(data_reg),
    .key_reg(key_reg),

    .status(status),

    .start(start),
    .busy(busy),
    .done(done)
);
// aes data path
aes_datapth u_datapath
(
    .clk(clk),
    .areset(areset),

    .load_pipeline(load_pipeline),

    .key(key_reg),
    .plaintext(data_reg),

    .ciphertext(ciphertext),

    .done(pipeline_done)
);

endmodule
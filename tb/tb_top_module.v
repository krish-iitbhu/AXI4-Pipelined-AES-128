`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2026 14:26:09
// Design Name: 
// Module Name: tb_top_module
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


module tb_top_module;

reg clk;
reg areset;
// write address
reg  [31:0] s_axi_awaddr;
reg         s_axi_awvalid;
wire        s_axi_awready;
// write data
reg  [31:0] s_axi_wdata;
reg  [3:0]  s_axi_wstrb;
reg         s_axi_wvalid;
wire        s_axi_wready;
// write response
wire [1:0]  s_axi_bresp;
wire        s_axi_bvalid;
reg         s_axi_bready;
// read address
reg  [31:0] s_axi_araddr;
reg         s_axi_arvalid;
wire        s_axi_arready;
// read data
wire [31:0] s_axi_rdata;
wire        s_axi_rvalid;
wire [1:0]  s_axi_rrespo;
reg         s_axi_rready;


top_module DUT
(
    .clk(clk),
    .areset(areset),

    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),

    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),

    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),

    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),

    .s_axi_rdata(s_axi_rdata),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rrespo(s_axi_rrespo),
    .s_axi_rready(s_axi_rready)
);
 // for clock 
always #5 clk = ~clk;

// axi write 
task axi_write;

input [31:0] addr;
input [31:0] data;

begin

@(posedge clk);

s_axi_awaddr  <= addr;
s_axi_awvalid <= 1;

s_axi_wdata   <= data;
s_axi_wstrb   <= 4'hF;
s_axi_wvalid  <= 1;

wait(s_axi_awready && s_axi_wready);

@(posedge clk);

s_axi_awvalid <= 0;
s_axi_wvalid  <= 0;
s_axi_bready  <= 1;
wait(s_axi_bvalid);

@(posedge clk);
s_axi_bready <= 0;

end
endtask

// axi read task
task axi_read;

input [31:0] addr;

begin

@(posedge clk);

s_axi_araddr  <= addr;
s_axi_arvalid <= 1;

wait(s_axi_arready);

@(posedge clk);
s_axi_arvalid <= 0;
s_axi_rready <= 1;
wait(s_axi_rvalid);

$display("READ [%h] = %h",addr,s_axi_rdata);

@(posedge clk);

s_axi_rready <= 0;

end

endtask

// values testing 
initial
begin

clk=0;
areset=1;

s_axi_awaddr=0;
s_axi_awvalid=0;
s_axi_wdata=0;
s_axi_wvalid=0;
s_axi_wstrb=4'hF;
s_axi_bready=0;

s_axi_araddr=0;
s_axi_arvalid=0;
s_axi_rready=0;

#30;
areset=0;
// aes start 
axi_write(32'h00,32'h00000001);

// plain text
axi_write(32'h08,32'h00112233);
axi_write(32'h0C,32'h44556677);
axi_write(32'h10,32'h8899AABB);
axi_write(32'h14,32'hCCDDEEFF);

// key 

axi_write(32'h18,32'h00010203);
axi_write(32'h1C,32'h04050607);
axi_write(32'h20,32'h08090A0B);
axi_write(32'h24,32'h0C0D0E0F);

repeat(30)
begin :READ_STATUS

axi_read(32'h04);

if(s_axi_rdata==32'h00000004)
begin
    $display("AES DONE");
    disable READ_STATUS;
end

end


// read cipher text
axi_read(32'h28);
axi_read(32'h2C);
axi_read(32'h30);
axi_read(32'h34);

#100;

$finish;

end

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2026 21:34:05
// Design Name: 
// Module Name: AXI
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




module AXI
(
    input              clk,
    input              areset,

    
    // AXI Write Address Channel

     input      [31:0]  s_axi_awaddr,
  input              s_axi_awvalid,
   output reg         s_axi_awready,
    
    // AXI read Address Channel
     input      [31:0]  s_axi_araddr,
  input              s_axi_arvalid,
   output reg         s_axi_arready,
   
    // AXI Write Data Channel   
    input      [31:0]  s_axi_wdata,
     input      [3:0]   s_axi_wstrb,
      input              s_axi_wvalid,
       output reg         s_axi_wready,

    // AXII READ DATA CHANNEL
    output reg[31:0] s_axi_rdata,
    output reg       s_axi_rvalid,
     output reg [1:0]       s_axi_rrespo,
    input            s_axi_rready,
    
    // AXI Write Response Channel
    output reg [1:0]   s_axi_bresp,
    output reg         s_axi_bvalid,
    input              s_axi_bready,

// aes interface 
input [127:0] ciphertext,
output [127:0] key,
output [127:0] plaintext,
input [31:0] status,
output reg[31:0] control,
output  key_valid,
output  data_valid,
input aes_done
);
//// status 
//parameter busy=32'h00000001;
//parameter done=32'h00000004;
//parameter idle=32'h00000002;
// parameter for response 
localparam OKAY   = 2'b00;
localparam SLVERR = 2'b10;
localparam DECERR = 2'b11;

  // Output to Register File
   
     reg [31:0]  wr_addr;
     reg [31:0]  wr_data;
     reg         wr_en;
    
    // read registers
      reg [31:0]  r_addr;
      
      
reg aw_done;
reg w_done;

always @(posedge clk or posedge areset)
begin

  if(areset)
    begin
        s_axi_awready <= 1'b1;
        s_axi_wready  <= 1'b1;
        s_axi_bvalid  <= 1'b0;
        s_axi_bresp   <= 2'b00;
        aw_done <= 1'b0;
        w_done  <= 1'b0;
        wr_en   <= 1'b0;
        wr_addr <= 32'd0;
        wr_data <= 32'd0;
    end

    else
    begin

        wr_en <= 1'b0;

        // address Handshake
        if(s_axi_awready && s_axi_awvalid&&!aw_done)
        begin
            wr_addr <= s_axi_awaddr;
            aw_done <= 1'b1;
            s_axi_awready <= 1'b0;
        end
        // data Handshake
        if(s_axi_wready && s_axi_wvalid&&!w_done)
        begin
            wr_data <= s_axi_wdata;
            w_done  <= 1'b1;
            s_axi_wready <= 1'b0;
        end

        // Complete Write
        if(aw_done && w_done && !s_axi_bvalid)
        begin
            wr_en <= 1'b1;

            s_axi_bvalid <= 1'b1;
            s_axi_bresp  <= OKAY;     // OKAY
        end

        // Response Accepted
 
        if(s_axi_bvalid && s_axi_bready)
        begin
            s_axi_bvalid <= 1'b0;

            aw_done <= 1'b0;
            w_done  <= 1'b0;

            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
        end

    end

end


reg [31:0] reg_data_out[0:3];
reg [31:0] reg_key[0:3];
reg data_get, key_get;
always @(posedge clk or posedge areset)
begin
if(areset)
begin
reg_data_out[0]<=0;
reg_data_out[1]<=0;
reg_data_out[2]<=0;
reg_data_out[3]<=0;
control <= 0;
key_get  <= 0;
data_get <= 0;
reg_key[0]<=0;
reg_key[1]<=0;
reg_key[2]<=0;
reg_key[3]<=0;
end
else
begin
if( wr_en)
begin
case(wr_addr)
8'h00:
begin
control<= wr_data;
end

8'h08:
begin
if(s_axi_wstrb[0])
    reg_data_out[0][7:0] <= wr_data[7:0];

if(s_axi_wstrb[1])
    reg_data_out[0][15:8] <= wr_data[15:8];

if(s_axi_wstrb[2])
    reg_data_out[0][23:16] <= wr_data[23:16];

if(s_axi_wstrb[3])
    reg_data_out[0][31:24] <= wr_data[31:24];
    
end

8'h0c:
begin
if(s_axi_wstrb[0])
    reg_data_out[1][7:0] <= wr_data[7:0];

if(s_axi_wstrb[1])
    reg_data_out[1][15:8] <= wr_data[15:8];

if(s_axi_wstrb[2])
    reg_data_out[1][23:16] <= wr_data[23:16];

if(s_axi_wstrb[3])
    reg_data_out[1][31:24] <= wr_data[31:24];
end

8'h10:
begin
 if(s_axi_wstrb[2])
    reg_data_out[2][7:0] <= wr_data[7:0];

if(s_axi_wstrb[2])
    reg_data_out[2][15:8] <= wr_data[15:8];

if(s_axi_wstrb[2])
    reg_data_out[2][23:16] <= wr_data[23:16];

if(s_axi_wstrb[2])
    reg_data_out[2][31:24] <= wr_data[31:24];
end

8'h14:
begin
if(s_axi_wstrb[0])
    reg_data_out[3][7:0] <= wr_data[7:0];

if(s_axi_wstrb[1])
    reg_data_out[3][15:8] <= wr_data[15:8];

if(s_axi_wstrb[2])
    reg_data_out[3][23:16] <= wr_data[23:16];

if(s_axi_wstrb[3])
    reg_data_out[3][31:24] <= wr_data[31:24];
    if(s_axi_wstrb==4'b1111)
    data_get<=1;
    
end

8'h18:
begin
 reg_key[0]<= wr_data;
end

8'h1c:
begin
 reg_key[1]<= wr_data;
end

8'h20:
begin
 reg_key[2]<= wr_data;
end

8'h24:
begin
 reg_key[3]<= wr_data;
 key_get<=1;
end

default:
begin
    s_axi_bresp <= DECERR;
end
endcase
end
end
end

assign plaintext={reg_data_out[0],reg_data_out[1],reg_data_out[2],reg_data_out[3]};
assign key={reg_key[0],reg_key[1],reg_key[2],reg_key[3]};
assign key_valid=key_get;
assign data_valid=data_get;


reg ar_done;
reg rd_done;
reg [31:0] reg_data_in[0:3];
always@(posedge clk or posedge areset)
begin
if(areset)
begin
s_axi_arready<=1;
s_axi_rdata<=0;
s_axi_rvalid<=0;
end

else
begin

if(s_axi_arready&&s_axi_arvalid)
begin
  r_addr<= s_axi_araddr;
  ar_done<=1'b1;   
            s_axi_arready <= 1'b0;
  end
  
  if(ar_done)
  begin
  case(r_addr)
  8'h04:
  begin
  s_axi_rdata<=status;
  s_axi_rrespo<=OKAY;
  end

  8'h28:
  begin
  s_axi_rdata<=reg_data_in[0];
  s_axi_rrespo<=OKAY;
  end
  
  8'h2c:
  begin
  s_axi_rdata<=reg_data_in[1];
  s_axi_rrespo<=OKAY;
  end
  
  8'h30:
  begin
  s_axi_rdata<=reg_data_in[2];
  s_axi_rrespo<=OKAY;
  end
  
  8'h34:
  begin
  s_axi_rdata<=reg_data_in[3];
  s_axi_rrespo<=OKAY;
  end
  
  default:
begin
    s_axi_rrespo<=DECERR;
end
  endcase
 rd_done<=1;
 s_axi_rvalid<=1;
  end
  
  
   
  if(rd_done&& s_axi_rvalid&& s_axi_rready)
  begin
  s_axi_rvalid<=0;
  s_axi_arready<=1;
  rd_done<=0;
  ar_done<=0;
  end
  
  
end
end


always@(posedge clk)
begin
if(aes_done)
begin
reg_data_in[0]<=ciphertext[127-:32];
reg_data_in[1]<=ciphertext[95-:32];
reg_data_in[2]<=ciphertext[63-:32];
reg_data_in[3]<=ciphertext[31-:32];
end

else
reg_data_in[0]<=0;
reg_data_in[1]<=0;
reg_data_in[2]<=0;
reg_data_in[3]<=0;
end
endmodule

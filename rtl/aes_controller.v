`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 14:33:52
// Design Name: 
// Module Name: aes_controller
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

`timescale 1ns / 1ps

module aes_controller
(
    input               clk,
    input               areset,

    // from AXI
    input  [31:0]       control,
    input  [127:0]      plaintext,
    input  [127:0]      key,
    input               data_valid,
    input               key_valid,

    // from AES Pipeline
    input               pipeline_done,
    input  [127:0]      ciphertext,

    // to AES pipeline
    output reg          load_pipeline,
    output reg [127:0]  data_reg,
    output reg [127:0]  key_reg,

    // to AXI
    output reg [31:0]   status,
    output              start,
    output              busy,
    output              done
);
// STATES 
localparam IDLE = 2'd0;
localparam LOAD = 2'd1;
localparam RUN  = 2'd2;
localparam DONE = 2'd3;

reg [1:0] ps, ns;

always @(posedge clk or posedge areset)
begin
    if(areset)
        ps <= IDLE;
    else
        ps <= ns;
end


// neaxt state logic
always @(*)
begin
 case(ps)

 IDLE:
    begin
        if(control[0])          // Start bit
            ns = LOAD;
    end

  LOAD:
      begin
        if(data_valid && key_valid)
          ns = RUN;
    end
    
   RUN:
    begin
        if(pipeline_done)
            ns = DONE;
    end
    
 DONE:
  begin
  ns = IDLE;
   end
   
   default:
   ns = IDLE;
    endcase

end

// REG LOGICS AND OUTPUT ACCORDING TO IT 
always @(posedge clk or posedge areset)
begin

    if(areset)
    begin
 data_reg       <= 128'd0;
 key_reg        <= 128'd0; 
 load_pipeline  <= 1'b0;
 status         <= 32'd2;      
    end
    

    else
    begin
        // Default every clock
        load_pipeline <= 1'b0;
 case(ps)
 IDLE:
 begin
    status <= 32'h00000002;// idle
 end

 LOAD:      
  begin
if(data_valid)
 data_reg <= plaintext;
 if(key_valid)
 key_reg <= key;
  load_pipeline <= 1'b1;
    status <= 32'h00000002;  // idle
   end

 RUN:
  begin
 load_pipeline <= 1'b0;
 status <= 32'h00000001;   // run
  end

DONE :
begin
status <= 32'h00000004; // done  
 end
 
  endcase
    end
end

// OUTPUT FLAGS
assign start = (ps == LOAD);
assign busy  = (ps == RUN);
assign done  = (ps == DONE);

endmodule
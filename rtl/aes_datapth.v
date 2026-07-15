`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 20:16:50
// Design Name: 
// Module Name: aes_datapth
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


module aes_datapth
#(parameter Nr=10,
  parameter Nk=4,
  parameter data_width=128,
  parameter key_size=128)
(
input clk,
input areset,

input load_pipeline,
input [127:0] key,
input [127:0] plaintext,

output [127:0] ciphertext,
output  done


    );
wire [(Nr+1)*key_size-1:0]round_key;
reg [data_width-1:0]state[0:Nr];
wire [key_size-1:0] round_each_key[0:Nr];

      // key expansion will done combinationally 
      
      
    key_expansion u_key_expansion(key,round_key);
    
assign round_each_key[0]  = round_key[1407:1280];
assign round_each_key[1]  = round_key[1279:1152];
assign round_each_key[2]  = round_key[1151:1024];
assign round_each_key[3]  = round_key[1023:896];
assign round_each_key[4]  = round_key[895:768];
assign round_each_key[5]  = round_key[767:640];
assign round_each_key[6]  = round_key[639:512];
assign round_each_key[7]  = round_key[511:384];
assign round_each_key[8]  = round_key[383:256];
assign round_each_key[9]  = round_key[255:128];
assign round_each_key[10] = round_key[127:0]; 
   
    
    //multiply by 3
    function [7:0] mb3; 
	input [7:0] x;
	begin 
			
			mb3 = mb2(x) ^ x;
	end 
    endfunction

    // multiplication of 2 
    function [7:0] mb2;
    input [7:0] a;
    begin
    if(a[7]==1)
     mb2=(a<<1)^8'h1b;
    else
    mb2=a<<1;  
    end
   endfunction

    
    // function of add round key 
    function [127:0] addround_key;
    input [127:0]in;
    input [127:0]key;
    
    addround_key=in^key;
    endfunction
    
    reg [10:0] valid;

always @(posedge clk or posedge areset)
begin
    if(areset)
    begin
        valid <= 11'b0;
    end

    else if(load_pipeline)
    begin
        valid[0]  <= 1'b1;
        valid[1]  <= 1'b0;
        valid[2]  <= 1'b0;
        valid[3]  <= 1'b0;
        valid[4]  <= 1'b0;
        valid[5]  <= 1'b0;
        valid[6]  <= 1'b0;
        valid[7]  <= 1'b0;
        valid[8]  <= 1'b0;
        valid[9]  <= 1'b0;
        valid[10] <= 1'b0;
    end

    else
    begin
        valid[0]  <= 1'b0;
        valid[1]  <= valid[0];
        valid[2]  <= valid[1];
        valid[3]  <= valid[2];
        valid[4]  <= valid[3];
        valid[5]  <= valid[4];
        valid[6]  <= valid[5];
        valid[7]  <= valid[6];
        valid[8]  <= valid[7];
        valid[9]  <= valid[8];
        valid[10] <= valid[9];
    end
end

assign done = valid[10];
    
    
    // all rounds are pipelined 
    // round 0 
   
    always@(posedge clk or posedge areset)
    begin
    if(areset)
    begin
    state[0]<=0;
    
   
    end
    else if(load_pipeline)
    begin
    state[0]<=addround_key(plaintext,round_each_key[0]);

    end
    end
    
   // variables  use for combinational part after round 0
   wire [7:0]sub_0 [0:15];
   wire [7:0] shf_0[0:15];
    wire [127:0]mix_0;
    genvar r0;
    
    generate
    for(r0=0;r0<16;r0=r0+1)
    begin:loop_s0
    s_box s(state[0][127-r0*8-:8],sub_0[r0]);
    end
    endgenerate
    
    generate 
    for(r0=0;r0<4;r0=r0+1)
    begin:loop_shf_0
    assign shf_0[4*r0]=sub_0[4*r0];
    assign shf_0[4*r0+1]=sub_0[(4*(r0+1))%16+1];
     assign shf_0[4*r0+2]=sub_0[(4*(r0+2))%16+2];
      assign shf_0[4*r0+3]=sub_0[(4*(r0+3))%16+3];
    end    
    endgenerate
    
    generate 
    for(r0=0;r0<4;r0=r0+1)
    begin:loop_m0  
assign mix_0[(127-r0*32)-:8] = mb2(shf_0[4*r0]) ^ mb3(shf_0[4*r0+1]) ^ shf_0[4*r0+2] ^ shf_0[4*r0+3];
assign mix_0[(119-r0*32)-:8] = shf_0[4*r0] ^ mb2(shf_0[4*r0+1]) ^ mb3(shf_0[4*r0+2]) ^ shf_0[4*r0+3];
assign mix_0[(111-r0*32)-:8] = shf_0[4*r0] ^ shf_0[4*r0+1] ^ mb2(shf_0[4*r0+2]) ^ mb3(shf_0[4*r0+3]);
assign mix_0[(103-r0*32)-:8] = mb3(shf_0[4*r0]) ^ shf_0[4*r0+1] ^ shf_0[4*r0+2] ^ mb2(shf_0[4*r0+3]);
 end
    endgenerate
    
    always@(posedge clk or posedge areset)
    begin
    if(areset)
    begin
  state[1]<=0;
 
    end
   else 
   state[1]<=addround_key(mix_0,round_each_key[1]);
    end
    
    
   //========================== ROUND 1 ==========================

wire [7:0] sub_1 [0:15];
wire [7:0] shf_1 [0:15];
wire [127:0] mix_1;
genvar r1;

generate
for(r1=0;r1<16;r1=r1+1)
begin:loop_s1
    s_box s(state[1][127-r1*8-:8],sub_1[r1]);
end
endgenerate

generate
for(r1=0;r1<4;r1=r1+1)
begin:loop_shf_1
assign shf_1[4*r1]   = sub_1[4*r1];
assign shf_1[4*r1+1] = sub_1[((r1+1)%4)*4+1];
assign shf_1[4*r1+2] = sub_1[((r1+2)%4)*4+2];
assign shf_1[4*r1+3] = sub_1[((r1+3)%4)*4+3];
end
endgenerate

generate
for(r1=0;r1<4;r1=r1+1)
begin:loop_m1
assign mix_1[(127-r1*32)-:8] = mb2(shf_1[4*r1]) ^ mb3(shf_1[4*r1+1]) ^ shf_1[4*r1+2] ^ shf_1[4*r1+3];
assign mix_1[(119-r1*32)-:8] = shf_1[4*r1] ^ mb2(shf_1[4*r1+1]) ^ mb3(shf_1[4*r1+2]) ^ shf_1[4*r1+3];
assign mix_1[(111-r1*32)-:8] = shf_1[4*r1] ^ shf_1[4*r1+1] ^ mb2(shf_1[4*r1+2]) ^ mb3(shf_1[4*r1+3]);
assign mix_1[(103-r1*32)-:8] = mb3(shf_1[4*r1]) ^ shf_1[4*r1+1] ^ shf_1[4*r1+2] ^ mb2(shf_1[4*r1+3]);
end
endgenerate

always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[2] <= 0;
    
    end
    else 
        state[2] <= addround_key(mix_1,round_each_key[2]);
end


//========================== ROUND 2 ==========================

wire [7:0] sub_2 [0:15];
wire [7:0] shf_2 [0:15];
wire [127:0] mix_2;
genvar r2;

generate
for(r2=0;r2<16;r2=r2+1)
begin:loop_s2
    s_box s(state[2][127-r2*8-:8],sub_2[r2]);
end
endgenerate

generate
for(r2=0;r2<4;r2=r2+1)
begin:loop_shf_2
assign shf_2[4*r2]   = sub_2[4*r2];
assign shf_2[4*r2+1] = sub_2[((r2+1)%4)*4+1];
assign shf_2[4*r2+2] = sub_2[((r2+2)%4)*4+2];
assign shf_2[4*r2+3] = sub_2[((r2+3)%4)*4+3];
end
endgenerate

generate
for(r2=0;r2<4;r2=r2+1)
begin:loop_m2
assign mix_2[(127-r2*32)-:8] = mb2(shf_2[4*r2]) ^ mb3(shf_2[4*r2+1]) ^ shf_2[4*r2+2] ^ shf_2[4*r2+3];
assign mix_2[(119-r2*32)-:8] = shf_2[4*r2] ^ mb2(shf_2[4*r2+1]) ^ mb3(shf_2[4*r2+2]) ^ shf_2[4*r2+3];
assign mix_2[(111-r2*32)-:8] = shf_2[4*r2] ^ shf_2[4*r2+1] ^ mb2(shf_2[4*r2+2]) ^ mb3(shf_2[4*r2+3]);
assign mix_2[(103-r2*32)-:8] = mb3(shf_2[4*r2]) ^ shf_2[4*r2+1] ^ shf_2[4*r2+2] ^ mb2(shf_2[4*r2+3]);
end
endgenerate

always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[3] <= 0;
      
    end
    else
        state[3] <= addround_key(mix_2,round_each_key[3]);
end


//========================== ROUND 3 ==========================

wire [7:0] sub_3 [0:15];
wire [7:0] shf_3 [0:15];
wire [127:0] mix_3;
wire [127:0] adrkey_3;
genvar r3;

generate
for(r3=0;r3<16;r3=r3+1)
begin:loop_s3
    s_box s(state[3][127-r3*8-:8],sub_3[r3]);
end
endgenerate

generate
for(r3=0;r3<4;r3=r3+1)
begin:loop_shf_3
assign shf_3[4*r3]   = sub_3[4*r3];
assign shf_3[4*r3+1] = sub_3[((r3+1)%4)*4+1];
assign shf_3[4*r3+2] = sub_3[((r3+2)%4)*4+2];
assign shf_3[4*r3+3] = sub_3[((r3+3)%4)*4+3];
end
endgenerate

generate
for(r3=0;r3<4;r3=r3+1)
begin:loop_m3
assign mix_3[(127-r3*32)-:8] = mb2(shf_3[4*r3]) ^ mb3(shf_3[4*r3+1]) ^ shf_3[4*r3+2] ^ shf_3[4*r3+3];
assign mix_3[(119-r3*32)-:8] = shf_3[4*r3] ^ mb2(shf_3[4*r3+1]) ^ mb3(shf_3[4*r3+2]) ^ shf_3[4*r3+3];
assign mix_3[(111-r3*32)-:8] = shf_3[4*r3] ^ shf_3[4*r3+1] ^ mb2(shf_3[4*r3+2]) ^ mb3(shf_3[4*r3+3]);
assign mix_3[(103-r3*32)-:8] = mb3(shf_3[4*r3]) ^ shf_3[4*r3+1] ^ shf_3[4*r3+2] ^ mb2(shf_3[4*r3+3]);
end
endgenerate

assign adrkey_3= addround_key(mix_3,round_each_key[4]) ;
always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[4] <= 0;
        
    end
    else 
        state[4] <= adrkey_3;
end


//========================== ROUND 4 ==========================

wire [7:0] sub_4 [0:15];
wire [7:0] shf_4 [0:15];
wire [127:0] mix_4;
wire [127:0] adrkey_4;
genvar r4;

generate
for(r4=0;r4<16;r4=r4+1)
begin:loop_s4
    s_box s(state[4][127-r4*8-:8],sub_4[r4]);
end
endgenerate

generate
for(r4=0;r4<4;r4=r4+1)
begin:loop_shf_4
assign shf_4[4*r4]   = sub_4[4*r4];
assign shf_4[4*r4+1] = sub_4[((r4+1)%4)*4+1];
assign shf_4[4*r4+2] = sub_4[((r4+2)%4)*4+2];
assign shf_4[4*r4+3] = sub_4[((r4+3)%4)*4+3];
end
endgenerate

generate
for(r4=0;r4<4;r4=r4+1)
begin:loop_m4
assign mix_4[(127-r4*32)-:8] = mb2(shf_4[4*r4]) ^ mb3(shf_4[4*r4+1]) ^ shf_4[4*r4+2] ^ shf_4[4*r4+3];
assign mix_4[(119-r4*32)-:8] = shf_4[4*r4] ^ mb2(shf_4[4*r4+1]) ^ mb3(shf_4[4*r4+2]) ^ shf_4[4*r4+3];
assign mix_4[(111-r4*32)-:8] = shf_4[4*r4] ^ shf_4[4*r4+1] ^ mb2(shf_4[4*r4+2]) ^ mb3(shf_4[4*r4+3]);
assign mix_4[(103-r4*32)-:8] = mb3(shf_4[4*r4]) ^ shf_4[4*r4+1] ^ shf_4[4*r4+2] ^ mb2(shf_4[4*r4+3]);
end
endgenerate


assign adrkey_4= addround_key(mix_4,round_each_key[5]) ;
always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[5] <= 0;
       
    end
    else 
        state[5] <= adrkey_4;
end


//========================== ROUND 5 ==========================

wire [7:0] sub_5 [0:15];
wire [7:0] shf_5 [0:15];
wire [127:0] mix_5;
wire [127:0] adrkey_5;
genvar r5;

generate
for(r5=0;r5<16;r5=r5+1)
begin:loop_s5
    s_box s(state[5][127-r5*8-:8],sub_5[r5]);
end
endgenerate

generate
for(r5=0;r5<4;r5=r5+1)
begin:loop_shf_5
assign shf_5[4*r5]   = sub_5[4*r5];
assign shf_5[4*r5+1] = sub_5[((r5+1)%4)*4+1];
assign shf_5[4*r5+2] = sub_5[((r5+2)%4)*4+2];
assign shf_5[4*r5+3] = sub_5[((r5+3)%4)*4+3];
end
endgenerate

generate
for(r5=0;r5<4;r5=r5+1)
begin:loop_m5
assign mix_5[(127-r5*32)-:8] = mb2(shf_5[4*r5]) ^ mb3(shf_5[4*r5+1]) ^ shf_5[4*r5+2] ^ shf_5[4*r5+3];
assign mix_5[(119-r5*32)-:8] = shf_5[4*r5] ^ mb2(shf_5[4*r5+1]) ^ mb3(shf_5[4*r5+2]) ^ shf_5[4*r5+3];
assign mix_5[(111-r5*32)-:8] = shf_5[4*r5] ^ shf_5[4*r5+1] ^ mb2(shf_5[4*r5+2]) ^ mb3(shf_5[4*r5+3]);
assign mix_5[(103-r5*32)-:8] = mb3(shf_5[4*r5]) ^ shf_5[4*r5+1] ^ shf_5[4*r5+2] ^ mb2(shf_5[4*r5+3]);
end
endgenerate

assign adrkey_5= addround_key(mix_5,round_each_key[6]) ;

always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[6] <= 0;
        
    end
    else 
        state[6] <= adrkey_5;
end


//========================== ROUND 6 ==========================

wire [7:0] sub_6 [0:15];
wire [7:0] shf_6 [0:15];
wire [127:0] mix_6;
wire [127:0] adrkey_6;
genvar r6;

generate
for(r6=0;r6<16;r6=r6+1)
begin:loop_s6
    s_box s(state[6][127-r6*8-:8],sub_6[r6]);
end
endgenerate

generate
for(r6=0;r6<4;r6=r6+1)
begin:loop_shf_6
assign shf_6[4*r6]   = sub_6[4*r6];
assign shf_6[4*r6+1] = sub_6[((r6+1)%4)*4+1];
assign shf_6[4*r6+2] = sub_6[((r6+2)%4)*4+2];
assign shf_6[4*r6+3] = sub_6[((r6+3)%4)*4+3];
end
endgenerate

generate
for(r6=0;r6<4;r6=r6+1)
begin:loop_m6
assign mix_6[(127-r6*32)-:8] = mb2(shf_6[4*r6]) ^ mb3(shf_6[4*r6+1]) ^ shf_6[4*r6+2] ^ shf_6[4*r6+3];
assign mix_6[(119-r6*32)-:8] = shf_6[4*r6] ^ mb2(shf_6[4*r6+1]) ^ mb3(shf_6[4*r6+2]) ^ shf_6[4*r6+3];
assign mix_6[(111-r6*32)-:8] = shf_6[4*r6] ^ shf_6[4*r6+1] ^ mb2(shf_6[4*r6+2]) ^ mb3(shf_6[4*r6+3]);
assign mix_6[(103-r6*32)-:8] = mb3(shf_6[4*r6]) ^ shf_6[4*r6+1] ^ shf_6[4*r6+2] ^ mb2(shf_6[4*r6+3]);
end
endgenerate


assign adrkey_6= addround_key(mix_6,round_each_key[7]) ;
always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[7] <= 0;
        
    end
    else 
        state[7] <= adrkey_6;
end



//========================== ROUND 7 ==========================

wire [7:0] sub_7 [0:15];
wire [7:0] shf_7 [0:15];
wire [127:0] mix_7;
wire [127:0] adrkey_7;
genvar r7;

generate
for(r7=0;r7<16;r7=r7+1)
begin:loop_s7
    s_box s(state[7][127-r7*8-:8],sub_7[r7]);
end
endgenerate

generate
for(r7=0;r7<4;r7=r7+1)
begin:loop_shf_7
assign shf_7[4*r7]   = sub_7[4*r7];
assign shf_7[4*r7+1] = sub_7[((r7+1)%4)*4+1];
assign shf_7[4*r7+2] = sub_7[((r7+2)%4)*4+2];
assign shf_7[4*r7+3] = sub_7[((r7+3)%4)*4+3];
end
endgenerate

generate
for(r7=0;r7<4;r7=r7+1)
begin:loop_m7
assign mix_7[(127-r7*32)-:8] = mb2(shf_7[4*r7]) ^ mb3(shf_7[4*r7+1]) ^ shf_7[4*r7+2] ^ shf_7[4*r7+3];
assign mix_7[(119-r7*32)-:8] = shf_7[4*r7] ^ mb2(shf_7[4*r7+1]) ^ mb3(shf_7[4*r7+2]) ^ shf_7[4*r7+3];
assign mix_7[(111-r7*32)-:8] = shf_7[4*r7] ^ shf_7[4*r7+1] ^ mb2(shf_7[4*r7+2]) ^ mb3(shf_7[4*r7+3]);
assign mix_7[(103-r7*32)-:8] = mb3(shf_7[4*r7]) ^ shf_7[4*r7+1] ^ shf_7[4*r7+2] ^ mb2(shf_7[4*r7+3]);
end
endgenerate


assign adrkey_7= addround_key(mix_7,round_each_key[8]) ;
always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[8] <= 0;
    
    end
    else 
        state[8] <= adrkey_7;
end


//========================== ROUND 8 ==========================

wire [7:0] sub_8 [0:15];
wire [7:0] shf_8 [0:15];
wire [127:0] mix_8;
wire [127:0] adrkey_8;
genvar r8;

generate
for(r8=0;r8<16;r8=r8+1)
begin:loop_s8
    s_box s(state[8][127-r8*8-:8],sub_8[r8]);
end
endgenerate

generate
for(r8=0;r8<4;r8=r8+1)
begin:loop_shf_8
assign shf_8[4*r8]   = sub_8[4*r8];
assign shf_8[4*r8+1] = sub_8[((r8+1)%4)*4+1];
assign shf_8[4*r8+2] = sub_8[((r8+2)%4)*4+2];
assign shf_8[4*r8+3] = sub_8[((r8+3)%4)*4+3];
end
endgenerate

generate
for(r8=0;r8<4;r8=r8+1)
begin:loop_m8
assign mix_8[(127-r8*32)-:8] = mb2(shf_8[4*r8]) ^ mb3(shf_8[4*r8+1]) ^ shf_8[4*r8+2] ^ shf_8[4*r8+3];
assign mix_8[(119-r8*32)-:8] = shf_8[4*r8] ^ mb2(shf_8[4*r8+1]) ^ mb3(shf_8[4*r8+2]) ^ shf_8[4*r8+3];
assign mix_8[(111-r8*32)-:8] = shf_8[4*r8] ^ shf_8[4*r8+1] ^ mb2(shf_8[4*r8+2]) ^ mb3(shf_8[4*r8+3]);
assign mix_8[(103-r8*32)-:8] = mb3(shf_8[4*r8]) ^ shf_8[4*r8+1] ^ shf_8[4*r8+2] ^ mb2(shf_8[4*r8+3]);
end
endgenerate

assign adrkey_8= addround_key(mix_8,round_each_key[9]) ;
always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[9] <= 0;
    
    end
    else 
        state[9] <= adrkey_8;
end


//========================== ROUND 9 ==========================

wire [7:0] sub_9 [0:15];
wire [7:0] shf_9 [0:15];
wire [127:0] mix_9;
wire [127:0] adrkey_9;
genvar r9;

generate
for(r9=0;r9<16;r9=r9+1)
begin:loop_s9
    s_box s(state[9][127-r9*8-:8],sub_9[r9]);
end
endgenerate

generate
for(r9=0;r9<4;r9=r9+1)
begin:loop_shf_9
assign shf_9[4*r9]   = sub_9[4*r9];
assign shf_9[4*r9+1] = sub_9[((r9+1)%4)*4+1];
assign shf_9[4*r9+2] = sub_9[((r9+2)%4)*4+2];
assign shf_9[4*r9+3] = sub_9[((r9+3)%4)*4+3];
end
endgenerate


assign mix_9={shf_9[0],shf_9[1],shf_9[2],shf_9[3],shf_9[4],shf_9[5],shf_9[6],shf_9[7],shf_9[8],shf_9[9],shf_9[10],shf_9[11],shf_9[12],shf_9[13],shf_9[14],shf_9[15]};

assign adrkey_9= addround_key(mix_9,round_each_key[10]) ;
always@(posedge clk or posedge areset)
begin
    if(areset)
    begin
        state[10] <= 0;
       
    end
    else 
    begin
        state[10] <= adrkey_9;
        
        end
end
assign ciphertext=state[10];

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2018 18:30:20
// Design Name: 
// Module Name: LZC_try2
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


module LZC_try2(
  output reg [4:0] lzcount,
  input [23:0] in);

reg all3,all2,all1; 
reg [2:0] y3,y2,y1,y0;
reg ab3,ac3,ef3,ab2,ac2,ef2,ab1,ac1,ef1,ab0,ac0,ef0;

assign a3=in[23];
assign b3=in[22];
assign c3=in[21];
assign d3=in[20];
assign e3=in[19];
assign f3=in[18];
assign a2=in[17];
assign b2=in[16];
assign c2=in[15];
assign d2=in[14];
assign e2=in[13];
assign f2=in[12];
assign a1=in[11];
assign b1=in[10];
assign c1=in[9];
assign d1=in[8];
assign e1=in[7];
assign f1=in[6];
assign a0=in[5];
assign b0=in[4];
assign c0=in[3];
assign d0=in[2];
assign e0=in[1];
assign f0=in[0];
  
always@(a3,b3,c3,d3,e3,f3)
begin 
    ab3=(~a3)&&(~b3);
    ac3=(~a3)&&(~c3);
    ef3=(~e3)&&(~f3);
    y3[2]=(ab3)&&((~c3)&&(~d3));
    y3[1]=(ab3)&&((c3||d3)||ef3);
    y3[0]=((ac3)&&(d3||((~e3)&&f3)))||((~a3)&&b3);
  
    if(y3==3'b110)
      all3=1'b1;
    else
      all3=1'b0;
end

always@(a2,b2,c2,d2,e2,f2)
begin
      ab2=(~a2)&&(~b2);
      ac2=(~a2)&&(~c2);
      ef2=(~e2)&&(~f2);
      y2[2]=(ab2)&&((~c2)&&(~d2));
      y2[1]=(ab2)&&((c2||d2)||ef2);
      y2[0]=((ac2)&&(d2||((~e2)&&f2)))||((~a2)&&b2);                 
  
      if(y2==3'b110)
        all2=1'b1;
      else
        all2=1'b0;
end

always@(a1,b1,c1,d1,e1,f1)
begin
      ab1=(~a1)&&(~b1);
      ac1=(~a1)&&(~c1);
      ef1=(~e1)&&(~f1);
      y1[2]=(ab1)&&((~c1)&&(~d1));
      y1[1]=(ab1)&&((c1||d1)||ef1);
      y1[0]=((ac1)&&(d1||((~e1)&&f1)))||((~a1)&&b1);                 
  
      if(y1==3'b110)
        all1=1'b1;
      else
        all1=1'b0;
    
end

always@(a0,b0,c0,d0,e0,f0)
begin
      ab0=(~a0)&&(~b0);
      ac0=(~a0)&&(~c0);
      ef0=(~e0)&&(~f0);
      y0[2]=(ab0)&&((~c0)&&(~d0));
      y0[1]=(ab0)&&((c0||d0)||ef0);
      y0[0]=((ac0)&&(d0||((~e0)&&f0)))||((~a0)&&b0);                 
end

always@(y3,y2,y1,y0,all3,all2,all1)
begin
    case({all3,all2,all1})
    3'b111: lzcount={2'b0,y3}+{2'b0,y2}+{2'b0,y1}+{2'b0,y0};
    3'b110: lzcount={2'b0,y3}+{2'b0,y2}+{2'b0,y1};
    3'b100: lzcount={2'b0,y3}+{2'b0,y2};
    3'b101: lzcount={2'b0,y3}+{2'b0,y2};
    3'b000: lzcount={2'b0,y3};
    3'b010: lzcount={2'b0,y3};
    3'b001: lzcount={2'b0,y3};
    3'b011: lzcount={2'b0,y3};
    default: lzcount=0;
    endcase
end

endmodule
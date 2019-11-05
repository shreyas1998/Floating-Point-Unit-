module BarrelShifter(
  output reg [23:0] out,
  output [30:0] thrown,
  //output reg g,r,s,
  input [23:0] in,
  input [4:0] shift,          //for 24 shifts
  input LR,fillbit,G_in);     //LR=0 for Left,1 for Right
  
  
  //variable declarations
  reg [23:0] L1,L2,L4,L8,L16,L1s,L2s,L4s,L8s,L16s;
  reg [23:0] R1,R2,R4,R8,R16,R1s,R2s,R4s,R8s,R16s;
  reg fillp1,s1;
  reg [1:0] fillp2,s2;
  reg [3:0] fillp4,s4;
  reg [7:0] fillp8,s8;
  reg [15:0] fillp16,s16;
  integer i;
  
  wire [30:0] shiftout;
  

always@(*)
begin
  if(fillbit==1'b0)
  begin
    fillp1=1'b0;
    fillp2=2'b00;
    fillp4=4'b0000;
    fillp8=8'b00000000;
    fillp16=16'b0000000000000000;
  end
  else
  begin
    fillp1=1'b1;
    fillp2=2'b11;
    fillp4=4'b1111;
    fillp8=8'b11111111;
    fillp16=16'b1111111111111111;
  end
end


always@(*)
begin
  L1s={in[22:0],G_in};
  if(shift[0]==1'b1)
    L1=L1s;
  else
    L1=in;

  L2s={L1[21:0],fillp2};
  if(shift[1]==1'b1)
    L2=L2s;
  else
    L2=L1;
  
  L4s={L2[19:0],fillp4};
  if(shift[2]==1'b1)
    L4=L4s;
  else
    L4=L2;
  
  L8s={L4[15:0],fillp8};
  if(shift[3]==1'b1)
    L8=L8s;
  else
    L8=L4;
  
  L16s={L8s[7:0],fillp16};
  if(shift[4]==1'b1)
    L16=L16s;
  else
    L16=L8;
end  

always@(*)
begin
  R1s={fillp1,in[23:1]};
  if(shift[0]==1'b1)
  begin
    s1=in[0];
    R1=R1s;
  end
  else
  begin
    s1=1'b0;
    R1=in;
  end

  R2s={fillp2,R1[23:2]};
  if(shift[1]==1'b1)
  begin
    s2=R1[1:0];
    R2=R2s;
  end
  else
  begin
    s2=2'b00;
    R2=R1;
  end

  R4s={fillp4,R2[23:4]};
  if(shift[2]==1'b1)
  begin
    s4=R2[3:0];
    R4=R4s;
  end
  else
  begin
    s4=4'b0000;
    R4=R2;
  end

  R8s={fillp8,R4[23:8]};
  if(shift[3]==1'b1)
  begin
    s8=R4[7:0];
    R8=R8s;
  end
  else
  begin
    s8=8'b00000000;
    R8=R4;
  end

  R16s={fillp16,R8[23:16]};
  if(shift[4]==1'b1)
  begin
    s16=R8[15:0];
    R16=R16s;
  end
  else
  begin
    s16=16'b0000000000000000;
    R16=R8;
  end
end  

always@(*)    //0 for Left,1 for Right
begin
  if(LR==1'b0)
    out=L16;
  else
    out=R16;
end

assign thrown={s16,s8,s4,s2,s1};
 
endmodule

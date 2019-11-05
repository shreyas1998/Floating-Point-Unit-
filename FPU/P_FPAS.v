//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module P_FPAS(
  output reg [31:0] Fieee,
  input [31:0] ieee1,ieee2,
  input opcode,clk);
    
//variable declarations
reg [24:0] tmp;
reg [23:0] num1_swapped,num2_swapped,num2_after,num2_shifted;
reg [23:0] sum,sum1,sum_in,sum_out,Fsum;
reg [7:0] diff,exp1_swapped,exp2_swapped,exp_out,Fexp;
reg [4:0] amount;
reg [1:0] status;
reg sign1_swapped,sign2_swapped,Fsign;
reg swap,same,fill,fill_1,carry,sum_neg,LR,nr,ns;    

//Module wires
wire [23:0] inLZC;
wire [30:0] thrown,thrown1;
wire [23:0] outbarrel,outbarrel1;
wire [23:0] inbarrel,inbarrel1;
wire [4:0] count,count1,lzcount;
wire fillbit,fillbit1,direction,direction1,G_in,G_in1;
wire g,r,s;

//Wires
wire [31:0] result;
wire [7:0] S2exp1_swapped;
wire [3:0] sign_cal;
wire S1sign1,S1sign2,S2same;

//Registers
reg [23:0] R0num1,R0num2,R1num1_swapped,R1num2_swapped;
reg [23:0] R2sum;
reg [7:0] R0exp1,R0exp2,R1exp1_swapped,R1diff,R2exp1_swapped;
reg R0sign1,R0sign2,R1sign1,R1sign2;
reg R1same,R1swap,R2same,R2carry,R2Fsign,R2g,R2r,R2s;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Reg0
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk) //Registers    
begin
    R0num1<={1'b1,ieee1[22:0]};
    R0num2<={1'b1,ieee2[22:0]};
    R0exp1<=ieee1[30:23];
    R0exp2<=ieee2[30:23];
    R0sign1<=ieee1[31];
    if(opcode==1'b0) //add 
      R0sign2<=ieee2[31];
    else             //sub
      R0sign2<=(~ieee2[31]);     
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Stage1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(R0exp1,R0exp2)
begin
  if(R0exp1>=R0exp2)
  begin
    diff=R0exp1-R0exp2;
    swap=1'b0;
  end
  else
  begin
    diff=R0exp2-R0exp1;
    swap=1'b1;
  end
end

always@(R0sign1,R0sign2)
begin
  if(R0sign1==R0sign2)
    same=1'b1;
  else
    same=1'b0;
end

always@(swap,R0sign1,R0sign2,R0exp1,R0exp2,R0num1,R0num2)
begin
  if(swap==1'b0)
  begin
    sign1_swapped=R0sign1;
    sign2_swapped=R0sign2;
    exp1_swapped=R0exp1;
    exp2_swapped=R0exp2;
    num1_swapped=R0num1;
    num2_after=R0num2;
  end
  else
  begin
    sign1_swapped=R0sign2;
    sign2_swapped=R0sign1;
    exp1_swapped=R0exp2;
    exp2_swapped=R0exp1;
    num1_swapped=R0num2;
    num2_after=R0num1;
  end
end

always@(num2_after,same)
begin
  if(same==1'b1)
    num2_swapped=num2_after;
  else
    num2_swapped=(~num2_after)+1;
end

assign S1sign1=R0sign1;
assign S1sign2=R0sign2;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Reg1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk) //Registers
begin
    R1same<=same;  
    R1swap<=swap;
    R1diff<=diff;
    R1sign1<=S1sign1;
    R1sign2<=S1sign2;
    R1exp1_swapped<=exp1_swapped;
    R1num1_swapped<=num1_swapped;
    R1num2_swapped<=num2_swapped;
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Stage2
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(R1same)
begin
  if(R1same==1'b1)
    fill=1'b0;
  else
    fill=1'b1;
end

assign inbarrel=R1num2_swapped;
assign count=R1diff[4:0];
assign fillbit=fill;
assign direction=1'b1;
assign G_in=1'b0;

BarrelShifter BS1(outbarrel,thrown,inbarrel,count,direction,fillbit,G_in);
FindGRS GRS1(g,r,s,count,thrown);

always@(outbarrel)
begin
  num2_shifted=outbarrel;
end

always@(R1num1_swapped,num2_shifted)
begin
  {carry,sum}=R1num1_swapped+num2_shifted;
end

always@(carry,sum,R1same)
begin
  if((R1same==1'b0)&&(sum[23]==1'b1)&&(carry==1'b0))
  begin
    sum_neg=1'b1;
    sum1=(~sum)+1;
  end
  else
  begin
    sum_neg=1'b0;
    sum1=sum;
  end
end

assign sign_cal={R1swap,sum_neg,R1sign1,R1sign2};

always@(sign_cal)
begin
  case(sign_cal)
  4'b0000: Fsign=0;
  4'b0001: Fsign=0;
  4'b0010: Fsign=1;
  4'b0011: Fsign=1;
  4'b0100: Fsign=0;
  4'b0101: Fsign=1;
  4'b0110: Fsign=0;
  4'b0111: Fsign=1;
  4'b1000: Fsign=0;
  4'b1001: Fsign=1;
  4'b1010: Fsign=0;
  4'b1011: Fsign=1;
  4'b1100: Fsign=0;
  4'b1101: Fsign=1;
  4'b1110: Fsign=0;
  4'b1111: Fsign=1;
  default: Fsign=0;
  endcase
end

assign S2same=R1same;
assign S2exp1_swapped=R1exp1_swapped;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Reg2
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk) //Registers
begin
    R2sum<=sum1;
    R2exp1_swapped<=S2exp1_swapped;
    R2same<=S2same;
    R2carry<=carry;
    R2Fsign<=Fsign;
    R2g<=g;
    R2r<=r;
    R2s<=s;
end
 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Stage3
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


assign inLZC=R2sum;

//Leading0Counter LZC1(lzcount,inLZC);
LZC_try2 LZC1(lzcount,inLZC);

always@(R2same,R2exp1_swapped,R2carry,lzcount)
begin
  if((R2same==1'b1)&&(R2carry==1'b1))
    exp_out=R2exp1_swapped+1;
  else if(R2same==1'b0)
    exp_out=R2exp1_swapped-lzcount;
  else
    exp_out=R2exp1_swapped;
end

always@(R2carry,R2sum,lzcount,R2same)
begin
  if((R2same==1'b1)&&(R2carry==1'b1))
  begin //Right Shift
    fill_1=1'b1;
    LR=1'b1; 
    amount=5'b00001;
    sum_in=R2sum;
    status=2'b01;
  end
  else if(R2same==1'b0)
  begin //Left Shift
    fill_1=1'b0;
    LR=1'b0;  
    amount=lzcount;
    sum_in=R2sum;
    status=2'b10;
  end
  else
  begin //No Shift
    fill_1=1'b0;
    LR=1'b0;  
    amount=5'b00000;
    sum_in=R2sum;
    status=2'b00;
  end
end

assign inbarrel1=sum_in;
assign count1=amount;
assign fillbit1=fill_1;
assign direction1=LR;
assign G_in1=R2g;

BarrelShifter BS2(outbarrel1,thrown1,inbarrel1,count1,direction1,fillbit1,G_in1);

always@(outbarrel1) 
begin
  sum_out=outbarrel1;
end


always@(R2g,R2r,R2s,count1,status,R2sum,exp_out,sum_out)
begin
  if(status==2'b01)
  begin
    nr=R2sum[0];
    ns=(R2g||R2sum[0])||R2s;
  end
  else if(status==2'b00)
  begin
    nr=R2g;
    ns=R2g||R2s;
  end
  else if(status==2'b10)
  begin
    if(count1==1)
    begin
      nr=R2r;
      ns=R2s;
    end
    else
    begin
      nr=1'b0;
      ns=1'b0;
    end
  end
  else
  begin
    nr=1'b0;
    ns=1'b0;
  end
  
  if((nr==1'b1)&&(ns==1'b1))
  begin
    tmp={1'b0,sum_out}+1;
    
    if(tmp[24]==1'b1)
    begin
      Fsum=tmp[24:1];
      Fexp=exp_out+1;
    end
    else
    begin
      Fsum=tmp[23:0];
      Fexp=exp_out;
    end
  end
  else
  begin
    Fsum=sum_out;
    Fexp=exp_out;
  end
end

assign result={R2Fsign,Fexp,Fsum[22:0]};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Stage3
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk) //Registers
begin
    Fieee<=result;
end


endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*module TB_P_FPAS;
  wire [31:0] Fieee;
  reg [31:0] ieee1,ieee2;
  reg opcode,clk;
  
  P_FPAS FPAS1(Fieee,ieee1,ieee2,opcode,clk);
  
initial #200 $finish;
initial 
begin
clk=0;
forever #5 clk=~clk;
end

initial 
fork
opcode=0;
ieee1=32'b01000001100100011110110010010001;
ieee2=32'b11000001011011000000000000000000;
#10 ieee1=32'b11000001000111000000000000000000;
#10 ieee2=32'b00111111000100000000000000000000;
#20 ieee1=32'b01000001000111000000000000000000;
#20 ieee2=32'b00111111000100000000000000000000;
join

endmodule*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

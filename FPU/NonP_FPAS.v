//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module NonP_FPAS(
  output reg [31:0] Fieee,
  input [31:0] ieee1,ieee2,
  input opcode,clk,rst,start);


/////CHANGE Leading Zero Counter Logic
  
  
//variable declarations
reg [24:0] tmp;
reg [23:0] num1_swapped,num2_swapped,num2_after,sum,sum1,sum_in,sum_out,Fsum;
reg [7:0] exp1_swapped,exp2_swapped,diff,exp_out,Fexp;
reg [4:0] amount;
reg [1:0] status;
reg sign1_swapped,sign2_swapped,carry,Fsign;
reg swap,fill,fill_1,sum_neg,LR,nr,ns,same;

wire [30:0] thrown,thrown1;
wire [23:0] outbarrel,outbarrel1;
wire [23:0] inbarrel,inbarrel1;
wire [4:0] count,count1;
wire fillbit,fillbit1,direction,direction1,G_in,G_in1;

wire [31:0] result;
wire [23:0] inLZC;
wire [4:0] lzcount;
wire [3:0] sign_cal;
wire g,r,s;

//Registers
reg [23:0] Rnum1,Rnum2,Rnum1_swapped,Rnum2_swapped,Rnum2_shifted;
reg [23:0] Rsum;
reg [7:0] Rexp1,Rexp2,Rdiff,Rexp1_swapped,Rexp2_swapped;
reg [4:0] Rlzcount;
reg Rsign1,Rsign2,Rswap,Rsign1_swapped,Rsign2_swapped,Rg,Rr,Rs,Rcarry,Rsum_neg,Rsame;

//Enables
reg en_S0,en_S1,en_S2,en_S3,en_S4;

//state 
reg [2:0] state;
parameter S0=3'b000,S1=3'b001,S2=3'b010,S3=3'b011,S4=3'b100;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk)
begin
  if(rst!=0)
    state<=S0;
  else
  begin
    case(state)
    S0: begin
        if(start==1)
          state<=S1;
        else
          state<=S0;
        end
    S1: state<=S2;
    S2: state<=S3;
    S3: state<=S4;
    S4: state<=S0;
    endcase
  end
end

always@(state)
begin 
  case(state)
  S0: begin
      en_S0=1;
      en_S1=0;
      en_S2=0;
      en_S3=0;
      en_S4=0;
      end
  S1: begin
      en_S0=0;
      en_S1=1;
      en_S2=0;
      en_S3=0;
      en_S4=0;
      end
  S2: begin
      en_S0=0;
      en_S1=0;
      en_S2=1;
      en_S3=0;
      en_S4=0;
      end
  S3: begin
      en_S0=0;
      en_S1=0;
      en_S2=0;
      en_S3=1;
      en_S4=0;
      end
  S4: begin
      en_S0=0;
      en_S1=0;
      en_S2=0;
      en_S3=0;
      en_S4=1;
      end
  default: begin
           en_S0=0;
           en_S1=0;
           en_S2=0;
           en_S3=0;
           en_S4=0;
           end
  endcase
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//S0
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk) //Registers    
begin
  if(en_S0==1'b1)
  begin
    Rnum1<={1'b1,ieee1[22:0]};
    Rnum2<={1'b1,ieee2[22:0]};
    Rexp1<=ieee1[30:23];
    Rexp2<=ieee2[30:23];
    Rsign1<=ieee1[31];
    if(opcode==1'b0) //add 
      Rsign2<=ieee2[31];
    else             //sub
      Rsign2<=(~ieee2[31]);
  end      
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//S1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(Rexp1,Rexp2)
begin
  if(Rexp1>=Rexp2)
  begin
    diff=Rexp1-Rexp2;
    swap=1'b0;
  end
  else
  begin
    diff=Rexp2-Rexp1;
    swap=1'b1;
  end
end

always@(Rsign1,Rsign2)
begin
  if(Rsign1==Rsign2)
    same=1'b1;
  else
    same=1'b0;
end

always@(swap,Rsign1,Rsign2,Rexp1,Rexp2,Rnum1,Rnum2)
begin
  if(swap==1'b0)
  begin
    sign1_swapped=Rsign1;
    sign2_swapped=Rsign2;
    exp1_swapped=Rexp1;
    exp2_swapped=Rexp2;
    num1_swapped=Rnum1;
    num2_after=Rnum2;
  end
  else
  begin
    sign1_swapped=Rsign2;
    sign2_swapped=Rsign1;
    exp1_swapped=Rexp2;
    exp2_swapped=Rexp1;
    num1_swapped=Rnum2;
    num2_after=Rnum1;
  end
end

always@(num2_after,same)
begin
  if(same==1'b1)
    num2_swapped=num2_after;
  else
    num2_swapped=(~num2_after)+1;
end

always@(posedge clk) //Registers
begin
  if(en_S1==1'b1)  
  begin 
    Rsame<=same;  
    Rswap<=swap;
    Rdiff<=diff;
    Rsign1_swapped<=sign1_swapped;
    Rsign2_swapped<=sign2_swapped;
    Rexp1_swapped<=exp1_swapped;
    Rexp2_swapped<=exp2_swapped;
    Rnum1_swapped<=num1_swapped;
    Rnum2_swapped<=num2_swapped;
  end
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//S2
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(Rsame)
begin
  if(Rsame==1'b1)
    fill=1'b0;
  else
    fill=1'b1;
end

assign inbarrel=Rnum2_swapped;
assign count=Rdiff[4:0];
assign fillbit=fill;
assign direction=1'b1;
assign G_in=1'b0;

BarrelShifter BS1(outbarrel,thrown,inbarrel,count,direction,fillbit,G_in);
FindGRS GRS1(g,r,s,count,thrown);

always@(posedge clk) //Registers
begin
  if(en_S2==1'b1)  
  begin 
    Rnum2_shifted<=outbarrel;
    Rg<=g;
    Rr<=r;
    Rs<=s;
  end
end 


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//S3
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(Rnum1_swapped,Rnum2_shifted)
begin
  {carry,sum}=Rnum1_swapped+Rnum2_shifted;
end

always@(carry,sum,Rsame)
begin
  if((Rsame==1'b0)&&(sum[23]==1'b1)&&(carry==1'b0))
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

assign inLZC=sum1;

//Leading0Counter LZC1(lzcount,inLZC);
LZC_try2 LZC1(lzcount,inLZC);

always@(posedge clk) //Registers
begin
  if(en_S3==1'b1)   
  begin
    Rcarry<=carry;
    Rsum<=sum1;
    Rsum_neg<=sum_neg;
    Rlzcount<=lzcount;
  end
end  


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//S4
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(Rcarry,Rsum,Rlzcount,Rsame)
begin
  if((Rsame==1'b1)&&(Rcarry==1'b1))
  begin //Right Shift
    fill_1=1'b1;
    LR=1'b1; 
    amount=5'b00001;
    sum_in=Rsum;
    status=2'b01;
  end
  else if(Rsame==1'b0)
  begin //Left Shift
    fill_1=1'b0;
    LR=1'b0;  
    amount=Rlzcount;
    sum_in=Rsum;
    status=2'b10;
  end
  else
  begin //No Shift
    fill_1=1'b0;
    LR=1'b0;  
    amount=5'b00000;
    sum_in=Rsum;
    status=2'b00;
  end
end

assign inbarrel1=sum_in;
assign count1=amount;
assign fillbit1=fill_1;
assign direction1=LR;
assign G_in1=Rg;

BarrelShifter BS2(outbarrel1,thrown1,inbarrel1,count1,direction1,fillbit1,G_in1);

always@(outbarrel1) /////////////////////
begin
  sum_out=outbarrel1;
end

assign sign_cal={Rswap,Rsum_neg,Rsign1,Rsign2};

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

always@(Rsame,Rexp1_swapped,Rcarry,Rlzcount)
begin
  if((Rsame==1'b1)&&(Rcarry==1'b1))
    exp_out=Rexp1_swapped+1;
  else if(Rsame==1'b0)
    exp_out=Rexp1_swapped-Rlzcount;
  else
    exp_out=Rexp1_swapped;
end

always@(Rg,Rr,Rs,count1,status,Rsum,exp_out,sum_out)
begin
  if(status==2'b01)
  begin
    nr=Rsum[0];
    ns=(Rg||Rsum[0])||Rs;
  end
  else if(status==2'b00)
  begin
    nr=Rg;
    ns=Rg||Rs;
  end
  else if(status==2'b10)
  begin
    if(count1==1)
    begin
      nr=Rr;
      ns=Rs;
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

assign result={Fsign,Fexp,Fsum[22:0]};

always@(posedge clk) //Registers
begin
  if(en_S4==1'b1)  
  begin
    Fieee<=result;
  end
end


endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*module TB_NonP_FPAS;
  wire [31:0] Fieee;
  reg [31:0] ieee1,ieee2;
  reg opcode,clk,rst,start;
  
  NonP_FPAS FPAS1(Fieee,ieee1,ieee2,opcode,clk,rst,start);
  
initial #200 $finish;
initial 
begin
clk=0;
forever #5 clk=~clk;
end

initial 
fork
rst=1;
start=0;
opcode=0;
ieee1=32'b01000001100100011110110010010001;
ieee2=32'b11000001011011000000000000000000;
#7 rst=0;
#7 start=1;
#50 ieee1=32'b11000001000111000000000000000000;
#50 ieee2=32'b00111111000100000000000000000000;
#100 ieee1=32'b01000001000111000000000000000000;
#100 ieee2=32'b00111111000100000000000000000000;
join

endmodule*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module P_FPM(
  output reg [31:0] Fieee,
  input [31:0] ieee1,ieee2,
  input clk);

//variable declarations
reg [47:0] Nmul;
reg [31:0] result;
reg [23:0] Fmul,Fnum;
reg [7:0] Fexp,Nexpsum;
reg shift,carry;

wire [47:0] mul,mul1;
wire [7:0] expsum,exp;
wire Fsign,error,nr,ns,p0;

//Registers
reg [47:0] R1mul;
reg [23:0] R0num1,R0num2;
reg [7:0] R0exp1,R0exp2,R1expsum;
reg R0sign1,R0sign2,R1error,R1shift,R1Fsign;

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
    R0sign2<=ieee2[31];     
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Stage1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign Fsign=R0sign1+R0sign2;
assign {error,expsum}=R0exp1+R0exp2-127;
assign mul=R0num1*R0num2;  

 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Reg1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk) //Registers    
begin
    R1mul<=mul;
    R1expsum<=expsum;
    R1error<=error;
    R1Fsign<=Fsign;
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Stage2
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(R1error,R1expsum,R1mul)
begin
  if(R1error==1'b0)
  begin  
    if(R1mul[47]==1)
    begin
      shift=1;  
      Nexpsum=R1expsum+1; 
      Nmul=R1mul;  
    end
    else
    begin
      shift=0;
      Nexpsum=R1expsum;
      Nmul={1'b0,R1mul[47:1]};
    end
  end
  else 
  begin
    shift=0;  
    Nexpsum=0; 
    Nmul=0;
  end  
end 

assign mul1=Nmul;
assign exp=Nexpsum;

FindRSP RSP1(nr,ns,p0,mul1[24:0],R1error,shift);

always@(R1error,R1Fsign,mul1,exp,nr,ns,p0)
begin
  if(R1error==1'b0)
  begin
    if(((nr&&p0)||(nr&&ns))==1'b0)
    begin
      Fexp=exp;
      Fnum=mul1[47:24];
    end
    else
    begin
      {carry,Fmul}=mul1[47:24] +1;
      if(carry==0)
      begin
        Fexp=exp;
        Fnum=Fmul[23:0];
      end
      else
      begin
        Fexp=exp+1;
        Fnum={1'b1,Fmul[23:1]};
      end
    end
    result={R1Fsign,Fexp,Fnum[22:0]};
  end
  else 
    result=0;
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Reg2
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk) //Registers
begin
    Fieee<=result;
end 
    

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*module TB_P_FPM;
  wire [31:0] Fieee;
  reg [31:0] ieee1,ieee2;
  reg clk;
  
  P_FPM FPM1(Fieee,ieee1,ieee2,clk);
  
initial #200 $finish;
initial 
begin
clk=0;
forever #5 clk=~clk;
end

initial 
fork
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



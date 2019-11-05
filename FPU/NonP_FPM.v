//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module NonP_FPM(
  output reg [31:0] Fieee,
  input [31:0] ieee1,ieee2,
  input clk,rst,start);

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
reg [47:0] Rmul;
reg [23:0] Rnum1,Rnum2;
reg [7:0] Rexp1,Rexp2,Rexpsum;
reg Rsign1,Rsign2,RFsign,Rerror;

//Enables
reg en_S0,en_S1,en_S2;

//state 
reg [1:0] state;
parameter S0=2'b00,S1=2'b01,S2=2'b10;

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
    S2: state<=S0;
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
      end
  S1: begin
      en_S0=0;
      en_S1=1;
      en_S2=0;
      end
  S2: begin
      en_S0=0;
      en_S1=0;
      en_S2=1;
      end
  default: begin
           en_S0=0;
           en_S1=0;
           en_S2=0;
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
    Rsign2<=ieee2[31];
  end      
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//S1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign Fsign=Rsign1+Rsign2;
assign {error,expsum}=Rexp1+Rexp2-127;
assign mul=Rnum1*Rnum2;  

always@(posedge clk) //Registers
begin
  if(en_S1==1'b1)
  begin
    RFsign<=Fsign;
    Rerror<=error;
    Rexpsum<=expsum;
    Rmul<=mul;
  end
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//S2
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(Rerror,Rexpsum,Rmul)
begin
  if(Rerror==1'b0)
  begin  
    if(Rmul[47]==1)
    begin
      shift=1;  
      Nexpsum=Rexpsum+1; 
      Nmul=Rmul;  
    end
    else
    begin
      shift=0;
      Nexpsum=Rexpsum;
      Nmul={1'b0,Rmul[47:1]};
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

FindRSP RSP1(nr,ns,p0,mul1[24:0],Rerror,shift);

always@(Rerror,Fsign,mul1,exp,nr,ns,p0)
begin
  if(Rerror==1'b0)
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
    result={Fsign,Fexp,Fnum[22:0]};
  end
  else 
    result=0;
end

always@(posedge clk) //Registers
begin
  if(en_S2==1'b1)
  begin
    Fieee<=result;
  end
end 
    

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*module TB_NonP_FPM;
  wire [31:0] Fieee;
  reg [31:0] ieee1,ieee2;
  reg clk,rst,start;
  
  NonP_FPM FPM1(Fieee,ieee1,ieee2,clk,rst,start);
  
initial #200 $finish;
initial 
begin
clk=0;
forever #5 clk=~clk;
end

initial 
begin
rst=1;
start=0;
ieee1=32'b01000001100100011110110010010001;
ieee2=32'b11000001011011000000000000000000;
#7 rst=0;
   start=1;
#23 ieee1=32'b11000001000111000000000000000000;
    ieee2=32'b00111111000100000000000000000000;
#30 ieee1=32'b01000001000111000000000000000000;
    ieee2=32'b00111111000100000000000000000000;
end

endmodule*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

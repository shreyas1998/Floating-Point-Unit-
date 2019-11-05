//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module NonP_FPD(
  output reg [31:0] Fieee,
  input [31:0] ieee1,ieee2,
  input clk,rst,start);


//variable declarations
reg [23:0] div;
reg [7:0] Fexp;

//Wires
wire [47:0] dividend,divisor;
wire [31:0] result;
wire [24:0] longQ;
wire [7:0] exp;
wire Fsign,done;

//Registers
reg [24:0] RlongQ;
reg [23:0] Rnum1,Rnum2;
reg [7:0] Rexp1,Rexp2,Rexp;
reg Rsign1,Rsign2,RFsign;

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
        if(start==1'b1)
          state<=S1;
        else
          state<=S0;
        end
    S1: begin
        if(done==1'b1)
          state<=S2;
        else
          state<=S1;
        end
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
assign exp=Rexp1-Rexp2+127;
  
assign dividend={Rnum1,24'd0};
assign divisor={24'd0,Rnum2};
  
NonResDivision NRD1(longQ,done,dividend,divisor,clk,en_S1);

always@(posedge clk) //Registers
begin
  if((en_S1==1'b1))////////////////////////////////////
  begin
    RFsign<=Fsign;
    Rexp<=exp;
    RlongQ<=longQ;
  end
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//S2
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(RlongQ,Rexp)
begin  
  if(RlongQ[24]==0)
  begin
    div=RlongQ[23:0];
    Fexp=Rexp-1;
  end
  else
  begin 
    div=RlongQ[24:1];
    Fexp=Rexp;
  end
end

assign result={RFsign,Fexp,div[22:0]};

always@(posedge clk) //Registers
begin
  if((en_S2==1'b1)&&(done==1'b1))
  begin
    Fieee<=result;
  end
end

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*module TB_NonP_FPD;
  wire [31:0] Fieee;
  reg [31:0] ieee1,ieee2;
  reg clk,rst,start;
  
  NonP_FPD FPD1(Fieee,ieee1,ieee2,clk,rst,start);
  
initial #2500 $finish;
initial 
begin
clk=0;
forever #5 clk=~clk;
end

initial 
fork
rst=1;
start=0;
ieee1=32'b01000001100100011110110010010001;
ieee2=32'b11000001011011000000000000000000;
#7 rst=0;
#7 start=1;
#530 ieee1=32'b11000001000111000000000000000000;
#530 ieee2=32'b00111111000100000000000000000000;
#1070 ieee1=32'b01000001000111000000000000000000;
#1070 ieee2=32'b00111111000100000000000000000000;
join

endmodule*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

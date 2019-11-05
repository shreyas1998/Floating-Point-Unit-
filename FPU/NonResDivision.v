module NonResDivision(
  output reg [24:0] longQ,
  output reg done,
  input [47:0] dividend,divisor,
  input clk,en);
  
//variables 
reg ready;
reg [6:0] count;
reg [95:0] longN,longD,tlongD,diff;
reg [47:0] Q,tQ;

initial done=1'b1;

always@(count)
begin
  if(count==0)
    done=1'b1;
  else
    done=1'b0;
end

always@(posedge clk)
begin
  if((done==1'b1)&&(en==1'b0))
    ready=1'b1;
  else if(en==1'b1)
  begin
    if(ready==1'b1)
    begin
    count=48;
    longN={48'd0,dividend};
    longD={1'b0,divisor,47'd0};
    tlongD=longD;
    Q=0;
    tQ=Q;
    ready=1'b0;
    end
    else
    begin
    if(done==1'b0)
    begin
      diff=longN-longD;
      //tQ=Q<<1;
      tQ={Q[46:0],1'b0};
      Q=tQ;
      
      if(diff[95]==1'b0)
      begin
        longN=diff;
        Q[0]=1'b1;
      end
      
      //tlongD=longD>>1;
      tlongD={1'b0,longD[95:1]};
      longD=tlongD;
      count=count-1;
    end
    end
  end
  else
    ready=1'b0;
end

always@(Q,done)
begin
  if(done==1'b1)
    longQ=Q[24:0];
  else
    longQ=0;
end

endmodule


/*module tb_NRD_f;
  wire [24:0] longQ;
  wire done;
  reg [47:0] dividend,divisor;
  reg clk,en;
  
  NonResDivision NRD1(longQ,done,dividend,divisor,clk,en);

initial #2500 $finish;
initial 
begin
clk=0;
forever #5 clk=~clk;
end

initial 
fork
en=1'b1;
dividend=48'b100100011110110010010001000000000000000000000000;
divisor=48'b000000000000000000000000111011000000000000000000;
join

endmodule*/
      
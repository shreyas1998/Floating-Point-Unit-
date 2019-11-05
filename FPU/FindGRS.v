module FindGRS(
  output reg g,r,s,
  input [4:0] shift,
  input [30:0] shiftout);
  
  integer i;

always@(*)
begin
  if(shift[4]==1'b1)
  begin
    g=shiftout[30];
    r=shiftout[29];
    s=1'b0;
    for(i=28;i>=0;i=i-1)
      s=s||shiftout[i];
  end
  else if(shift[4:3]==2'b01)
  begin
    g=shiftout[14];
    r=shiftout[13];
    s=1'b0;
    for(i=12;i>=0;i=i-1)
      s=s||shiftout[i];
  end
  else if(shift[4:2]==3'b001)
  begin
    g=shiftout[6];
    r=shiftout[5];
    s=1'b0;
    for(i=4;i>=0;i=i-1)
      s=s||shiftout[i];
  end
  else if(shift[4:1]==4'b0001)
  begin
    g=shiftout[2];
    r=shiftout[1];
    s=shiftout[0];
  end
  else if(shift[4:0]==5'b00001)
  begin
    g=shiftout[0];
    r=1'b0;
    s=1'b0;
  end
  else if(shift[4:0]==5'b00000)
  begin
    g=1'b0;
    r=1'b0;
    s=1'b0;
  end
  else 
  begin
    g=1'b0;
    r=1'b0;
    s=1'b0;
  end
end

endmodule 

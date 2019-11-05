module FindRSP(
  output reg nr,ns,p0,
  input [24:0] mul1,
  input Rerror,shift);

  reg g,r,s;
  integer i;
  
always@(*)
begin
  if(Rerror==1'b0)
  begin
    g=mul1[23];
    r=mul1[22];
    s=0;
	 	for(i=21;i>=0;i=i-1)
		  s=s||mul1[i];
		
		if(shift==0)
		begin
		  nr=r;
		  ns=s;
		end
		else
		begin
		  nr=g;
		  ns=s||r;
		end
		p0=mul1[24];
	end
	else
	begin
	  nr=0;
	  ns=0;
	  p0=0;
	end
end

endmodule

module SEG7_LUT	(oSEG,oSEG_DP,iDIG	);
input	[3:0]	iDIG;
output	[6:0]	oSEG;
output			oSEG_DP;
reg		[6:0]	oSEG;
reg				oSEG_DP;

always @(iDIG)
begin
		case(iDIG)
		4'h1: oSEG = 7'b1111001;	// ---t----
		4'h2: oSEG = 7'b0100100; 	// |	  |
		4'h3: oSEG = 7'b0110000; 	// lt	 rt
		4'h4: oSEG = 7'b0011001; 	// |	  |
		4'h5: oSEG = 7'b0010010; 	// ---m----
		4'h6: oSEG = 7'b0000010; 	// |	  |
		4'h7: oSEG = 7'b1111000; 	// lb	 rb
		4'h8: oSEG = 7'b0000000; 	// |	  |
		4'h9: oSEG = 7'b0011000; 	// ---b----
		4'ha: oSEG = 7'b0001000;
		4'hb: oSEG = 7'b0000011;
		4'hc: oSEG = 7'b1000110;
		4'hd: oSEG = 7'b0100001;
		4'he: oSEG = 7'b0000110;
		4'hf: oSEG = 7'b0001110;
		4'h0: oSEG = 7'b1000000;
		endcase
end

always @(iDIG)
begin
		case(iDIG)
		4'h1: oSEG_DP = 1'b0;
		4'h2: oSEG_DP = 1'b1;
		4'h3: oSEG_DP = 1'b0;
		4'h4: oSEG_DP = 1'b1;
		4'h5: oSEG_DP = 1'b0;
		4'h6: oSEG_DP = 1'b1;
		4'h7: oSEG_DP = 1'b0;
		4'h8: oSEG_DP = 1'b1;
		4'h9: oSEG_DP = 1'b0;
		4'ha: oSEG_DP = 1'b1;
		4'hb: oSEG_DP = 1'b0;
		4'hc: oSEG_DP = 1'b1;
		4'hd: oSEG_DP = 1'b0;
		4'he: oSEG_DP = 1'b1;
		4'hf: oSEG_DP = 1'b0;
		4'h0: oSEG_DP = 1'b1;
		endcase
end
endmodule

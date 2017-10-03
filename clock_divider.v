// File: clock_divider.v
// Description:
// Clockdivider

//-----Module Interface-----
module clock_divider(
clk,
rst,
clk_out
);

//-----Input Ports and Type-----
input clk, rst; // Default to "wire" type

//-----Output Ports and Type-----
output reg clk_out; // A register type

//-----Hardware Description Starts Here-----
reg [27:0] counter; 	// Counter incremented on each "clk" cycle
						// Counter is 28 bits wide, can count up to
						// 2^28 in decimal
						
// Some important comment. Read pdf file

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		counter <= 28'd0;	// 28'd0 means 28-bit number with decimal value 0
		clk_out <= 1'b0;	// 1'b0 means 1-bit number with binary value 0
	end
	// originally 25000000
	// When it starts to look static: 150000
	else if(counter==28'd150000) begin
		counter <= 28'd0;
		clk_out <= ~clk_out;
	end
	else begin
		counter <= counter +1;
	end
end

endmodule

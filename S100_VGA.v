`default_nettype none

module S100_VGA(
master_clk, // System CLK 50MHz
Hsync, // Hsync
Vsync, // Vsync
PLLLight,
rOUT, gOUT, bOUT // RGB
);
wire VGA_CLK, dividedClock_LK;
input wire master_clk;
output reg Hsync, Vsync;
output wire PLLLight;
output wire rOUT, gOUT, bOUT;

reg [7:0] frames;

wire display;
reg hDisp, vDisp;
reg [2:0] pixels;
reg [2:0] colorOut;

assign display = hDisp && vDisp;
assign {rOUT, gOUT, bOUT} = display ? colorOut: 3'b0;
VGA_CLOCK_PLL MCLK(master_clk, VGA_CLK, dividedClock_LK);

// VGA Constants
parameter VGA_H_VA = 800;
parameter VGA_H_FP = 40;
parameter VGA_H_SP = 128;
parameter VGA_H_BP = 88;

parameter VGA_V_VA = 600;
parameter VGA_V_FP = 1;
parameter VGA_V_SP = 4;
parameter VGA_V_BP = 23;

// VGA Timing Counters
reg [10:0] hCounter;
reg [9:0] vCounter;

initial hCounter = 0;
initial vCounter = 0;
initial pixels = 3'b100;
initial frames = 0;

always @(posedge VGA_CLK)
begin
	if (hCounter < (VGA_H_VA + VGA_H_FP + VGA_H_SP + VGA_H_BP))
	begin
		hCounter <= hCounter + 1;
	end
	else
		begin
		hCounter <= 0;
		if (vCounter < (VGA_V_VA + VGA_V_FP + VGA_V_SP + VGA_V_BP))
			vCounter <= vCounter + 1;
		else
			begin
			vCounter <= 0;
			frames <= frames + 1;
			if (frames == 0)
				pixels <= pixels + 1;
			end
		end
	colorOut <= pixels;
end

always @(*)
begin
	if (hCounter == 0)
		hDisp = 1;
	else if (hCounter == VGA_H_VA)
		hDisp = 0;
	else if (hCounter == (VGA_H_VA + VGA_H_FP))
		Hsync = 1;
	else if (hCounter == (VGA_H_VA + VGA_H_FP + VGA_H_SP))
		Hsync = 0;
end

always @(*)
begin 
if (vCounter == 0)
	begin
		vDisp = 1;
	end
	else if (vCounter == VGA_V_VA)
		vDisp = 0;
	else if (vCounter == (VGA_V_VA + VGA_V_FP))
		Vsync = 1;
	else if (vCounter == (VGA_V_VA + VGA_V_FP + VGA_V_SP))
		Vsync = 0;
end

assign PLLLight = dividedClock_LK;
endmodule

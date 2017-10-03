// File: ledcubelab.v

//-----Module Interface-----
module ledcubelab (
clock,
sw,
key_n,
GPIO0_pin_2_vert_pwr_1,
GPIO0_pin_4_vert_pwr_2,
GPIO0_pin_6_vert_pwr_3,
GPIO0_pin_8_R1_Bot,
GPIO0_pin_10_R2_Bot,
// pin 12 is GND
GPIO0_pin_14_R3_Bot,
GPIO0_pin_16_R1_Mid,
GPIO0_pin_18_R2_Mid,
GPIO0_pin_20_R3_Mid,
GPIO0_pin_22_R1_Top,
GPIO0_pin_24_R2_Top,
GPIO0_pin_26_R3_Top,
GPIO0_pin_28_unused1,
// pin 30 is GND
ledr,
ledg
);

//-----Input Ports-----
input clock;
input [9:0] sw;
input [3:0] key_n;

//-----Output Ports-----
output GPIO0_pin_2_vert_pwr_1;
output GPIO0_pin_4_vert_pwr_2;
output GPIO0_pin_6_vert_pwr_3;
output GPIO0_pin_8_R1_Bot;
output GPIO0_pin_10_R2_Bot;
output GPIO0_pin_14_R3_Bot;
output GPIO0_pin_16_R1_Mid;
output GPIO0_pin_18_R2_Mid;
output GPIO0_pin_20_R3_Mid;
output GPIO0_pin_22_R1_Top;
output GPIO0_pin_24_R2_Top;
output GPIO0_pin_26_R3_Top;
output GPIO0_pin_28_unused1;
output [9:0] ledr;
output [7:0] ledg;

//-----Input Ports data type-----
wire clock;
wire [9:0] sw;
wire [3:0] key_n;

//-----Output Ports Data Type-----
wire GPIO0_pin_2_vert_pwr_1;
wire GPIO0_pin_4_vert_pwr_2;
wire GPIO0_pin_6_vert_pwr_3;
wire GPIO0_pin_8_R1_Bot;
wire GPIO0_pin_10_R2_Bot;
wire GPIO0_pin_14_R3_Bot;
wire GPIO0_pin_16_R1_Mid;
wire GPIO0_pin_18_R2_Mid;
wire GPIO0_pin_20_R3_Mid;
wire GPIO0_pin_22_R1_Top;
wire GPIO0_pin_24_R2_Top;
wire GPIO0_pin_26_R3_Top;
wire GPIO0_pin_28_unused1;
wire [9:0] ledr;
wire [7:0] ledg;

//-----Hardware Description Starts Here-----

// Wires to be used with inputs from buttons
wire reset_n, go_n, ledtest_n;

// Define registers that will store the state of the system
// Also, define registers that store the control signals for each row
// and vertical planes
reg [3:0] state, state_next;
reg vert_1, vert_1_next;
reg vert_2, vert_2_next;
reg vert_3, vert_3_next;
reg r1_bot, r1_bot_next;
reg r2_bot, r2_bot_next;
reg r3_bot, r3_bot_next;
reg r1_mid, r1_mid_next;
reg r2_mid, r2_mid_next;
reg r3_mid, r3_mid_next;
reg r1_top, r1_top_next;
reg r2_top, r2_top_next;
reg r3_top, r3_top_next;

// Clock related wires
wire clk_50Mhz, clk_1Hz;

// Input pin connected to 'clock' gives 50MHz clock,
// assign this signal to the "clk_50Mhz" wire
assign clk_50Mhz = clock;

// Generate slower clock using clock divider.
// COnnect "clk_50Mhz" to the "clk" input of the clock divider,
// connect negated "reset_n" to "rst" input of clock divider, note
// that clock divider is reset when "rst" is high, where as "reset_n"
// is active low signal, so have to invert it with the "~" operator before
// connecting to "rst", finally connect the output "clk_out" to
// the "clk_1Hz" wire
clock_divider clock_divider_instance (
	.clk		(clk_50Mhz),
	.rst		(~reset_n),
	.clk_out	(clk_1Hz)
);

// Display slow clock on LED by connecting "clk_1Hz" to the red LED 0
assign ledr[0] = clk_1Hz;

// State encoding
parameter [3:0] s_idle							= 4'b0000,
						s_light_all 				= 4'b0001,
						s_light_vert_bot			= 4'b0010,
						s_light_vert_mid			= 4'b0011,
						s_light_vert_top			= 4'b0100,
						s_light_diag1_bot			= 4'b0101,
						s_light_diag1_mid			= 4'b0110,
						s_light_diag1_top			= 4'b0111,
						s_light_horizontal_bot	= 4'b1000,
						s_light_horizontal_mid	= 4'b1001,
						s_light_horizontal_top	= 4'b1010,
						s_light_diag2_bot			= 4'b1011,
						s_light_diag2_mid			= 4'b1100,
						s_light_diag2_top			= 4'b1101;
						/*
						s_light_plane1 	= 4'b0011,
						s_light_plane2 	= 4'b0100,
						s_light_plane3 	= 4'b0101;
						*/

// Display current state on green LEDs
assign ledg[3:0] = state;

// Counter for holding each plane light up
reg counter_reset, counter_reset_next;
reg [31:0] counter;

// Reset, go and LED test button connections
assign reset_n = key_n[0];
assign go_n = key_n[1];
assign ledtest_n = key_n[2];

// Next-state logic for the LED cube
always @(*)
begin
	// Default values, by default assign current value to next value
	// unless it is overwritten later in teh "always" block
	state_next = state;
	vert_1_next = vert_1;
	vert_2_next = vert_2;
	vert_3_next = vert_3;
	r1_bot_next = r1_bot;
	r2_bot_next = r2_bot;
	r3_bot_next = r3_bot;
	r1_mid_next = r1_mid;
	r2_mid_next = r2_mid;
	r3_mid_next = r3_mid;
	r1_top_next = r1_top;
	r2_top_next = r2_top;
	r3_top_next = r3_top;
	counter_reset_next = counter_reset;
	
	// Depending on current state, perform different actions
	case (state)
		// Idle state, all LEDs off, waiting for go signal or
		// LED test signal
		s_idle: begin
					// Turn off LEDs in idle state
					vert_1_next = 1'b0;
					vert_2_next = 1'b0;
					vert_3_next = 1'b0;
					r1_bot_next = 1'b0;
					r2_bot_next = 1'b0;
					r3_bot_next = 1'b0;
					r1_mid_next = 1'b0;
					r2_mid_next = 1'b0;
					r3_mid_next = 1'b0;
					r1_top_next = 1'b0;
					r2_top_next = 1'b0;
					r3_top_next = 1'b0;
					counter_reset_next = 1'b1;
					// Wait to get a go signal
			if (~go_n) begin
				state_next = s_light_vert_bot;
			end
			// Or LED test signal
			else if (~ledtest_n) begin
				// Light up LEDs
				vert_1_next = 1'b0;
				vert_2_next = 1'b0;
				vert_3_next = 1'b0;
				r1_bot_next = 1'b1;
				r2_bot_next = 1'b1;
				r3_bot_next = 1'b1;
				r1_mid_next = 1'b1;
				r2_mid_next = 1'b1;
				r3_mid_next = 1'b1;
				r1_top_next = 1'b1;
				r2_top_next = 1'b1;
				r3_top_next = 1'b1;
				// Go to next state
				state_next = s_light_all;
			end
			else begin
				// By default will stay in current state
			end
		end
		
		// State for lighting all LEDs
		s_light_all: begin
			// Keep lighting LED until user releases LED test button
			
			// Note signal is active low, so when it becomes true, user
			// has released the button.
			if (ledtest_n) begin
				// Turn off LEDs
				vert_1_next <= 1'b0;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b0;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b0;
				r2_mid_next <= 1'b0;
				r3_mid_next <= 1'b0;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_idle;
			end
		end
		
		////////////////////////////////////////////////////////
		
		s_light_vert_bot: begin
			if (counter >= 32'd100 & ~counter_reset) begin
				state_next = s_light_diag1_bot;
			end
			else begin
				// Stop resetting counter
				counter_reset_next = 1'b0;
				// Light LEDs
				vert_1_next <= 1'b1;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b1;
				r1_bot_next <= 1'b1;
				r2_bot_next <= 1'b1;
				r3_bot_next <= 1'b1;
				r1_mid_next <= 1'b0;
				r2_mid_next <= 1'b0;
				r3_mid_next <= 1'b0;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_vert_mid;
			end
		end
		
		s_light_vert_mid: begin
				vert_1_next <= 1'b1;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b1;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b1;
				r2_mid_next <= 1'b1;
				r3_mid_next <= 1'b1;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_vert_top;
		end
		
		s_light_vert_top: begin
				vert_1_next <= 1'b1;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b1;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b0;
				r2_mid_next <= 1'b0;
				r3_mid_next <= 1'b0;
				r1_top_next <= 1'b1;
				r2_top_next <= 1'b1;
				r3_top_next <= 1'b1;
				// Go to next state
				state_next = s_light_vert_bot;
		end
		
		////////////////////////////////////////////////////////
		
		s_light_diag1_bot: begin
			if (counter >= 32'd200) begin
				state_next = s_light_horizontal_bot;
			end
			else begin
				// Stop resetting counter
				counter_reset_next = 1'b0;
				// Light LEDs
				vert_1_next <= 1'b0;
				vert_2_next <= 1'b1;
				vert_3_next <= 1'b1;
				r1_bot_next <= 1'b1;
				r2_bot_next <= 1'b1;
				r3_bot_next <= 1'b1;
				r1_mid_next <= 1'b0;
				r2_mid_next <= 1'b0;
				r3_mid_next <= 1'b0;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_diag1_mid;
			end
		end
		
		s_light_diag1_mid: begin
				vert_1_next <= 1'b1;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b1;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b1;
				r2_mid_next <= 1'b1;
				r3_mid_next <= 1'b1;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_diag1_top;
		end
		
		s_light_diag1_top: begin
				vert_1_next <= 1'b1;
				vert_2_next <= 1'b1;
				vert_3_next <= 1'b0;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b0;
				r2_mid_next <= 1'b0;
				r3_mid_next <= 1'b0;
				r1_top_next <= 1'b1;
				r2_top_next <= 1'b1;
				r3_top_next <= 1'b1;
				// Go to next state
				state_next = s_light_diag1_bot;
		end
		
		////////////////////////////////////////////////////////
		
		s_light_horizontal_bot: begin
			if (counter >= 32'd300) begin
				state_next = s_light_diag2_bot;
			end
			else begin
				// Stop resetting counter
				counter_reset_next = 1'b0;
				// Light LEDs
				vert_1_next <= 1'b0;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b0;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b1;
				r2_mid_next <= 1'b1;
				r3_mid_next <= 1'b1;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_horizontal_mid;
			end
		end
		
		s_light_horizontal_mid: begin
				vert_1_next <= 1'b0;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b0;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b1;
				r2_mid_next <= 1'b1;
				r3_mid_next <= 1'b1;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_horizontal_top;
		end
		
		s_light_horizontal_top: begin
				vert_1_next <= 1'b0;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b0;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b1;
				r2_mid_next <= 1'b1;
				r3_mid_next <= 1'b1;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_horizontal_bot;
		end
		
		////////////////////////////////////////////////////////
		
		s_light_diag2_bot: begin
			if (counter >= 32'd400) begin
				counter_reset_next = 1'b1;
				state_next = s_light_vert_bot;
			end
			else begin
				// Stop resetting counter
				counter_reset_next = 1'b0;
				// Light LEDs
				vert_1_next <= 1'b1;
				vert_2_next <= 1'b1;
				vert_3_next <= 1'b0;
				r1_bot_next <= 1'b1;
				r2_bot_next <= 1'b1;
				r3_bot_next <= 1'b1;
				r1_mid_next <= 1'b0;
				r2_mid_next <= 1'b0;
				r3_mid_next <= 1'b0;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_diag2_mid;
			end
		end
		
		s_light_diag2_mid: begin
				vert_1_next <= 1'b1;
				vert_2_next <= 1'b0;
				vert_3_next <= 1'b1;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b1;
				r2_mid_next <= 1'b1;
				r3_mid_next <= 1'b1;
				r1_top_next <= 1'b0;
				r2_top_next <= 1'b0;
				r3_top_next <= 1'b0;
				// Go to next state
				state_next = s_light_diag2_top;
		end
		
		s_light_diag2_top: begin
				vert_1_next <= 1'b0;
				vert_2_next <= 1'b1;
				vert_3_next <= 1'b1;
				r1_bot_next <= 1'b0;
				r2_bot_next <= 1'b0;
				r3_bot_next <= 1'b0;
				r1_mid_next <= 1'b0;
				r2_mid_next <= 1'b0;
				r3_mid_next <= 1'b0;
				r1_top_next <= 1'b1;
				r2_top_next <= 1'b1;
				r3_top_next <= 1'b1;
				// Go to next state
				state_next = s_light_diag2_bot;
		end
		
	endcase
end

// Next state registers for LED cube
// Note this runs on clock from the clock divider

always @ (posedge clk_1Hz or negedge reset_n)
begin
	// Reset button is active low! so reset if it's 0
	if (~reset_n) begin
		state <= s_idle;
		vert_1 <= 1'b0;
		vert_2 <= 1'b0;
		vert_3 <= 1'b0;
		r1_bot <= 1'b0;
		r2_bot <= 1'b0;
		r3_bot <= 1'b0;
		r1_mid <= 1'b0;
		r2_mid <= 1'b0;
		r3_mid <= 1'b0;
		r1_top <= 1'b0;
		r2_top <= 1'b0;
		r3_top <= 1'b0;
		counter_reset <= 1'b1;
	end
	// Else take state assigned in next state logic
	// and save it to the registers
	else begin
		state <= state_next;
		vert_1 <= vert_1_next;
		vert_2 <= vert_2_next;
		vert_3 <= vert_3_next;
		r1_bot <= r1_bot_next;
		r2_bot <= r2_bot_next;
		r3_bot <= r3_bot_next;
		r1_mid <= r1_mid_next;
		r2_mid <= r2_mid_next;
		r3_mid <= r3_mid_next;
		r1_top <= r1_top_next;
		r2_top <= r2_top_next;
		r3_top <= r3_top_next;
		counter_reset <= counter_reset_next;
	end
end

always @ (posedge clk_1Hz or negedge reset_n)
begin
	// Reset button is active low! So reset if it's 0
	if (~reset_n) begin
		counter <= 32'd0;
	end
	// Reset counter
	else if (counter_reset) begin
		counter <= 32'd0;
	end
	// Otherwise just keep counter
	else begin
		counter <= counter + 1;
	end
end

// Output logic, simply connect registers to the output signals
assign GPIO0_pin_2_vert_pwr_1 = vert_1;
assign GPIO0_pin_4_vert_pwr_2 = vert_2;
assign GPIO0_pin_6_vert_pwr_3 = vert_3;

assign GPIO0_pin_8_R1_Bot = r1_bot;
assign GPIO0_pin_10_R2_Bot = r2_bot;
assign GPIO0_pin_14_R3_Bot = r3_bot;
assign GPIO0_pin_16_R1_Mid = r1_mid;
assign GPIO0_pin_18_R2_Mid = r2_mid;
assign GPIO0_pin_20_R3_Mid = r3_mid;
assign GPIO0_pin_22_R1_Top = r1_top;
assign GPIO0_pin_24_R2_Top = r2_top;
assign GPIO0_pin_26_R3_Top = r3_top;

endmodule

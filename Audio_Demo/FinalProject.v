
module FinalProject (
	// Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	PS2_CLK,
	PS2_DAT,
	VGA_HS, 
	VGA_VS, 
	VGA_BLANK_N, 
	VGA_SYNC_N, 
	VGA_CLK,
	VGA_R, VGA_G, VGA_B
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
localparam  C        = 8'h1A,
				Cs       = 8'h1B,
				D			= 8'h22,
				Ds       = 8'h23,
				E        = 8'h21,
				F        = 8'h2A,
				Fs       = 8'h34,
				G        = 8'h3A,
				Gs       = 8'h3B,
				A        = 8'h41,
				As       = 8'h42,
				B        = 8'h49,
				Co        = 8'h15,
				Cso       = 8'h1E,
				Do			= 8'h1D,
				Dso       = 8'h26,
				Eo        = 8'h24,
				Fo        = 8'h2D,
				Fso       = 8'h2E,
				Go        = 8'h3C,
				Gso       = 8'h3D,
				Ao        = 8'h43,
				Aso       = 8'h3E,
				Bo        = 8'h44,
				nothing  = 8'h0,
				Lshift   = 8'h12,
				Rshift   = 8'h59,
				caps     = 8'h58;
/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[3:0]	KEY;
input		[9:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

inout          PS2_CLK;
inout          PS2_DAT;
// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;
output    [7:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
output[7:0] VGA_R, VGA_G, VGA_B;
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;
wire     [7:0] data_received;
// Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;

reg [18:0] delay_cnt2;
wire [18:0] delay2;

reg [18:0] delay_cnt3;
wire [18:0] delay3;

reg snd;
reg snd2;
reg snd3;

reg [15:0] freq;
reg [18:0] octaveFreq;

reg [15:0] freq2;

reg octave1, octave2, octave3;

reg [22:0] beatCountM, beatCountZ, beatCountZtut, beatCountRocky;
reg [21:0] beatCountP;
reg [9:0] addressZ, addressP, addressM, addressZtut, addressRocky; 
reg [17:0] audioFreq;
wire [17:0] audioFreqP, audioFreqM, audioFreqZ, audioFreqZtut, audioFreqRocky; 

//PS2
/*
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output      [7:0] last_data_received
*/
PS2_Demo p1(.CLOCK_50(CLOCK_50), .KEY(KEY), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), .HEX0(HEX0), 
					.HEX1(HEX1), .data_received(data_received));

Display d1(.CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW), .delay(freqOut), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), 
					.VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_BLANK_IN), .VGA_CLK(VGA_CLK), .VGA_R(VGA_R), 
						.VGA_G(VGA_G), .VGA_B(VGA_B));
// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
 
wire ended, dataEqual, increaseAddress, ld_song, reset_address;
wire [9:0] address;
wire [15:0] freqOut;
control c1(.clk(CLOCK_50), .reset(~KEY[0]), .play(~KEY[3]), .ended(ended), /*.dataEqual(dataEqual), 
					.increaseAddress(increaseAddress),*/ .ld_song(ld_song), .reset_address(reset_address));
datapath display1(.clk(CLOCK_50), .reset(~KEY[0]), .data_inR(SW[0]), .data_inM(SW[1]), 
					.data_inZ(SW[2]), .keyboardFreq(delay), .ld_song(ld_song), /*.increaseAddress(increaseAddress),*/ 
						.reset_address(reset_address), .freqOut(freqOut), .ended(ended), /*.dataEqual(dataEqual),*/ .ADDRESSDEBUG(address));
						
						
Hexadecimal_To_Seven_Segment Segment2 (
	// Inputs
	.hex_number			(freqOut[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX2)
);

Hexadecimal_To_Seven_Segment Segment3 (
	// Inputs
	.hex_number			(freqOut[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX3)
);

Hexadecimal_To_Seven_Segment Segment4 (
	// Inputs
	.hex_number			(address[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX4)
);

Hexadecimal_To_Seven_Segment Segment5 (
	// Inputs
	.hex_number			(address[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX5)
);

rocky r1(.address(addressRocky), .clock(CLOCK_50), .data(18'b0), .wren(1'b0), .q(audioFreqRocky));
pokemon pika1(.address(addressP), .clock(CLOCK_50), .data(18'b0), .wren(1'b0), .q(audioFreqP));
zelda z1(.address(addressZ), .clock(CLOCK_50), .data(18'b0), .wren(1'b0), .q(audioFreqZ));
mario m1(.address(addressM), .clock(CLOCK_50), .data(18'b0), .wren(1'b0), .q(audioFreqM));
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;

always @(posedge CLOCK_50)
	if(delay_cnt2 == delay2) begin
		delay_cnt2 <= 0;
		snd2 <= !snd2;
	end else delay_cnt2 <= delay_cnt2 + 1;

always @(posedge CLOCK_50)
	if(delay_cnt3 == delay3) begin
		delay_cnt3 <= 0;
		snd3 <= !snd3;
	end else delay_cnt3 <= delay_cnt3 + 1;

always @(posedge CLOCK_50) begin //select frequency
	if(SW[3] == 1'b1) //rocky song listen is chosen
		audioFreq <= audioFreqRocky;
	else if(SW[4] == 1'b1) //pokemon song listen is chosen
		audioFreq <= audioFreqP;
	else if(SW[5] == 1'b1) //zelda song listen is chosen
		audioFreq <= audioFreqZ;
	else if(SW[6] == 1'b1) //mario song listen is chosen
		audioFreq <= audioFreqM;
end



always @(posedge CLOCK_50) begin //extraction for listening pieces
	if(~KEY[0])begin //reset everything
		addressRocky <= 0;
		addressP <= 0;
		addressZ <= 0;
		addressM <= 0;
	end
	if(SW[3] == 1'b1) begin //rocky song listen is chosen
		if(beatCountRocky == 23'b10011000100101101000000)begin
			beatCountRocky <= 23'b0;
			if(addressRocky < 10'b1001111110)
				addressRocky <= addressRocky + 1;
		end
		else 
			beatCountRocky <= beatCountRocky + 1;
	end
	else if(SW[4] == 1'b1) begin //pokemon song listen is chosen
		if(beatCountP == 22'b1011111010111100001000)begin
			beatCountP <= 22'b0;
			if(addressP < 10'b1011101000)
				addressP <= addressP + 1;
		end
		else 
			beatCountP <= beatCountP + 1;
	end
	else if(SW[5] == 1'b1) begin //zelda song listen is chosen
		if(beatCountZ == 22'b1011111010111100001000)begin
			beatCountZ <= 22'b0;
			if(addressZ < 10'b1110110001)
				addressZ <= addressZ + 1;
		end
		else 
			beatCountZ <= beatCountZ + 1;
	end
	else if(SW[6] == 1'b1) begin //zelda song listen is chosen
		if(beatCountM == 22'b1011111010111100001000)begin
			beatCountM <= 22'b0;
			if(addressM < 10'b1101101111)
				addressM <= addressM + 1;
		end
		else 
			beatCountM <= beatCountM + 1;
	end
	
end
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
always @(*)
	case(data_received) 
		C: freq = 16'd23889; //1046.5Hz
		Cs: freq = 16'd22548; //1108.73Hz
		D: freq = 16'd21283; //1174.66Hz
		Ds: freq = 16'd20088; //1244.51Hz 
		E: freq = 16'd18961; //1318.51Hz
		F: freq = 16'd17897; //1396.91Hz
		Fs: freq = 16'd16892; //1479.98Hz
		G: freq = 16'd15944; //1567.98Hz
		Gs: freq = 16'd15049; //1661.22Hz
		A: freq = 16'd14205; //1760hz
		As: freq = 16'd13407; //1864.66Hz
		B: freq = 16'd12655; //1975.53Hz
		
		Co: freq = 16'd47778; //1046.5Hz
		Cso: freq = 16'd45096; //1108.73Hz
		Do: freq = 16'd42566; //1174.66Hz
		Dso: freq = 16'd40176; //1244.51Hz 
		Eo: freq = 16'd37922; //1318.51Hz
		Fo: freq = 16'd35794; //1396.91Hz
		Fso: freq = 16'd33784; //1479.98Hz
		Go: freq = 16'd31888; //1567.98Hz
		Gso: freq = 16'd30098; //1661.22Hz
		Ao: freq = 16'd28410; //1760hz
		Aso: freq = 16'd26814; //1864.66Hz
		Bo: freq = 16'd25310; //1975.53Hz
		
		default: freq = 16'd0; //default frequency, largest 16 bit decimal value
	endcase
	
//TO implement, frequency merging
assign delay = freq;
assign delay3 = audioFreq;

assign delay2 = freqOut;

wire [31:0] sound = (data_received == 0) ? 0 : snd ? 32'd100000000 : -32'd100000000;
wire [31:0] sound3 = ((SW[3] == 1'b0) && (SW[4] == 1'b0) && (SW[5] == 1'b0) && (SW[6] == 1'b0)) ? 0 : snd3 ? 32'd100000000 : -32'd100000000;
wire [31:0] sound2 = (freqOut == 0) ? 0 : (snd2 ? 32'd500000 : -32'd500000);


reg [31:0] combinedSound;
always@(*) begin
		/*if(sound == 32'b0)
			combinedSound = sound3;
		else if (sound3 == 32'b0)
			combinedSound = sound;
		else if (sound3 == sound)
			combinedSound = sound;
		else */
		//if(sound3 != 32'b0 && sound != 32'b0) begin
			//combine amplitudes of 2 sounds waves
			combinedSound = sound + sound3;		
		//end	
	end


assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= left_channel_audio_in+combinedSound;
assign right_channel_audio_out	= right_channel_audio_in+sound2;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

//TODO: corner case for listening vs tutorial
module control(
	input clk,
	input reset,
	input play,
	input ended,
	//input dataEqual,
	//output reg increaseAddress,
	output reg ld_song,
	output reg reset_address);
	
reg [2:0] current_state, next_state;

parameter CHOOSE          = 3'd0,
			 LOAD_STATE      = 3'd1,
			 //EXTRACT         = 3'd2,
			 CHECK           = 3'd3,
			 END             = 3'd4;
			 
	//state table
	always@(*)
	begin: state_table
			  case(current_state)
				CHOOSE: next_state = play ? LOAD_STATE : CHOOSE;
				LOAD_STATE: next_state = CHECK;
				//EXTRACT: next_state = CHECK;
				//CHECK: next_state = ended ? END : (dataEqual ? EXTRACT : CHECK);
				CHECK: next_state = ended ? END : CHECK;
				END: next_state = CHOOSE;
			  
			  default: next_state = CHOOSE;
	    endcase
	end
	
	// Output logic aka all of our datapath control signals

    always @(*)
    begin: enable_signals
      ld_song = 1'b0;
      //increaseAddress = 1'b0;
		reset_address = 1'b0;
		
		 case (current_state)
			LOAD_STATE: ld_song = 1'b1;
			//EXTRACT: increaseAddress = 1'b1;
			END: reset_address = 1'b1;
		 endcase
	 end 
		 
	 //current_state registers
	 always@(posedge clk)
	 begin: state_FFs
		  if(reset)
				current_state <= CHOOSE;
		  else
				current_state <= next_state;
	 end
endmodule
 
module datapath(
	input clk,
	input reset,
	input data_inR,
	input data_inM,
	input data_inZ,
	input [18:0] keyboardFreq,
	input ld_song,
   //input increaseAddress,
	input reset_address,
	output reg [15:0] freqOut,
	output reg ended,
	//output reg dataEqual,
	output [9:0] ADDRESSDEBUG);
	
	reg flagRocky, flagMario, flagZelda, flagplay;
	reg [1:0] song;
	reg [9:0] address;
	assign ADDRESSDEBUG = address;
	wire [15:0] freqRocky, freqZelda, freqMario;
	//TO CHANGE
	localparam RockyLength = 10'd165, 
				  zeldaLength   = 10'd128,
				  marioLength   = 10'd174;
				  
	  rockyT r1 ( .address(address), .clock(clk), .data(18'b0), .wren(1'b0), .q(freqRocky));
	  zeldaT z2 ( .address(address), .clock(clk), .data(18'b0), .wren(1'b0), .q(freqZelda));
	  marioT m2 ( .address(address), .clock(clk), .data(18'b0), .wren(1'b0), .q(freqMario));
	
	//load the song
	always@(posedge clk) begin
		if(reset) 
			song <= 2'b0;
		if(ld_song) begin
			song <= 2'd0;
			if(data_inR)
				song <= 2'd1; //to prevent unintended change in switches
			if(data_inM)	
				song <= 2'd2;
			if(data_inZ)
				song <= 2'd3;
		end
	end
	
	//counter 
	always@(posedge clk) begin
	if(ld_song)
		flagplay <= 1;
	if(reset) begin
		address <= 10'b0;
		ended <= 1'b0;
		flagRocky <= 0;
		flagMario <= 0;
		flagZelda <= 0;
		flagplay <= 0;
	end
	else begin	
		if(song == 2'd1) begin //Rocky song chosen
			if(reset_address) begin //reset address and undo ended.
				address <= 10'b0;
				ended <= 1'b0;
				flagplay <= 1'b0;
				flagRocky <= 1'b0;
			end
			if(address == RockyLength) 
				ended <= 1'b1;
			else begin 
				if((keyboardFreq == freqRocky) && (address < RockyLength) && !flagRocky && flagplay)begin
					address <= address + 1;
					flagRocky <= 1;
				end
				
				if(!(keyboardFreq == freqRocky))
					flagRocky <= 0;
				
			end
		end	
		
		if(song == 2'd2) begin //mario song chosen
			if(reset_address) begin //reset address and undo ended.
				address <= 10'b0;
				ended <= 1'b0;
				flagplay <= 1'b0;
				flagMario <= 1'b0;
			end
			if(address == marioLength) 
				ended <= 1'b1;
			else begin 
				if((keyboardFreq == freqMario) && (address < marioLength) && !flagMario && flagplay)begin
					address <= address + 1;
					flagMario <= 1;
				end
				
				if(!(keyboardFreq == freqMario))
					flagMario <= 0;
				
			end
		end
		
		if(song == 2'd3) begin //zelda song chosen
			if(reset_address) begin //reset address and undo ended.
				address <= 10'b0;
				ended <= 1'b0;
				flagplay <= 0;
				flagZelda <= 0;
			end
			
			if(address == zeldaLength) 
				ended <= 1'b1;
			else begin 
				if((keyboardFreq == freqZelda) && (address < zeldaLength) && !flagZelda && flagplay)begin
					address <= address + 1;
					flagZelda <= 1;
				end
				
				if(!(keyboardFreq == freqZelda))
					flagZelda <= 0;
				
			end
		end
	end
end
	
	//output the right frequency to the top module
	always@(posedge clk) begin
		freqOut <= 16'b0;
		if(song == 2'd1)  //pokemon song chosen
			freqOut <= freqRocky;
		if (song == 2'd2) //mario chosen
			freqOut <= freqMario;
		if (song == 2'd3) //zelda chosen
			freqOut <= freqZelda; 
	end
	
endmodule 
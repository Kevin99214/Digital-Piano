module Display(
	input 		CLOCK_50,
	input [3:0]	KEY,
	input [9:0] SW,
	input [15:0] delay, //comment this to test, uncomment everything else in top level module
	
	output 		VGA_HS, 
					VGA_VS, 
					VGA_BLANK_N, 
					VGA_SYNC_N, 
					VGA_CLK, 
	output[7:0] VGA_R, 
					VGA_G, 
					VGA_B
	);
	
	wire [7:0] x;
	wire [6:0] y;
	wire colour, enable_plot;
//	reg [15:0] delay2;
//	reg [25:0] counter;
//	reg [4:0] change;
	
	//instantiate the vga adapter
	vga_adapter a1(.resetn(KEY[0]), 
						.clock(CLOCK_50), 
						.colour((colour ? 3'b001 : 3'b111)), 
						.x((x + 8'd49)), 
						.y((y + 7'd29)), 
						.plot(1'b1),
						.VGA_R(VGA_R),
						.VGA_G(VGA_G), 
						.VGA_B(VGA_B), 
						.VGA_HS(VGA_HS), 
						.VGA_VS(VGA_VS),
						.VGA_BLANK(VGA_BLANK_N),
						.VGA_SYNC(VGA_SYNC_N),
						.VGA_CLK(VGA_CLK)); //draw the pixel 
	
	defparam a1.RESOLUTION = "160x120";
	defparam a1.MONOCHROME = "FALSE";
	defparam a1.BITS_PER_COLOUR_CHANNEL = 1;
	defparam a1.BACKGROUND_IMAGE = "black.mif";
	
//	always @(posedge CLOCK_50) begin
//		if(counter > 26'd50000000) begin
//			change <= change + 1'b1;
//			counter <= 26'b0;
//		end
//		else
//			counter <= counter + 1'b1;
//			
//		case(change)
//			5'd0: delay2 <= 16'd23889;
//			5'd1: delay2 <= 16'd22548;
//			5'd2:	delay2 <= 16'd21283;
//			5'd3: delay2 <= 16'd20088;
//			5'd4: delay2 <= 16'd18961;
//			5'd5: delay2 <= 16'd17897;
//			5'd6: delay2 <= 16'd16892;
//			5'd7: delay2 <= 16'd15944;
//			5'd8: delay2 <= 16'd15049;
//			5'd9: delay2 <= 16'd14205;
//			5'd10: delay2 <= 16'd13407;
//			5'd11: delay2 <= 16'd12655;
//			5'd12: delay2 <= 16'd47778;
//			5'd13: delay2 <= 16'd45096;
//			5'd14: delay2 <= 16'd42566;
//			5'd15: delay2 <= 16'd40176;
//			5'd16: delay2 <= 16'd37922;
//			5'd17: delay2 <= 16'd35794;
//			5'd18: delay2 <= 16'd33784;
//			5'd19: delay2 <= 16'd31888;
//			5'd20: delay2 <= 16'd30098;
//			5'd21: delay2 <= 16'd28410;
//			5'd22: delay2 <= 16'd26814;
//			5'd23: delay2 <= 16'd25310;
//			5'd31: delay2 <= 16'd12345;
//		endcase
//	end
	
	draw d1(.clk(CLOCK_50), .reset(~KEY[0]), .delay(delay), 
					.x(x), .y(y), .c(colour), .enable_plot(enable_plot));
	
endmodule 

module draw(input clk, reset, input [15:0] delay, 
					output reg [7:0] x, output reg [6:0] y, output reg c, enable_plot);
	
	//internal wires for memory extract 
	wire c2, c3, c5, c7, c8, cC, cD, cE, cG, cGreat, cI, cJ, 
				cK, cLess, cM, cO, cQ, cR, cS, cU, cV, cW, cX, cZ; 	
	
	//internal count registers
	reg [15:0] counter;
	reg [7:0] countX;
	reg [6:0] countY;
	reg [15:0] letterToPrint;
	reg printedFlag;		
	
	//local parameters
	localparam  C         = 16'd23889,
					Cs        = 16'd22548,
					D			 = 16'd21283,
					Ds        = 16'd20088,
					E         = 16'd18961,
					F         = 16'd17897,
					Fs        = 16'd16892,
					G         = 16'd15944,
					Gs        = 16'd15049,
					A         = 16'd14205,
					As        = 16'd13407,
					B         = 16'd12655,
					
					Co        = 16'd47778,
					Cso       = 16'd45096,
					Do			 = 16'd42566,
					Dso       = 16'd40176,
					Eo        = 16'd37922,
					Fo        = 16'd35794,
					Fso       = 16'd33784,
					Go        = 16'd31888,
					Gso       = 16'd30098,
					Ao        = 16'd28410,
					Aso       = 16'd26814,
					Bo        = 16'd25310;
		
	//make sure letter is only printing once
	always @(posedge clk) begin
		if(reset) begin
			printedFlag <= 1'b0;
			letterToPrint <= 16'd0;
			enable_plot <= 1'b0;
		end
		else begin
			if((letterToPrint != delay)) begin
				printedFlag <= 1'b0;
				letterToPrint <= delay; 
			end
			if((countX == 8'd63) && (countY==7'd63))begin
				printedFlag <= 1'b1; 
			end
			enable_plot <= ~printedFlag;
		end
	end
	
	//count though all the pixels that need to be drawn
	always @(posedge clk) begin
		if(reset) begin
			countX <= 8'd0;
			countY <= 7'd0;
			counter <= 16'd1;
			end
		else if(!printedFlag) begin
			countX <= countX + 1'b1;
			counter <= counter + 1'b1;
			//move to next row
			if(countX == 8'd63) begin
				countY <= countY  + 1'b1;
				countX <= 8'd0;
			end
		
			//counted through the entire picture
			if((countX == 8'd63) && (countY==7'd63))begin
				countX <= 8'd0;
				countY <= 7'd0;
				counter <= 16'd1; 
			end	
		end
	end	
	
	//output to screen
	always @(posedge clk) begin
		if(reset) begin
			x <= 8'd0;
			y <= 7'd0;
		end
		else begin
			x <= countX;
			y <= countY;
		end		
	end
		
	//extract from image mif note to play from image mif
	two display2(.address(counter), .clock(clk), .q(c2));
	three display3(.address(counter), .clock(clk), .q(c3));
	five display5(.address(counter), .clock(clk), .q(c5));
	seven display7(.address(counter), .clock(clk), .q(c7));
	eight display8(.address(counter), .clock(clk), .q(c8));
	C displayC(.address(counter), .clock(clk), .q(cC));
	D displayD(.address(counter), .clock(clk), .q(cD));
	E displayE(.address(counter), .clock(clk), .q(cE));
	G displayG(.address(counter), .clock(clk), .q(cG));
	greater displayGrt(.address(counter), .clock(clk), .q(cGreat));
	I displayI(.address(counter), .clock(clk), .q(cI));
	J displayJ(.address(counter), .clock(clk), .q(cJ));
	K displayK(.address(counter), .clock(clk), .q(cK));
	less displayL(.address(counter), .clock(clk), .q(cLess));
	M displayM(.address(counter), .clock(clk), .q(cM));
	O displayO(.address(counter), .clock(clk), .q(cO));
	Q displayQ(.address(counter), .clock(clk), .q(cQ));
	R displayR(.address(counter), .clock(clk), .q(cR));
	S displayS(.address(counter), .clock(clk), .q(cS));
	U displayU(.address(counter), .clock(clk), .q(cU));
	V displayV(.address(counter), .clock(clk), .q(cV));
	W displayW(.address(counter), .clock(clk), .q(cW));		
	X displayX(.address(counter), .clock(clk), .q(cX));
	Z displayZ(.address(counter), .clock(clk), .q(cZ));
	
	//determine which mif to draw onto the screen
	always@(posedge clk) begin
		case(letterToPrint)
			C:    c = cZ;
			Cs:   c = cS;
			D:    c = cX;
			Ds:   c = cD;
			E:    c = cC;
			F:    c = cV;
			Fs:   c = cG;
			G:    c = cM;
			Gs:   c = cJ;
			A:    c = cLess;
			As:   c = cK;
			B:    c = cGreat;
			
			Co:   c = cQ;
			Cso:  c = c2;    
			Do:   c = cW;			 
			Dso:  c = c3;    
			Eo:   c = cE;      
			Fo:   c = cR;    
			Fso:  c = c5;    
			Go:   c = cU;   
			Gso:  c = c7;    
			Ao:   c = cI;   
			Aso:  c = c8;   
			Bo:   c = cO;  
			
			default: c = 1'b0;
		endcase
	end	
endmodule 
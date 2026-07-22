/*
 * Copyright (c) 2026 Edgar Hofmann
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
// pmodvga_06 - color tiles VGA 640x480 using TT VGA Playground Module Template
// Consider clk 25 Mhz

module tt_um_ehofmannbr_pmodvga_06(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

// VGA signals
wire hsync;
wire vsync;
wire [1:0] R;
wire [1:0] G;
wire [1:0] B;
wire video_active;
wire [9:0] pix_x;
wire [9:0] pix_y;

// Tile Registers
	reg[11:0] _cor;         // Tile Color Register
	reg[11:0] cor1;         // Color 1
	reg[11:0] cor2;         // ...
reg[11:0] cor3;             
reg[11:0] cor4;             
reg[11:0] cor5;             
reg[11:0] cor6;             
reg[11:0] cor7;             
reg[11:0] cor8;             
	reg[11:0] cor9;         // Color 9
	reg[11:0] cort;         // Temp Color
	reg[25:0] t_cnt;        // Color shift timer, supports 25Mhz and 50Mhz clocks

// TinyVGA PMOD
assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  
// Unused outputs assigned to 0.
assign uio_out = 0;
assign uio_oe  = 0;

// Suppress unused signals warning
wire _unused_ok = &{ena, ui_in, uio_in};

hvsync_generator hvsync_gen(
  .clk(clk),
  .reset(~rst_n),
  .hsync(hsync),
  .vsync(vsync),
  .display_on(video_active),
  .hpos(pix_x),
  .vpos(pix_y)
);
//                       XL     XM      XR
parameter XL = 213;//   ---------------------
parameter XM = 426;//   |_____|______|______| YU
parameter XR = 640;//   |                   |
parameter YU = 160;//   |_____|______|______| YM
parameter YM = 320;//   |                   |
parameter YB = 480;//   |_____|______|______| YB

// Tiles
always @(*) begin
   if ((pix_x>=0)&&(pix_x<XL)&&(pix_y>=0)&&(pix_y<YU)) 
      begin
      _cor = cor1;
      end
	else
   if ((pix_x>=XL)&&(pix_x<XM)&&(pix_y>=0)&&(pix_y<YU)) 
      begin
      _cor = cor2;
		end
	else
   if ((pix_x>=XM)&&(pix_x<XR)&&(pix_y>=0)&&(pix_y<YU)) 
      begin
      _cor = cor3;
		end
	else
   if ((pix_x>=0)&&(pix_x<XL)&&(pix_y>=YU)&&(pix_y<YM)) 
      begin
      _cor = cor4;
      end
	else
   if ((pix_x>=XL)&&(pix_x<XM)&&(pix_y>=YU)&&(pix_y<YM)) 
      begin
      _cor = cor5;
		end
	else
   if ((pix_x>=XM)&&(pix_x<XR)&&(pix_y>=YU)&&(pix_y<YM)) 
      begin
      _cor = cor6;
		end
	else
   if ((pix_x>=0)&&(pix_x<XL)&&(pix_y>=YM)&&(pix_y<YB)) 
      begin
      _cor = cor7;
      end
	else
   if ((pix_x>=XL)&&(pix_x<XM)&&(pix_y>=YM)&&(pix_y<YB)) 
      begin
      _cor = cor8;
		end
	else
   if ((pix_x>=XM)&&(pix_x<XR)&&(pix_y>=YM)&&(pix_y<YB)) 
      begin
      _cor = cor9;
		end
	else
	  begin
	  _cor = 12'b0;
	  end
end		

always @(posedge clk) begin
   if (!rst_n)
      begin
		t_cnt  = 0;
		cor1   = 12'b000000000000;
		cor2   = 12'b111100000000;
		cor3   = 12'b000011110000;
		cor4   = 12'b000000001111;
		cor5   = 12'b111111110000;
		cor6   = 12'b111100001111;
		cor7   = 12'b000011111111;
		cor8   = 12'b011101110111;
		cor9   = 12'b111111111111;
      end
   else
      begin
      if (t_cnt==24999999) // 1 em 1 segundo
		     begin
			  t_cnt = 0;
			  cort = cor9;
			  cor9 = cor8;
			  cor8 = cor7;
			  cor7 = cor6;
			  cor6 = cor5;
			  cor5 = cor4;
			  cor4 = cor3;
			  cor3 = cor2;
			  cor2 = cor1;
			  cor1 = cort;
			  end
		  else
		     begin
			  t_cnt = t_cnt + 1'b1;
			  end  
        end
end

assign R[1]=_cor[11];
assign R[0]=_cor[10];
assign G[1]=_cor[7];
assign G[0]=_cor[6];
assign B[1]=_cor[3];
assign B[0]=_cor[2];

endmodule



module vgapmod_04 (
    input wire clk_50,       // 50 Mhz Clk
    input wire rst_n,        // Asynchronous Low reset
    output wire hs,          // Horizontal signal
    output wire vs,          // Vertical signal
    output wire[3:0] r_out,  // Red signal
    output wire[3:0] g_out,  // Green signal
    output wire[3:0] b_out   // Blue signal
);

reg clk_25;                 // Divide 50Mhz por 2
reg[9:0] h_cnt;             // Conta de zero a 799
reg[9:0] v_cnt;             // Conta de zero a 520
reg _hs;                    // Registro hs
reg _vs;                    // Registro vs
reg[11:0] _cor;             // Saida do mux de cor
reg[11:0] cor1;             // Registro de cor
reg[11:0] cor2;             // Registro de cor
reg[11:0] cor3;             // Registro de cor
reg[11:0] cor4;             // Registro de cor
reg[11:0] cor5;             // Registro de cor
reg[11:0] cor6;             // Registro de cor
reg[11:0] cor7;             // Registro de cor
reg[11:0] cor8;             // Registro de cor
reg[11:0] cor9;             // Registro de cor
reg[11:0] cort;             // Registro de cor
reg[25:0] t_cnt;            // Enables period > 1s

// Horizontal sequence
// 0..95 hs active, 96..143 Back Porch, 144..783 _on, 784..799 Front Porch
always @(*) begin  // Horizontal pulse 
   if ((h_cnt>=0)&&(h_cnt<96)) 
      begin
      _hs = 1'b0;
      end
   else
      begin
      _hs = 1'b1;
      end   
end

// Vertical sequence
// 0..1 vs active, 2..30 Back Porch, 31..510 _on, 511..520 Front Porch
always @(*) begin // Vertical Pulse 
   if ((v_cnt>=0)&&(v_cnt<2)) 
      begin
      _vs = 1'b0;
      end
   else
      begin
      _vs = 1'b1;
      end   
end

// Mosaicos
always @(*) begin
   if ((h_cnt>=144)&&(h_cnt<358)&&(v_cnt>=31)&&(v_cnt<191)) 
      begin
      _cor = cor1;
      end
	else
   if ((h_cnt>=358)&&(h_cnt<572)&&(v_cnt>=31)&&(v_cnt<191)) 
      begin
      _cor = cor2;
		end
	else
   if ((h_cnt>=572)&&(h_cnt<783)&&(v_cnt>=31)&&(v_cnt<191)) 
      begin
      _cor = cor3;
		end
	else
   if ((h_cnt>=144)&&(h_cnt<358)&&(v_cnt>=191)&&(v_cnt<351)) 
      begin
      _cor = cor4;
      end
	else
   if ((h_cnt>=358)&&(h_cnt<572)&&(v_cnt>=191)&&(v_cnt<351)) 
      begin
      _cor = cor5;
		end
	else
   if ((h_cnt>=572)&&(h_cnt<783)&&(v_cnt>=191)&&(v_cnt<351)) 
      begin
      _cor = cor6;
		end
	else
   if ((h_cnt>=144)&&(h_cnt<358)&&(v_cnt>=351)&&(v_cnt<510)) 
      begin
      _cor = cor7;
      end
	else
   if ((h_cnt>=358)&&(h_cnt<572)&&(v_cnt>=351)&&(v_cnt<510)) 
      begin
      _cor = cor8;
		end
	else
   if ((h_cnt>=572)&&(h_cnt<783)&&(v_cnt>=351)&&(v_cnt<510)) 
      begin
      _cor = cor9;
		end
	else
	   begin
		_cor = 12'b0;
		end
end		
		
task raster;
begin
   if (h_cnt==800)
      begin
      h_cnt = 10'b0;
      if (v_cnt==521)
         begin
         v_cnt = 10'b0;
         end
      else
         begin
         v_cnt = v_cnt + 10'b1;
         end
      end
   else
      begin
      h_cnt = h_cnt + 10'b1;
      end
end
endtask

always @(posedge clk_50) begin
   if (!rst_n)
      begin
      clk_25 = 1'b0;
      h_cnt  = 10'b0;
      v_cnt  = 10'b0;
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
      clk_25 = ~clk_25;
      if (clk_25)
        begin
        raster();
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
end

assign hs = _hs;
assign vs = _vs;
assign r_out = _cor[11:8];
assign g_out = _cor[7:4];
assign b_out = _cor[3:0];

endmodule


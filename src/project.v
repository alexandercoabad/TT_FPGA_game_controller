/*
 * Copyright (c) 2025 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in [ 7 ] , ui_in [ 3 : 0 ] , uio_in};

  // VGA signals
  wire hsync;
  wire vsync;
  reg [1:0] R_sig; 
  reg [1:0] G;
  reg [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // Tiny VGA Pmod
  assign uo_out = {hsync, B [ 0 ] , G [ 0 ] , R_sig [ 0 ] , vsync, B [ 1 ] , G [ 1 ] , R_sig [ 1 ] };

  hvsync_generator vga_sync_gen (
      .clk(clk),
      .reset(~rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(video_active),
      .hpos(pix_x),
      .vpos(pix_y)
  );

  // Gamepad Pmod
  wire inp_b, inp_y, inp_select, inp_start, inp_up, inp_down, inp_left, inp_right, inp_a, inp_x, inp_l, inp_r;

  gamepad_pmod_single driver (
      .rst_n(rst_n),
      .clk(clk),
      .pmod_data(ui_in [ 6 ] ),
      .pmod_clk(ui_in [ 5 ] ),
      .pmod_latch(ui_in [ 4 ] ),
      .b(inp_b),
      .y(inp_y),
      .select(inp_select),
      .start(inp_start),
      .up(inp_up),
      .down(inp_down),
      .left(inp_left),
      .right(inp_right),
      .a(inp_a),
      .x(inp_x),
      .l(inp_l),
      .r(inp_r)
  );

  // Colors
  localparam [5:0] BLACK  = {2'b00, 2'b00, 2'b00};
  localparam [5:0] GREEN  = {2'b00, 2'b11, 2'b00};
  localparam [5:0] WHITE  = {2'b11, 2'b11, 2'b11};
  localparam [5:0] RED    = {2'b11, 2'b00, 2'b00};
  localparam [5:0] YELLOW = {2'b11, 2'b11, 2'b00}; 
  localparam [5:0] BLUE   = {2'b00, 2'b00, 2'b11}; 

  // ==========================================================================
  // GLYPH DEFINITIONS (64-bit flat vectors)
  // ==========================================================================
  
  // Gamepad UI Glyphs
  localparam [63:0] A_GLYPH = {
      8'b00111100, 8'b01100110, 8'b11000011, 8'b11111111,
      8'b11000011, 8'b11000011, 8'b11000011, 8'b00000000
  };
  localparam [63:0] LEFT_GLYPH = {
      8'b00010000, 8'b00110000, 8'b01110000, 8'b11111111,
      8'b01110000, 8'b00110000, 8'b00010000, 8'b00000000
  };
  localparam [63:0] RIGHT_GLYPH = {
      8'b00001000, 8'b00001100, 8'b00001110, 8'b11111111,
      8'b00001110, 8'b00001100, 8'b00001000, 8'b00000000
  };
  localparam [63:0] UP_GLYPH = {
      8'b00010000, 8'b00111000, 8'b01111100, 8'b11111110,
      8'b00010000, 8'b00010000, 8'b00010000, 8'b00010000
  };
  localparam [63:0] DOWN_GLYPH = {
      8'b00010000, 8'b00010000, 8'b00010000, 8'b00010000,
      8'b11111110, 8'b01111100, 8'b00111000, 8'b00010000
  };
  localparam [63:0] B_GLYPH = {
      8'b01111100, 8'b01100110, 8'b01100110, 8'b01111100,
      8'b01100110, 8'b01100110, 8'b01111100, 8'b00000000
  };
  localparam [63:0] X_GLYPH = {
      8'b11000011, 8'b01100110, 8'b00111100, 8'b00011000,
      8'b00011000, 8'b00111100, 8'b01100110, 8'b11000011
  };
  localparam [63:0] Y_GLYPH = {
      8'b11000011, 8'b01100110, 8'b00111100, 8'b00011000,
      8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000
  };
  localparam [63:0] L_GLYPH = {
      8'b11100000, 8'b11100000, 8'b11100000, 8'b11100000,
      8'b11100000, 8'b11111110, 8'b11111110, 8'b00000000
  };
  localparam [63:0] R_GLYPH = {
      8'b11111100, 8'b11100110, 8'b11100110, 8'b11111100,
      8'b11111000, 8'b11111100, 8'b11101110, 8'b00000000
  };
  localparam [63:0] SELECT_GLYPH = {
      8'b00011000, 8'b00100100, 8'b01000010, 8'b10000001,
      8'b10000001, 8'b01000010, 8'b00100100, 8'b00011000
  };
  localparam [63:0] START_GLYPH = {
      8'b00011000, 8'b01011010, 8'b10011001, 8'b10011001,
      8'b10011001, 8'b10000001, 8'b01000010, 8'b00111100
  };

  // Font Custom Glyphs for "Let's make some games!" text
  localparam [63:0] CHAR_L = {8'b11000000, 8'b11000000, 8'b11000000, 8'b11000000, 8'b11000000, 8'b11000011, 8'b11111111, 8'b00000000};
  localparam [63:0] CHAR_E = {8'b11111111, 8'b11000000, 8'b11111100, 8'b11000000, 8'b11000000, 8'b11000011, 8'b11111111, 8'b00000000};
  localparam [63:0] CHAR_T = {8'b11111111, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00000000};
  localparam [63:0] CHAR_S = {8'b01111110, 8'b11000011, 8'b11000000, 8'b01111110, 8'b00000011, 8'b11000011, 8'b01111110, 8'b00000000};
  localparam [63:0] CHAR_M = {8'b11000011, 8'b11100111, 8'b11111111, 8'b11011011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b00000000};
  localparam [63:0] CHAR_A = {8'b00111100, 8'b01100110, 8'b11000011, 8'b11111111, 8'b11000011, 8'b11000011, 8'b11000011, 8'b00000000};
  localparam [63:0] CHAR_K = {8'b11000011, 8'b11000110, 8'b11001100, 8'b11111000, 8'b11001100, 8'b11000110, 8'b11000011, 8'b00000000};
  localparam [63:0] CHAR_O = {8'b00111100, 8'b01100110, 8'b11000011, 8'b11000011, 8'b11000011, 8'b01100110, 8'b00111100, 8'b00000000};
  localparam [63:0] CHAR_G = {8'b01111111, 8'b11000000, 8'b11000000, 8'b11001111, 8'b11000011, 8'b11000011, 8'b01111111, 8'b00000000};
  localparam [63:0] CHAR_N = {8'b11000011, 8'b11100011, 8'b11110011, 8'b11011011, 8'b11001111, 8'b11000111, 8'b11000011, 8'b00000000};
  localparam [63:0] CHAR_APOS={8'b00001100, 8'b00001100, 8'b00001000, 8'b00010000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000};
  localparam [63:0] CHAR_EXCL={8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00000000, 8'b00011000, 8'b00011000};
  localparam [63:0] CHAR_SPC ={8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000};

  // ==========================================================================
  // LAYOUT POSITION CONFIGURATIONS
  // ==========================================================================
  
  // Gamepad layout
  localparam LEFT_X  = 64,  LEFT_Y  = 410;
  localparam RIGHT_X = 112, RIGHT_Y = 410;
  localparam UP_X    = 88,  UP_Y    = 386;
  localparam DOWN_X  = 88,  DOWN_Y  = 434;
  localparam Y_X     = 480, Y_Y     = 410;
  localparam X_X     = 504, X_Y     = 386;
  localparam A_X     = 528, A_Y     = 410;
  localparam B_X     = 504, B_Y     = 434;
  localparam L_X     = 64,  L_Y     = 350;
  localparam R_X     = 528, R_Y     = 350;
  localparam SEL_X   = 264, SEL_Y   = 410;
  localparam STRT_X  = 328, STRT_Y  = 410;

  // Global Text coordinate origin adjusted to center entire string safely
  localparam TXT_X = 150, TXT_Y = 248;

  wire left_act  = glyph_active(LEFT_X, LEFT_Y, LEFT_GLYPH);
  wire right_act = glyph_active(RIGHT_X, RIGHT_Y, RIGHT_GLYPH);
  wire up_act    = glyph_active(UP_X, UP_Y, UP_GLYPH);
  wire down_act  = glyph_active(DOWN_X, DOWN_Y, DOWN_GLYPH);
  wire a_act     = glyph_active(A_X, A_Y, A_GLYPH);
  wire b_act     = glyph_active(B_X, B_Y, B_GLYPH);
  wire x_act     = glyph_active(X_X, X_Y, X_GLYPH);
  wire y_act     = glyph_active(Y_X, Y_Y, Y_GLYPH);
  wire l_act     = glyph_active(L_X, L_Y, L_GLYPH);
  wire r_act     = glyph_active(R_X, R_Y, R_GLYPH);
  wire sel_act   = glyph_active(SEL_X, SEL_Y, SELECT_GLYPH);
  wire strt_act  = glyph_active(STRT_X, STRT_Y, START_GLYPH);

  // Text glyph evaluation structure: "Let's make some games!"
  wire t_l    = glyph_active(TXT_X + 0,   TXT_Y, CHAR_L);
  wire t_e1   = glyph_active(TXT_X + 16,  TXT_Y, CHAR_E);
  wire t_t1   = glyph_active(TXT_X + 32,  TXT_Y, CHAR_T);
  wire t_apos = glyph_active(TXT_X + 42,  TXT_Y, CHAR_APOS); // Shifted left near the 'T'
  wire t_s1   = glyph_active(TXT_X + 56,  TXT_Y, CHAR_S);    // Shifted left with tight tracking
  wire t_sp1  = glyph_active(TXT_X + 72,  TXT_Y, CHAR_SPC);
  wire t_m    = glyph_active(TXT_X + 88,  TXT_Y, CHAR_M);
  wire t_a1   = glyph_active(TXT_X + 104, TXT_Y, CHAR_A);
  wire t_k    = glyph_active(TXT_X + 120, TXT_Y, CHAR_K);
  wire t_e2   = glyph_active(TXT_X + 136, TXT_Y, CHAR_E);
  wire t_sp2  = glyph_active(TXT_X + 152, TXT_Y, CHAR_SPC);
  wire t_s2   = glyph_active(TXT_X + 168, TXT_Y, CHAR_S);
  wire t_o    = glyph_active(TXT_X + 184, TXT_Y, CHAR_O);
  wire t_m2   = glyph_active(TXT_X + 200, TXT_Y, CHAR_M);
  wire t_e3   = glyph_active(TXT_X + 216, TXT_Y, CHAR_E);
  wire t_sp3  = glyph_active(TXT_X + 232, TXT_Y, CHAR_SPC);
  wire t_g    = glyph_active(TXT_X + 248, TXT_Y, CHAR_G);
  wire t_a2   = glyph_active(TXT_X + 264, TXT_Y, CHAR_A);
  wire t_m3   = glyph_active(TXT_X + 280, TXT_Y, CHAR_M);
  wire t_e4   = glyph_active(TXT_X + 296, TXT_Y, CHAR_E);
  wire t_s3   = glyph_active(TXT_X + 312, TXT_Y, CHAR_S);
  wire t_excl = glyph_active(TXT_X + 328, TXT_Y, CHAR_EXCL);

  wire text_active = t_l | t_e1 | t_t1 | t_apos | t_s1 | t_sp1 | t_m | t_a1 | t_k | t_e2 |
                     t_sp2 | t_s2 | t_o | t_m2 | t_e3 | t_sp3 | t_g | t_a2 | t_m3 | t_e4 | t_s3 | t_excl;

  // ==========================================================================
  // BOUNDED SQUARE CONTROL ENGINE
  // ==========================================================================
  reg [9:0] block_x;
  reg [8:0] block_y;
  reg [5:0] block_color;
  reg [21:0] move_tick;
  reg        box_is_red; 

  wire block_moving = inp_up | inp_down | inp_left | inp_right;

  always @(posedge clk) begin
    if (~rst_n || inp_r) begin
      block_x     <= 10'd304;
      block_y     <= 9'd112; 
      block_color <= WHITE; 
      move_tick   <= 22'b0;
      box_is_red  <= 1'b0; 
    end else begin
      move_tick <= move_tick + 1'b1;

      if (inp_l) begin
        box_is_red <= 1'b1;
      end

      if (inp_x)      block_color <= BLUE;   
      else if (inp_y) block_color <= GREEN;  
      else if (inp_a) block_color <= RED;    
      else if (inp_b) block_color <= YELLOW; 

      if (move_tick == 22'b0 && block_moving) begin
        if (inp_up    && (block_y > 9'd16))  block_y <= block_y - 9'd16;
        if (inp_down  && (block_y < 9'd208)) block_y <= block_y + 9'd16; 
        if (inp_left  && (block_x > 10'd16))  block_x <= block_x - 10'd16;
        if (inp_right && (block_x < 10'd608)) block_x <= block_x + 10'd16; 
      end
    end
  end

  // Render Checks (16x16 pixels square block)
  wire block_act = (pix_x >= block_x) && (pix_x < block_x + 16) && 
                   (pix_y >= block_y) && (pix_y < block_y + 16);
                   
  // Complete 4-sided Arena Bounding Box definition
  wire top_border    = (pix_y == 16)  && (pix_x >= 16)  && (pix_x <= 624);
  wire bottom_border = (pix_y == 224) && (pix_x >= 16)  && (pix_x <= 624);
  wire left_border   = (pix_x == 16)  && (pix_y >= 16)  && (pix_y <= 224);
  wire right_border  = (pix_x == 624) && (pix_y >= 16)  && (pix_y <= 224);
  
  wire arena_border  = top_border | bottom_border | left_border | right_border;
  wire [5:0] arena_color = box_is_red ? RED : WHITE;

  // ==========================================================================
  // RGB PIPELINE PRIORITY MULTIPLEXER
  // ==========================================================================
  wire glyphs_active = left_act | right_act | up_act | down_act | a_act | b_act |
                       x_act | y_act | l_act | r_act | sel_act | strt_act;

  always @(posedge clk) begin
    if (~rst_n) begin
      R_sig <= 0; G <= 0; B <= 0;
    end else begin
      if (video_active) begin
        if (block_act) begin
          {R_sig, G, B} <= block_color;
        end else if (arena_border) begin
          {R_sig, G, B} <= arena_color;
        end else if (text_active) begin
          {R_sig, G, B} <= WHITE;
        end else if (glyphs_active) begin
          {R_sig, G, B} <= ((left_act & inp_left) | (right_act & inp_right) | 
                        (up_act & inp_up) | (down_act & inp_down) |
                        (a_act & inp_a) | (b_act & inp_b) |
                        (x_act & inp_x) | (y_act & inp_y) |
                        (l_act & inp_l) | (r_act & inp_r) |
                        (sel_act & inp_select) | (strt_act & inp_start)) ? GREEN : WHITE;
        end else begin
          {R_sig, G, B} <= BLACK;
        end
      end else begin
        {R_sig, G, B} <= 0;
      end
    end
  end

  // Scaled glyph activation function (2x size conversion)
  function glyph_active;
    input [9:0] x0, y0;
    input [63:0] glyph;
    reg [9:0] x_rel, y_rel;
    reg [7:0] row;
    begin
      if ((pix_x >= x0) && (pix_x < x0 + 16) && (pix_y >= y0) && (pix_y < y0 + 16)) begin
        x_rel = (pix_x - x0) >> 1;
        y_rel = (pix_y - y0) >> 1;
        
        row = glyph [ ((7 - y_rel) * 8) +: 8 ] ;
        glyph_active = row [ 7 - x_rel ] ;
      end else begin
        glyph_active = 0;
      end
    end
  endfunction

endmodule
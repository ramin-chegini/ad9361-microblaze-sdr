`timescale 1ns/100ps

module axi_ad9361_dev_if_idelay (
// physical interface (receive)
input rx_frame_in_p,
input rx_frame_in_n,
input [5:0] rx_data_in_p,
input [5:0] rx_data_in_n,
// physical interface (transmit)
output tx_clk_out_p,
output tx_clk_out_n,
output tx_frame_out_p,
output tx_frame_out_n,
output [5:0] tx_data_out_p,
output [5:0] tx_data_out_n,
// internal clock
input data_clk,
input clk200,
input clk100,
input rstn,
// receive data path interface
output reg adc_valid,
output reg [11:0] adc_data_i1,
output reg [11:0] adc_data_q1,
output reg [11:0] adc_data_i2,
output reg [11:0] adc_data_q2,
output reg adc_status,
input adc_r1_mode,
// transmit data path interface
input dac_valid,
input [11:0] dac_data_i1,
input [11:0] dac_data_q1,
input [11:0] dac_data_i2,
input [11:0] dac_data_q2,
input dac_r1_mode,
//output [63:0] chip_data,
// idelay
input [6:0] idly_en_vtc,
input [6:0] idly_load,
input [8:0] idly_d
);
// internal registers
reg [ 5:0]  rx_data_n     = 'd0;
reg         rx_frame_n    = 'd0;
reg [11:0]  rx_data       = 'd0;
reg [ 1:0]  rx_frame      = 'd0;
reg [11:0]  rx_data_d     = 'd0;
reg [ 1:0]  rx_frame_d    = 'd0;
reg         rx_error_r1   = 'd0;
reg         rx_valid_r1   = 'd0;
reg [11:0]  rx_data_i_r1  = 'd0;
reg [11:0]  rx_data_q_r1  = 'd0;
reg         rx_error_r2   = 'd0;
reg         rx_valid_r2   = 'd0;
reg [11:0]  rx_data_i1_r2 = 'd0;
reg [11:0]  rx_data_q1_r2 = 'd0;
reg [11:0]  rx_data_i2_r2 = 'd0;
reg [11:0]  rx_data_q2_r2 = 'd0;
reg [ 2:0]  tx_data_cnt   = 'd0;
reg [11:0]  tx_data_i1_d  = 'd0;
reg [11:0]  tx_data_q1_d  = 'd0;
reg [11:0]  tx_data_i2_d  = 'd0;
reg [11:0]  tx_data_q2_d  = 'd0;
reg         tx_frame      = 'd0;
reg [ 5:0]  tx_data_p     = 'd0;
reg [ 5:0]  tx_data_n     = 'd0;
// internal signals
wire    [ 3:0]  rx_frame_s;
wire    [ 3:0]  tx_data_sel_s;
wire    [ 5:0]  rx_data_ibuf_s;
wire    [ 5:0]  rx_data_idelay;
wire    [ 5:0]  rx_data_p_s;
wire    [ 5:0]  rx_data_n_s;
wire            rx_frame_ibuf_s;
wire            rx_frame_idelay;
wire            rx_frame_p_s;
wire            rx_frame_n_s;
wire    [ 5:0]  tx_data_oddr_s;
wire            tx_frame_oddr_s;
wire            tx_clk_oddr_s;
genvar          l_inst;
wire            rdy;
//receive data path interface
assign rx_frame_s = {rx_frame_d, rx_frame};
always @(posedge data_clk)
  begin
    rx_data_n   <=rx_data_n_s;
    rx_frame_n  <=rx_frame_n_s;
    rx_data     <={rx_data_n,rx_data_p_s};
    rx_frame    <={rx_frame_n,rx_frame_p_s};
    rx_data_d   <=rx_data;
    rx_frame_d  <=rx_frame;
  end
//receive data path for single rf, frame is expected to qualify i/q msb only
always @(posedge data_clk)
  begin
    rx_error_r1<=((rx_frame_s==4'b1100)||(rx_frame_s==4'b0011))?1'b0:1'b1;
    rx_valid_r1<=(rx_frame_s==4'b1100)?1'b1:1'b0;
    if (rx_frame_s==4'b1100)
      begin
        rx_data_i_r1<={rx_data_d[11:6],rx_data[11:6]};
        rx_data_q_r1<={rx_data_d[ 5:0],rx_data[ 5:0]};
      end
  end
//receive data path for dual rf, frame is expected to qualify i/q msb and lsb for rf-1 only
always @(posedge data_clk)
  begin
    rx_error_r2<=((rx_frame_s==4'b1111)||(rx_frame_s==4'b1100)||(rx_frame_s==4'b0000)||(rx_frame_s== 4'b0011))?1'b0:1'b1;
    rx_valid_r2<=(rx_frame_s==4'b0000)?1'b1:1'b0;
    if(rx_frame_s==4'b1111)
      begin
        rx_data_i1_r2<={rx_data_d[11:6],rx_data[11:6]};
        rx_data_q1_r2<={rx_data_d[ 5:0],rx_data[ 5:0]};
      end
    if(rx_frame_s==4'b0000)
      begin
        rx_data_i2_r2<={rx_data_d[11:6],rx_data[11:6]};
        rx_data_q2_r2<={rx_data_d[ 5:0],rx_data[ 5:0]};
      end
  end
//receive data path mux
always @(posedge data_clk)
  begin
    if(adc_r1_mode==1'b1)
      begin
        adc_valid   <=rx_valid_r1;
        adc_data_i1 <=rx_data_i_r1;
        adc_data_q1 <=rx_data_q_r1;
        adc_data_i2 <=12'd0;
        adc_data_q2 <=12'd0;
        adc_status  <=~rx_error_r1;
      end
    else
      begin
        adc_valid   <=rx_valid_r2;
        adc_data_i1 <=rx_data_i1_r2;
        adc_data_q1 <=rx_data_q1_r2;
        adc_data_i2 <=rx_data_i2_r2;
        adc_data_q2 <=rx_data_q2_r2;
        adc_status  <=~rx_error_r2;
      end
  end

// transmit data path mux (reverse of what receive does above)
// the count simply selets the data muxing on the ddr outputs
//------------------data format 1t--------------------------
//valid :~~~ ___ ~~~ ___ ~~~ ___ ~~~ ___                  //
//datai :i1      i1      i1      i1                       //
//dataq :q1      q1      q1      q1                       //
//cnt   :    100 101 100 101 100 101 100                  //
//------------------data format 2t--------------------------
//valid :~~~ ___ ___ ___ ~~~ ___ ___ ___ ~~~ ___ ___ ___  //
//datai :i1              i1              i1               //
//dataq :q1              q1              q1               //
//datai :i2              i2              i2               //
//dataq :q2              q2              q2               //
//cnt   :    100 101 110 111 100 101 110 111 100 101 110  //
//----------------------------------------------------------
assign tx_data_sel_s={tx_data_cnt[2],dac_r1_mode,tx_data_cnt[1:0]};
always @(posedge data_clk)
  begin
    if (dac_valid)
      begin
        tx_data_cnt<=3'b100;
        tx_data_i1_d<=dac_data_i1;
        tx_data_q1_d<=dac_data_q1;
        tx_data_i2_d<=dac_data_i2;
        tx_data_q2_d<=dac_data_q2;
       end
    else if(tx_data_cnt[2]==1'b1)
      tx_data_cnt<=tx_data_cnt+1'b1;
    case (tx_data_sel_s)
      4'b1101:
        begin
          tx_frame  <=1'b0;
          tx_data_p <=tx_data_i1_d[ 5:0];
          tx_data_n <=tx_data_q1_d[ 5:0];
        end
      4'b1100:
        begin
          tx_frame  <=1'b1;
          tx_data_p <=tx_data_i1_d[11:6];
          tx_data_n <=tx_data_q1_d[11:6];
        end
      4'b1011:
        begin
          tx_frame  <=1'b0;
          tx_data_p <=tx_data_i2_d[ 5:0];
          tx_data_n <=tx_data_q2_d[ 5:0];
        end
      4'b1010:
        begin
          tx_frame  <=1'b0;
          tx_data_p <=tx_data_i2_d[11:6];
          tx_data_n <=tx_data_q2_d[11:6];
        end
      4'b1001:
        begin
          tx_frame  <=1'b1;
          tx_data_p <=tx_data_i1_d[ 5:0];
          tx_data_n <=tx_data_q1_d[ 5:0];
        end
      4'b1000:
        begin
          tx_frame  <=1'b1;
          tx_data_p <=tx_data_i1_d[11:6];
          tx_data_n <=tx_data_q1_d[11:6];
        end
      default:
        begin
          tx_frame  <=1'b0;
          tx_data_p <=6'd0;
          tx_data_n <=6'd0;
        end
    endcase
  end
// receive data interface, ibuf  -> iddr
IDELAYCTRL #(
      .SIM_DEVICE("ULTRASCALE")  // Must be set to "ULTRASCALE" 
   )
   IDELAYCTRL_1 (
      .RDY(rdy),       // 1-bit output: Ready output
      .REFCLK(clk200), // 1-bit input: Reference clock input
      .RST(~rstn)        // 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
         );              // REFCLK.

wire [8:0] CNTVALUEOUT[6:0]; 
wire [8:0] CNTVALUEIN; 
wire  [6:0] idly_enn;      
         
generate
for (l_inst=0;l_inst<=5;l_inst=l_inst+1)
begin:g_rx_data
IBUFDS i_rx_data_ibuf(.I(rx_data_in_p[l_inst]),.IB(rx_data_in_n[l_inst]),.O(rx_data_ibuf_s[l_inst]));

 IDELAYE3 #(
    .CASCADE("NONE"),          // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
    .DELAY_FORMAT("TIME"),     // Units of the DELAY_VALUE (COUNT, TIME)
    .DELAY_SRC("IDATAIN"),     // Delay input (DATAIN, IDATAIN)
    .DELAY_TYPE("VAR_LOAD"),      // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
    .DELAY_VALUE(0),           // Input delay value setting
    .IS_CLK_INVERTED(1'b0),    // Optional inversion for CLK
    .IS_RST_INVERTED(1'b0),    // Optional inversion for RST
    .REFCLK_FREQUENCY(200.0),  // IDELAYCTRL clock input frequency in MHz (200.0-2667.0)
    .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                               // ULTRASCALE_PLUS_ES2)
    .UPDATE_MODE("ASYNC")      // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
 )
 IDELAYE3_D (
    .CASC_OUT( ),       // 1-bit output: Cascade delay output to ODELAY input cascade
    .CNTVALUEOUT(CNTVALUEOUT[l_inst] ), // 9-bit output: Counter value output
    .DATAOUT(rx_data_idelay[l_inst]),         // 1-bit output: Delayed data output
    .CASC_IN( ),         // 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
    .CASC_RETURN( ), // 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
    .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
    .CLK(clk100),                 // 1-bit input: Clock input
    .CNTVALUEIN(idly_d),   // 9-bit input: Counter value input
    .DATAIN( ),           // 1-bit input: Data input from the logic
    .EN_VTC(idly_en_vtc[l_inst] ),           // 1-bit input: Keep delay constant over VT
    .IDATAIN(rx_data_ibuf_s[l_inst] ),         // 1-bit input: Data input from the IOBUF
    .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
    .LOAD(idly_load[l_inst] ),               // 1-bit input: Load DELAY_VALUE input
    .RST(1'b0)                  // 1-bit input: Asynchronous Reset to the DELAY_VALUE
   );

   IDDRE1 #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
      .IS_CB_INVERTED(1'b0),          // Optional inversion for CB
      .IS_C_INVERTED(1'b0)            // Optional inversion for C
   )
   i_rx_data_iddr (
      .Q1(rx_data_p_s[l_inst]   ), // 1-bit output: Registered parallel output 1
      .Q2(rx_data_n_s[l_inst]  ), // 1-bit output: Registered parallel output 2
      .C(data_clk),   // 1-bit input: High-speed clock
      .CB(~data_clk), // 1-bit input: Inversion of High-speed clock C
      .D(rx_data_idelay[l_inst] ),   // 1-bit input: Serial Data Input
      .R(1'b0)    // 1-bit input: Active High Async Reset
   );
end endgenerate
// receive frame interface, ibuf  -> iddr
IBUFDS i_rx_frame_ibuf (.I(rx_frame_in_p),.IB(rx_frame_in_n),.O(rx_frame_ibuf_s));

   IDELAYE3 #(
      .CASCADE("NONE"),          // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
      .DELAY_FORMAT("TIME"),     // Units of the DELAY_VALUE (COUNT, TIME)
      .DELAY_SRC("IDATAIN"),     // Delay input (DATAIN, IDATAIN)
      .DELAY_TYPE("VAR_LOAD"),      // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
      .DELAY_VALUE(0),           // Input delay value setting
      .IS_CLK_INVERTED(1'b0),    // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),    // Optional inversion for RST
      .REFCLK_FREQUENCY(200.0),  // IDELAYCTRL clock input frequency in MHz (200.0-2667.0)
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                 // ULTRASCALE_PLUS_ES2)
      .UPDATE_MODE("ASYNC")      // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
   )
   IDELAYE3_F (
      .CASC_OUT(),       // 1-bit output: Cascade delay output to ODELAY input cascade
      .CNTVALUEOUT(CNTVALUEOUT[6]), // 9-bit output: Counter value output
      .DATAOUT(rx_frame_idelay),         // 1-bit output: Delayed data output
      .CASC_IN(1'b0),         // 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
      .CASC_RETURN(1'b0), // 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
      .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
      .CLK(clk100),                 // 1-bit input: Clock input
      .CNTVALUEIN(idly_d),   // 9-bit input: Counter value input
      .DATAIN( ),           // 1-bit input: Data input from the logic
      .EN_VTC(idly_en_vtc[6]),           // 1-bit input: Keep delay constant over VT
      .IDATAIN(rx_frame_ibuf_s),         // 1-bit input: Data input from the IOBUF
      .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
      .LOAD(idly_load[6] ),               // 1-bit input: Load DELAY_VALUE input
      .RST(1'b0)                  // 1-bit input: Asynchronous Reset to the DELAY_VALUE
   );
   
  IDDRE1 #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
      .IS_CB_INVERTED(1'b0),          // Optional inversion for CB
      .IS_C_INVERTED(1'b0)            // Optional inversion for C
   )
   i_rx_frame_iddr (
      .Q1(rx_frame_p_s), // 1-bit output: Registered parallel output 1
      .Q2(rx_frame_n_s), // 1-bit output: Registered parallel output 2
      .C(data_clk),   // 1-bit input: High-speed clock
      .CB(~data_clk), // 1-bit input: Inversion of High-speed clock C
      .D(rx_frame_idelay),   // 1-bit input: Serial Data Input
      .R(1'b0)    // 1-bit input: Active High Async Reset
   );

// transmit data interface, oddr -> obuf
generate
for (l_inst=0;l_inst<=5;l_inst=l_inst+1)
begin: g_tx_data
   ODDRE1 #(
      .IS_C_INVERTED(1'b0),      // Optional inversion for C
      .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
      .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                 // ULTRASCALE_PLUS_ES2, VERSAL, VERSAL_ES1, VERSAL_ES2)
      .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
   )
   i_tx_data_oddr (
      .Q(tx_data_oddr_s[l_inst]),   // 1-bit output: Data output to IOB
      .C(data_clk),   // 1-bit input: High-speed clock input
      .D1(tx_data_p[l_inst]), // 1-bit input: Parallel data input 1
      .D2(tx_data_n[l_inst]), // 1-bit input: Parallel data input 2
      .SR(1'b0)  // 1-bit input: Active High Async Reset
   );
OBUFDS i_tx_data_obuf (.I(tx_data_oddr_s[l_inst]),.O(tx_data_out_p[l_inst]),.OB(tx_data_out_n[l_inst]));
end endgenerate
// transmit frame interface, oddr -> obuf
  ODDRE1 #(
      .IS_C_INVERTED(1'b0),      // Optional inversion for C
      .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
      .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                 // ULTRASCALE_PLUS_ES2, VERSAL, VERSAL_ES1, VERSAL_ES2)
      .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
   )
   i_tx_frame_oddr (
      .Q(tx_frame_oddr_s),   // 1-bit output: Data output to IOB
      .C(data_clk),   // 1-bit input: High-speed clock input
      .D1(tx_frame), // 1-bit input: Parallel data input 1
      .D2(tx_frame), // 1-bit input: Parallel data input 2
      .SR(1'b0)  // 1-bit input: Active High Async Reset
   );
OBUFDS i_tx_frame_obuf (.I(tx_frame_oddr_s),.O(tx_frame_out_p),.OB(tx_frame_out_n));
// transmit clock interface, oddr -> obuf
  ODDRE1 #(
      .IS_C_INVERTED(1'b0),      // Optional inversion for C
      .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
      .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                 // ULTRASCALE_PLUS_ES2, VERSAL, VERSAL_ES1, VERSAL_ES2)
      .SRVAL(1'b0)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
   )
   i_tx_clk_oddr (
      .Q(tx_clk_oddr_s),   // 1-bit output: Data output to IOB
      .C(data_clk),   // 1-bit input: High-speed clock input
      .D1(1'b0), // 1-bit input: Parallel data input 1
      .D2(1'b1), // 1-bit input: Parallel data input 2
      .SR(1'b0)  // 1-bit input: Active High Async Reset
   );
OBUFDS i_tx_clk_obuf (.I(tx_clk_oddr_s),.O(tx_clk_out_p),.OB(tx_clk_out_n));
endmodule

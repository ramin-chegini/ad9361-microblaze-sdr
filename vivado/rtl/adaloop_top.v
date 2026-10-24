`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/21 15:18:47
// Design Name: 
// Module Name: adaloop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adaloop_top(
  //global
//  input          sys_clk_p,
//  input          sys_clk_n,
  input          Clk_in_100M,
  input          Calib_En,
  input          MB_Core_Resetn,
  output         fclk_100M_Out,
  //input          UART_rxd,
  //output         UART_txd,
  //output         led,
  //ad9361
  output         spi_csn,
  output         spi_clk,
  output         spi_mosi,
  input          spi_miso,
  inout          sync_in,
  inout          en_agc,
  inout          enable,
  inout          resetb,
  inout          txnrx,
  input          clk_out,
  output [3:0]   ctrl_in,
  input  [7:0]   ctrl_out,
  input          rx_clk_in_p,
  input          rx_clk_in_n,
  input  [5:0]   rx_data_in_n,
  input  [5:0]   rx_data_in_p,
  input          rx_frame_in_n,
  input          rx_frame_in_p,
  output         tx_clk_out_n,
  output         tx_clk_out_p,
  output [5:0]   tx_data_out_n,
  output [5:0]   tx_data_out_p,
//  input          aclken,
  input          CfgSET_Trig,
  output[1:0]    Interrupt_Ack,
  input [7:0]    PW, //Pulse Width
  input [7:0]    PRI,// Pulse Period
  input  [31:0]  sdr_cmd_param,
  input  [31:0]  sdr_data_low,
  input  [31:0]  sdr_data_high,
  output         tx_frame_out_n,
  output         tx_frame_out_p,
  //fmc9361
  output         cdcm_spi_clk,
  output         cdcm_spi_cs,
  output         cdcm_spi_mosi,
  input          cdcm_spi_miso,
  output         cdcm_sync,
  inout          ref_select,
  inout          ref_select2,
  inout          fdd_tdd_sel,
  inout          trx_sw,
  inout          gpio_scl,
  inout          gpio_sda,
  input          pps_1s
  
  //output         rxd_gps,
  //input          txd_gps
    );


  wire         UART_rxd;
  wire         UART_txd;
  
  wire          up_rack;
  wire [15:0]   up_raddr;
  wire [31:0]   up_rdata;
  wire          up_rreq;
  wire          up_wack;
  wire [15:0]   up_waddr;
  wire [31:0]   up_wdata;
  wire          up_wreq;
  
  wire          spi0_miso;
  wire          spi0_mosi;
  wire          spi0_sclk;
  wire          spi0_ss0;
  wire          spi0_ss1;
  wire          spi0_ss2;
  wire          spi1_miso;
  wire          spi1_mosi;
  wire          spi1_sclk;
  wire          spi1_ss0;
  wire          spi1_ss1;
  wire          spi1_ss2;
  wire          iic_1_scl_i;
  wire          iic_1_scl_o;
  wire          iic_1_scl_t;
  wire          iic_1_sda_i;
  wire          iic_1_sda_o;
  wire          iic_1_sda_t;
  wire          fclk_200m;
  wire          fclk_100m;
  wire          fclk_reset0_n;
  wire          axi_rd_ack;
  wire          axi_rd_stb;
  wire          axi_wr_ack;
  wire          axi_wr_stb;
  
  wire [9:0]   gpio_tri_i;
  wire [9:0]   gpio_tri_o;
  wire [9:0]   gpio_tri_t;  
  wire            BUFG_CE;
  
  wire          interrupt;
  wire          tx_clk_out;


  system system_i(
    .GPIO_tri_i    (gpio_tri_i),
    .GPIO_tri_o    (gpio_tri_o),
    .GPIO_tri_t    (gpio_tri_t),
    .IIC_scl_i     (iic_1_scl_i),
    .IIC_scl_o     (iic_1_scl_o),
    .IIC_scl_t     (iic_1_scl_t),
    .IIC_sda_i     (iic_1_sda_i),
    .IIC_sda_o     (iic_1_sda_o),
    .IIC_sda_t     (iic_1_sda_t),
    .Interrupt_Ack (Interrupt_Ack),
    .UART_rxd      (UART_rxd),
    .UART_txd      (UART_txd),
    .fclk_100m     (fclk_100m),
    .fclk_200m     (fclk_200m),
    .fclk_reset0_n (fclk_reset0_n),
    .reset_rtl_0   (MB_Core_Resetn),
//    .reset_rtl_0   (1'b1),
    .spi0_miso_i   (spi0_miso),
    .spi0_mosi_o   (spi0_mosi),
    .spi0_sclk_o   (spi0_sclk),
    .ss_o_0        ({spi0_ss1,spi0_ss0}),
//    .sys_clk_n     (sys_clk_n),
//    .sys_clk_p     (sys_clk_p),
    .Clk_in_100M     (Clk_in_100M),
    .temp_out      (),
    .interrupt     (interrupt),
    .up_rack       (up_rack),
    .up_raddr      (up_raddr),
    .up_rdata      (up_rdata),
    .up_rreq       (up_rreq),
    .up_wack       (up_wack),
    .up_waddr      (up_waddr),
    .up_wdata      (up_wdata),
    .up_wreq       (up_wreq));
           
  // gpio
  ad_iobuf #(.DATA_WIDTH(10)) i_iobuf1 (
    .dio_t (gpio_tri_t[9:0]),
    .dio_i (gpio_tri_o[9:0]),
    .dio_o (gpio_tri_i[9:0]),
    .dio_p ({
    cdcm_sync   ,//9
    txnrx       ,//8
    sync_in     ,//7
    en_agc      ,//6
    ref_select2 ,//5
    ref_select  ,//4
    fdd_tdd_sel ,//3
    trx_sw      ,//2
    enable      ,//1
    resetb       //0
  }));

  ad_iobuf #(.DATA_WIDTH(2)) i2c_iobuf (
    .dio_t ({iic_1_scl_t ,iic_1_sda_t }),
    .dio_i ({iic_1_scl_o ,iic_1_sda_o }),
    .dio_o ({iic_1_scl_i ,iic_1_sda_i }),
    .dio_p ({gpio_scl,gpio_sda})
  );
  
  // spi_warper
  assign spi_csn       = spi0_ss0;
  assign spi_clk       = spi0_sclk;
  assign spi_mosi      = spi0_mosi;
  
  assign cdcm_spi_clk  = spi0_sclk;
  assign cdcm_spi_mosi = spi0_mosi;
  assign cdcm_spi_cs   = spi0_ss1;
  assign fclk_100M_Out = fclk_100m;
  assign Interrupt_Ack  = Interrupt_Ack;

  assign spi0_miso = (!spi0_ss0)?spi_miso:
                   (!spi0_ss1)?cdcm_spi_miso:1'b1;

  //register define
  wire [31:0] sdr_info={16'h6000}; // ad9361_id - wr_rdn - cmd_num
  wire        mtime_start;
  wire        adc_status;
  wire [11:0] phase;
  wire [6:0]  idly_en_vtc;
  wire [6:0]  idly_load;
  wire [8:0]  idly_d;
  wire [ 1:0] pps_select;
  wire [31:0] clock_1pps;
  wire [3:0]  rf_mode;
  
  wire [31:0]  irq_ctrl;

//  wire [31:0] sdr_cmd_param;
//  wire [31:0] sdr_data_low;
//  wire [31:0] sdr_data_high;
  
  axi_lite_drv axi_lite_drv(
    .axi_gp_clk       (fclk_100m    ),//global
    .axi_rst_n        (fclk_reset0_n),
    //register
    .up_rack          (up_rack      ),
    .up_raddr         (up_raddr     ),
    .up_rdata         (up_rdata     ),
    .up_rreq          (up_rreq      ),
    .up_wack          (up_wack      ),
    .up_waddr         (up_waddr     ),
    .up_wdata         (up_wdata     ),
    .up_wreq          (up_wreq      ),
    .mtime_start      (mtime_start  ),//register out
    .rf_mode          (rf_mode      ),
    .phase            (phase        ),
    .idly_en_vtc      (idly_en_vtc  ),
    .idly_load        (idly_load    ),
    .idly_d           (idly_d       ),
    .pps_select       (pps_select   ),
    .clock_1pps       (clock_1pps   ),
    .rf1_ctrl_in      (ctrl_in      ),
    .BUFG_CE          (BUFG_CE      ),
    
    .irq_ctrl         (irq_ctrl),
    
    .interrupt        (interrupt),
    
    .CfgSET_Trig      (CfgSET_Trig),
    .sdr_cmd_param    (sdr_cmd_param),
    .sdr_data_low     (sdr_data_low),
    .sdr_data_high    (sdr_data_high),

    .sdr_info         (sdr_info     ),//register in
    .adc_status       (adc_status   ),
    .rf1_ctrl_out     (ctrl_out     )
        
  );
  
  // rx clk 
  wire          rx_clk_in;
  wire          data_clk1;

  IBUFDS IBUFDS_inst (
    .O  (rx_clk_in),   // 1-bit output: Buffer output
    .I  (rx_clk_in_p),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
    .IB (rx_clk_in_n)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
  );
  
  // BUFGCE  data_clk1  ctrl
  BUFGCE #(
    .CE_TYPE("SYNC"),      // ASYNC, HARDSYNC, SYNC
    .IS_CE_INVERTED(1'b0), // Programmable inversion on CE
    .IS_I_INVERTED(1'b0)   // Programmable inversion on I
   )
  BUFGCE_inst (
    .O(data_clk1),   // 1-bit output: Buffer
    .CE(BUFG_CE), // 1-bit input: Buffer enable
    .I(rx_clk_in)    // 1-bit input: Buffer
   );
    
  //DDS

  reg phase_en1;
  reg [1:0] cnt1;
  reg [11:0] phase1;
  
  always @ (posedge data_clk1 or negedge mtime_start)
  if(!mtime_start)
    begin
      cnt1<=2'd0;
      phase1<=12'd0;phase_en1<=1'b0;
    end
  else
    begin
      cnt1<=cnt1+1'b1;
      if(cnt1==2'd0)
        begin phase_en1<=1'b1;phase1<=phase1+phase;end
      else phase_en1<=1'b0;
    end
    
  wire [31:0] m_tdata1;
  wire        dds_en1;
//  wire        aclken;
  
//  dds1 dds1 (
//    .aclk                 (data_clk1  ),// input wire aclk
//    .aclken               (aclken), 
//    .s_axis_phase_tvalid  (phase_en1  ),// input wire s_axis_phase_tvalid
//    .s_axis_phase_tdata   (phase1     ),// input wire [15 : 0] s_axis_phase_tdata
//    .m_axis_data_tvalid   (dds_en1    ),// output wire m_axis_data_tvalid
//    .m_axis_data_tdata    (m_tdata1   ) // output wire [31 : 0] m_axis_data_tdata
//  );

  reg dac_valid;
  reg [11:0] dac_data_i1;
  reg [11:0] dac_data_q1;
  reg [11:0] dac_data_i2;
  reg [11:0] dac_data_q2;
  // with clk =250MHz
//  localparam integer PULSE_WIDTH_CYCLES = 10;   //  100ns
//  localparam integer PULSE_WIDTH_CYCLES = 25;   //  100ns
//  localparam integer PERIOD_CYCLES      = 80;  // 320ns
//  localparam integer PERIOD_CYCLES      = 155;  // 620ns
  reg [7:0] counter = 0;  
//  wire [5:0] counter_vio = 0;  
  reg pulse_out = 0; 
  reg [11:0] dac_data_i1_1;
  reg [11:0] dac_data_q1_1;
  reg [11:0] dac_data_i2_2;
  reg [11:0] dac_data_q2_2;     
  
  wire adc_valid;
  wire [11:0] adc_data_i1,adc_data_q1;
  wire [11:0] adc_data_i2,adc_data_q2;

  always @ (posedge data_clk1 or negedge mtime_start or negedge fclk_reset0_n)
  if(!mtime_start || !fclk_reset0_n)
    begin
      dac_valid  <=1'b0;
      dac_data_i1<=12'd0;
      dac_data_q1<=12'd0;
      dac_data_i2<=12'd0;
      dac_data_q2<=12'd0;
    end
  else
    begin
      case(rf_mode)
        4'd0 :begin
                dac_valid  <=phase_en1;
                dac_data_i1<=12'd0;
                dac_data_q1<=12'd0;
                dac_data_i2<=12'd0;
                dac_data_q2<=12'd0;
              end
        4'd1 :begin
                dac_valid  <=phase_en1;
                dac_data_i1<=m_tdata1[11:0];
                dac_data_q1<=m_tdata1[27:16];
                dac_data_i2<=m_tdata1[11:0];
                dac_data_q2<=m_tdata1[27:16];
              end
        4'd2 :begin
                dac_valid  <=adc_valid;
                dac_data_i1<=adc_data_i1;
                dac_data_q1<=adc_data_q1;
                dac_data_i2<=adc_data_i2;
                dac_data_q2<=adc_data_q2;
              end
        4'd3 :begin
                dac_valid  <=adc_valid;
                dac_data_i1<=adc_data_i2;
                dac_data_q1<=adc_data_q2;
                dac_data_i2<=adc_data_i1;
                dac_data_q2<=adc_data_q1;
              end
        4'd4 :begin
                dac_valid  <=phase_en1;
                dac_data_i1<=m_tdata1[11:0];
                dac_data_q1<=m_tdata1[27:16];
                dac_data_i2<=12'd0;
                dac_data_q2<=12'd0;
              end
        4'd5 :begin
                dac_valid  <=phase_en1;
                dac_data_i1<=12'd0;
                dac_data_q1<=12'd0;
                dac_data_i2<=m_tdata1[11:0];
                dac_data_q2<=m_tdata1[27:16];
              end
        default:
              begin
                dac_valid  <=phase_en1;
                dac_data_i1<=12'd0;
                dac_data_q1<=12'd0;
                dac_data_i2<=12'd0;
                dac_data_q2<=12'd0;
              end
      endcase
    end
    
  // RF1
  wire dac_r1_mode=1'b0;
  wire adc_r1_mode=1'b0;
  
  axi_ad9361_dev_if_idelay axi_ad9361_rf1 (
    .rx_frame_in_p  (rx_frame_in_p  ),
    .rx_frame_in_n  (rx_frame_in_n  ),
    .rx_data_in_p   (rx_data_in_p   ),
    .rx_data_in_n   (rx_data_in_n   ),
    .tx_clk_out_p   (tx_clk_out_p   ),
    .tx_clk_out_n   (tx_clk_out_n   ),
    .tx_frame_out_p (tx_frame_out_p ),
    .tx_frame_out_n (tx_frame_out_n ),
    .tx_data_out_p  (tx_data_out_p  ),
    .tx_data_out_n  (tx_data_out_n  ),
    .data_clk       (data_clk1          ),
    .clk200         (fclk_200m          ),
    .clk100         (fclk_100m          ),
    .rstn           (fclk_reset0_n      ),
    .adc_valid      (adc_valid          ),
    .adc_data_i1    (adc_data_i1        ),
    .adc_data_q1    (adc_data_q1        ),
    .adc_data_i2    (adc_data_i2        ),
    .adc_data_q2    (adc_data_q2        ),
    .adc_status     (adc_status         ),
    .adc_r1_mode    (adc_r1_mode        ),
    .dac_valid      (dac_valid          ),
//    .dac_data_i1    (dac_data_i1        ),
    .dac_data_i1    (dac_data_i1_1      ),
//    .dac_data_q1    (dac_data_q1        ),
    .dac_data_q1    (dac_data_q1_1      ),
//    .dac_data_i2    (dac_data_i2        ),
    .dac_data_i2    (dac_data_i2_2      ),
//    .dac_data_q2    (dac_data_q2        ),
    .dac_data_q2    (dac_data_q2_2      ),
    .dac_r1_mode    (dac_r1_mode        ),
    .idly_en_vtc    (idly_en_vtc        ),
    .idly_load      (idly_load          ),
    .idly_d         (idly_d             )
  );
  
  //led
  //assign led = adc_status; 
  
  // vio
//  vio_0 vio_0 (
//  .clk(fclk_100m),                // input wire clk
//  .probe_in0(interrupt),    // input wire [0 : 0] probe_in0
//  .probe_out0(aclken),  // output wire [0 : 0] probe_out0
//  .probe_out1(),  // output wire [31 : 0] probe_out1
//  .probe_out2(sdr_cmd_param),  // output wire [31 : 0] probe_out2
//  .probe_out3(sdr_data_low),  // output wire [31 : 0] probe_out3
//  .probe_out4(sdr_data_high)  // output wire [31 : 0] probe_out4
//);

  // ila
//  ila_0 ila_0 (
//    .clk(data_clk1),
//    .probe0({
//    adc_valid   ,//1
//    adc_data_i1 ,//12
//    adc_data_q1 ,//12
//    adc_data_i2 ,//12
//    adc_data_q2 ,//12
//    adc_status  ,//1
//    dac_valid   ,//1
//    dac_data_i1 ,//12
//    dac_data_q1 ,//12
//    dac_data_i2 ,//12
//    dac_data_q2  //12
//  }));


//ila_pulse_gen inst_ila_pulse_gen (
//	.clk(data_clk1), // input wire clk
//	.probe0(pulse_out), // input wire [0:0]  probe0  
//	.probe1(counter) // input wire [7:0]  probe1
//);

//vio_1 Inst_vio_1 (
//  .clk(data_clk1),                // input wire clk
//  .probe_out0(counter_vio)  // output wire [5 : 0] probe_out0
//);

  //---------------  Pulse Generator ----------------------------

    
    always @(posedge data_clk1 or negedge mtime_start or negedge fclk_reset0_n) begin
        if (!mtime_start || !fclk_reset0_n) 
        begin
            counter       <= 8'd0;
            pulse_out     <= 0;
            dac_data_i1_1 <= 12'd0; 
            dac_data_q1_1 <= 12'd0; 
            dac_data_i2_2 <= 12'd0; 
            dac_data_q2_2 <= 12'd0;             
        end 
        else 
         begin
            if(Calib_En == 1'b1)
            begin
                if (counter < PRI - 1)
//                if (counter < PERIOD_CYCLES - 1)
                    counter <= counter + 1;
                else
                    counter <= 8'd0;
                    if (counter < PW)
//                    if (counter < PULSE_WIDTH_CYCLES)
                        begin
                            dac_data_i1_1 <= 12'd2047;
                            dac_data_q1_1 <= 12'd2047;
                            dac_data_i2_2 <= 12'd2047; 
                            dac_data_q2_2 <= 12'd2047; 
                            pulse_out     <= 1;
                        end
                    else 
                        begin
                            dac_data_i1_1 <= 12'd0; 
                            dac_data_q1_1 <= 12'd0; 
                            dac_data_i2_2 <= 12'd0; 
                            dac_data_q2_2 <= 12'd0; 
                            pulse_out     <= 0;
                        end
            end else begin
                dac_data_i1_1 <= 12'd0; 
                dac_data_q1_1 <= 12'd0; 
                dac_data_i2_2 <= 12'd0; 
                dac_data_q2_2 <= 12'd0; 
                pulse_out     <= 0; 
                counter       <= 8'd0;                   
            end;
        end
    end
//     IBUFDS #(
//      .DIFF_TERM("FALSE"),       // Differential Termination
//      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
//      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
//   ) IBUFDS_inst1 (
//      .O(tx_clk_out),  // Buffer output
//      .I(tx_clk_out_p),  // Diff_p buffer input (connect directly to top-level port)
//      .IB(tx_clk_out_n) // Diff_n buffer input (connect directly to top-level port)
//   );
  
//  ila_dac ila_dac_inst (
//	.clk(tx_clk_out), // input wire clk
//	.probe0(tx_data_out_p), // input wire [5:0]  probe0  
//	.probe1(tx_data_out_n), // input wire [5:0]  probe1 
//	.probe2(tx_data_out_p), // input wire [5:0]  probe2 
//	.probe3(tx_data_out_n) // input wire [5:0]  probe3
//);

endmodule

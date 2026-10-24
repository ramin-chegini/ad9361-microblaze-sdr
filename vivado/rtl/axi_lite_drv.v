`timescale 1ns / 1ps

/* usage info */ 

/*

 at 1st user put the smd and data to the specified 

*/

module axi_lite_drv(
  //global
  input             axi_gp_clk,
  input             axi_rst_n,
  // AXI Lite Master Interface connections
  input               up_wreq,
  input  [15:0]       up_waddr,
  input  [31:0]       up_wdata,
  output reg          up_wack,
 
  input               up_rreq,
  input  [15:0]       up_raddr,
  output reg  [31:0]  up_rdata,
  output reg          up_rack,
  
  //register out
  output reg        mtime_start,
  output reg [3:0]  rf_mode,
  output reg [11:0] phase,
  output reg [6:0]  idly_en_vtc,
  output reg [6:0]  idly_load,
  output reg [8:0]  idly_d,
  output reg [1:0]  pps_select,
  output reg [31:0] clock_1pps,
  output reg [3:0]  rf1_ctrl_in,
  output reg        BUFG_CE,
  
  (* MARK_DEBUG="true" *) output reg [31:0] irq_ctrl,

  // interrupt 
  output reg        interrupt,
  
  //register in
  
  input             CfgSET_Trig,
  input [31:0]      sdr_cmd_param,
  input [31:0]      sdr_data_low,
  input [31:0]      sdr_data_high,
  
  input  [31:0]     sdr_info,
  input             adc_status,
  input  [7:0]      rf1_ctrl_out
);
			
  reg irq_status;
  
  // Register Interface
  always @(posedge axi_gp_clk) begin
    if (axi_rst_n == 1'b0) begin
      up_wack <= 1'b0;
    end else begin
      up_wack <= up_wreq;
    end
  end    
       
  always @(posedge axi_gp_clk) begin
    if (axi_rst_n == 1'b0) begin
      up_rack <= 'd0;
    end else begin
      up_rack <= up_rreq;
    end
  end
 
  // write register
  always @ (posedge axi_gp_clk or negedge axi_rst_n)
  if(!axi_rst_n)
    begin
      mtime_start<=1'b0;
      pps_select<=2'd0;
      rf_mode<=4'd0;
      phase<=12'd128;
      idly_en_vtc<= 7'd0;
      idly_load <= 7'd0;
      idly_d<=8'd8;
      clock_1pps<=32'd61440000;
      rf1_ctrl_in<=4'd0;
      BUFG_CE <= 1'b0;
      irq_ctrl <= 32'b0;
    end
  else if(up_wreq)
    begin
        case(up_waddr[15:2])
          6'd1 :mtime_start   <= up_wdata[0];
          6'd2 :pps_select    <= up_wdata[1:0];
          6'd3 :phase         <= up_wdata[11:0];
          6'd4 :rf_mode       <= up_wdata[3:0];
          6'd5 :clock_1pps    <= up_wdata;
          6'd20:idly_en_vtc   <= up_wdata[6:0];
          6'd21:idly_load     <= up_wdata[6:0];
          6'd22:idly_d        <= up_wdata[8:0];
          6'd23:rf1_ctrl_in   <= up_wdata[3:0];
          6'd26:BUFG_CE       <= up_wdata[0];
          6'd52:irq_ctrl      <= up_wdata[31:0];
//          6'd53:irq_status    <= up_wdata[31:0];
//          6'd54:sdr_cmd_param <= up_wdata[15:0];
//          6'd55:sdr_data_low  <= up_wdata[31:0];
//          6'd56:sdr_data_high <= up_wdata[31:0];
        endcase
    end
  else
  begin end
  
  // read register
  always @ (posedge axi_gp_clk or negedge axi_rst_n)
  if(!axi_rst_n)
    begin
      up_rdata<=32'd0;
    end
  else if(up_rreq)
    begin
      case(up_raddr[15:2])
        6'd0    : up_rdata<=sdr_info;
        6'd1    : up_rdata<=mtime_start;
        6'd2    : up_rdata<=pps_select;
        6'd3    : up_rdata<=phase;
        6'd4    : up_rdata<=rf_mode;
        6'd5    : up_rdata<=clock_1pps;
        6'd20   : up_rdata<=idly_en_vtc;
        6'd21   : up_rdata<=idly_load;
        6'd22   : up_rdata<=idly_d;
        6'd23   : up_rdata<=rf1_ctrl_out;
        6'd28   : up_rdata<=adc_status;
        6'd52   : up_rdata<=irq_ctrl;
        6'd53   : up_rdata<=irq_status;
        6'd54   : up_rdata<=sdr_cmd_param;
        6'd55   : up_rdata<=sdr_data_low;
        6'd56   : up_rdata<=sdr_data_high;
        default : up_rdata<=32'haabbccdd;
      endcase
    end
  else
   up_rdata <= up_rdata;


  // interrupt handler
  (* MARK_DEBUG="true" *) reg interrupt_set;
  (* MARK_DEBUG="true" *) reg interrupt_set_d;     // delayed version of interrupt_set
  (* MARK_DEBUG="true" *) reg interrupt_rising_edge;
  (* MARK_DEBUG="true" *) reg interrupt_rising_edge_d;

//  assign interrupt_set  = sdr_cmd_param[16];

//  always @(posedge axi_gp_clk) begin
//      interrupt_set <= sdr_cmd_param[16];
//      interrupt_set_d <= interrupt_set;  // store previous value
//  end

//  assign interrupt_rising_edge = ~interrupt_set_d & interrupt_set;
//  assign interrupt_rising_edge = sdr_cmd_param[16];

  // Interrupt generation logic (triggered by interrupt_rising_edge)
//  always @(posedge axi_gp_clk or negedge axi_rst_n) begin
//    if (!axi_rst_n) begin
//      // Active-low reset: Clear interrupt and status register
//      interrupt <= 0;       // Clear the interrupt signal
//      irq_status <= 32'b0;  // Clear interrupt status on reset
//    end else begin
//         interrupt_rising_edge_d <= sdr_cmd_param[16];
//        // Logic for handling the clear interrupt register (triggered by external write)
//        if (irq_ctrl == 32'b1) begin
//          interrupt <= 0;       // Clear the interrupt signal
//          irq_status <= 32'b0;  // Clear interrupt status on external write
//        end else begin
//          // Trigger the interrupt when interrupt_rising_edge is asserted
//          if (interrupt_rising_edge_d == 1'b0 && sdr_cmd_param[16] == 1'b1) begin
////          if (interrupt_rising_edge) begin
//            interrupt <= 1;        // Assert the interrupt signal
//            irq_status <= 32'b1;   // Set the interrupt status
//          end
//        end
//    end
//  end
  
  
    reg CfgSET_Trig_Prev=1'b0;
//    reg sdr_cmd_param_16_d;
    
    always @(posedge axi_gp_clk or negedge axi_rst_n) begin
      if (!axi_rst_n) begin
        interrupt        <= 1'b0;
        irq_status       <= 32'b0;
        CfgSET_Trig_Prev <= 1'b0;
//        sdr_cmd_param_16_d <= 1'b0;
      end else begin
        CfgSET_Trig_Prev <= CfgSET_Trig;
//        sdr_cmd_param_16_d <= sdr_cmd_param[16];
    
        if (irq_ctrl == 32'b1) begin
          interrupt <= 1'b0;
          irq_status <= 32'b0;
        end else begin
          if (CfgSET_Trig_Prev == 1'b0 && CfgSET_Trig == 1'b1) begin
//          if (sdr_cmd_param_16_d == 1'b0 && sdr_cmd_param[16] == 1'b1) begin
            interrupt <= 1'b1;
            irq_status <= 32'b1;
          end
        end
      end
    end

endmodule

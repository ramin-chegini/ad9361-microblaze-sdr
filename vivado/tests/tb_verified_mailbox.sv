`timescale 1ns/1ps
// Ramin: test this project's actual mailbox using Vivado 2018.3 XSim.
module tb_verified_mailbox;
reg clk=0,resetn=0,trigger=0,wr=0,rd=0;
always #5 clk=~clk;
reg [15:0] wa=0,ra=0;
reg [31:0] wd=0,command=0,low=0,high=0;
wire [31:0] rdata,seq,reply_sequence,reply_command,error;
wire [63:0] result;
wire ready,busy,done,overflow,irq;
axi_lite_drv dut(.axi_gp_clk(clk),.axi_rst_n(resetn),.up_wreq(wr),.up_waddr(wa),.up_wdata(wd),.up_wack(),
 .up_rreq(rd),.up_raddr(ra),.up_rdata(rdata),.up_rack(),.mtime_start(),.rf_mode(),.phase(),.idly_en_vtc(),
 .idly_load(),.idly_d(),.pps_select(),.clock_1pps(),.rf1_ctrl_in(),.BUFG_CE(),.irq_ctrl(),.interrupt(irq),
 .CfgSET_Trig(trigger),.sdr_cmd_param(command),.sdr_data_low(low),.sdr_data_high(high),
 .sdr_info(32'h12345678),.adc_status(1'b1),.rf1_ctrl_out(8'hc0),
 .cmd_ready(ready),.cmd_busy(busy),.cmd_done(done),.cmd_overflow(overflow),.cmd_sequence(seq),
 .reply_sequence(reply_sequence),.reply_command(reply_command),.reply_data(result),.reply_error(error));
task write_reg(input integer index,input [31:0] value);
 begin @(negedge clk);wa=index*4;wd=value;wr=1;@(negedge clk);wr=0;end
endtask
task expect_reg(input integer index,input [31:0] expected);
 begin
  @(negedge clk);ra=index*4;rd=1;@(posedge clk);#1;
  if(rdata!==expected) $fatal(1,"Register %0d mismatch: got %h expected %h",index,rdata,expected);
  @(negedge clk);rd=0;
 end
endtask
task send(input [31:0] cmd,input [63:0] value);
 begin
  @(negedge clk);command=cmd;low=value[31:0];high=value[63:32];trigger=1;
  @(negedge clk);trigger=0;
 end
endtask
task result_stage(input [31:0] token,input [63:0] value,input [31:0] status);
 begin write_reg(58,value[31:0]);write_reg(59,value[63:32]);write_reg(60,token);write_reg(61,status);end
endtask
initial begin
 #80;resetn=1;repeat(3) @(posedge clk);
 expect_reg(63,32'h43414c32);expect_reg(3,128);expect_reg(5,61440000);
 if(!ready || busy) $fatal(1,"Mailbox did not reset ready");
 send(32'h10102,64'd5000000000);
 if(!busy || !irq || ready || seq!==1) $fatal(1,"Frequency command was not accepted");
 // A trigger while occupied cannot replace the command being read by firmware.
 send(32'h10105,64'd10000);
 expect_reg(54,32'h10102);expect_reg(55,32'h2a05f200);expect_reg(56,1);
 if(!overflow || seq!==1) $fatal(1,"Busy mailbox was overwritten");
 // IRQ ACK clears only the IRQ, including a trigger during the clear write.
 @(negedge clk);wa=52*4;wd=1;wr=1;trigger=1;
 @(negedge clk);wr=0;trigger=0;
 if(irq || !busy || seq!==1) $fatal(1,"IRQ clear released or replaced the transaction");
 write_reg(52,0);
 result_stage(0,64'd111,0);write_reg(57,1);
 if(!busy || done || reply_sequence!==0) $fatal(1,"Stale completion was accepted");
 result_stage(1,64'd5000000000,0);write_reg(57,1);
 if(busy || !done || !ready || result!==64'd5000000000 || reply_sequence!==1 || reply_command!==32'h10102 || error!==0)
  $fatal(1,"Frequency completion/readback mismatch");
 write_reg(57,0);expect_reg(58,32'h2a05f200);expect_reg(59,1);expect_reg(62,1);
 send(32'h10105,64'd10000);result_stage(2,64'd10000,0);write_reg(57,1);
 if(busy || reply_command!==32'h10105 || reply_sequence!==2) $fatal(1,"Gain completion mismatch");
 write_reg(57,0);
 send(32'h10102,64'd3000000000);result_stage(3,0,6);write_reg(57,1);
 if(busy || !done || error!==6) $fatal(1,"Firmware error was lost");
 write_reg(57,0);send(32'h10102,64'd2000000000);
 #2;resetn=0;#20;resetn=1;repeat(3) @(posedge clk);
 if(busy || overflow || seq!==0 || !ready) $fatal(1,"Reset did not clear mailbox state");
 send(32'h10102,64'd1000000000);result_stage(4,0,0);write_reg(57,1);
 if(!busy || done) $fatal(1,"Pre-reset token completed a new transaction");
 result_stage(1,64'd1000000000,0);write_reg(57,1);
 if(busy || result!==64'd1000000000) $fatal(1,"Mailbox did not recover after reset");
 $display("AD9361_2018_MAILBOX_TESTS_PASSED");$finish;
end
initial begin #30000;$fatal(1,"Mailbox test timeout");end
endmodule

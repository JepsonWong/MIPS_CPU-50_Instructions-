module bridge(Wen,PrAddr,BE,PrDIn,PrDOut,HWInt,timer_ADD_I,timer_we,time_DAT_I,time_DAT_O,sw_ADD_I,sw_we,sw_DAT_I,sw_DAT_O,segment_ADD_I,segment_we,segment_DAT_I,segment_DAT_O,IRQ);

input [31:2] PrAddr;
input Wen;
input [3:0] BE;
output [31:0] PrDIn;
input [31:0] PrDOut;
output [7:2] HWInt;
output [3:2] timer_ADD_I;
output sw_ADD_I,segment_ADD_I;
output timer_we,sw_we,segment_we;
output [31:0] time_DAT_I,sw_DAT_I,segment_DAT_I;
input[31:0] time_DAT_O,sw_DAT_O,segment_DAT_O;
input IRQ;

assign HWInt={6'b0,IRQ};
assign PrDIn=((PrAddr[31:4]==28'b0000000000000000011111110000)&(PrAddr[3:2]!=2'b11)) ? time_DAT_O:
             ( PrAddr[31:2]==30'b000000000000000001111111000100) ? sw_DAT_O:
             ( PrAddr[31:2]==30'b000000000000000001111111000101) ? segment_DAT_O:
             32'bx;
assign timer_ADD_I=PrAddr[3:2];
assign sw_ADD_I=PrAddr[2];
assign segment_ADD_I=PrAddr[2];
assign timer_we=(  Wen&&(PrAddr[31:4]==28'b0000000000000000011111110000)) ? 1'b1:1'b0;
assign sw_we=(Wen&&(     PrAddr[31:2]==30'b000000000000000001111111000100)) ? 1'b1:1'b0;
assign segment_we=(Wen&&(PrAddr[31:2]==30'b000000000000000001111111000101)) ? 1'b1:1'b0;
assign time_DAT_I=PrDOut;
assign sw_DAT_I=PrDOut;
assign segment_DAT_I=PrDOut;
  
endmodule

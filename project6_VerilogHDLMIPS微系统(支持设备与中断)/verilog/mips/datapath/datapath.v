module datapath(clk,reset,Im,Zero,NPCOp,PCWr,IRWr,WDSel,RegDst,RegWr,ExtOp,ALUSelA,ALUSelB,ALUOp,MemWr,whb,be,ALUOUT,B,CP0_Wen,EPCWr,EXLSet,EXLClr,MUL_DIV_Sel,MUL_DIV_Wr,IntReq,HWInt,PrDIn,DM_Sel);
  input clk;
  input reset;
  output [31:0] Im;
  output [2:0] Zero;
  input PCWr,IRWr,RegWr,ExtOp,ALUSelA,ALUSelB,MemWr;
  input [4:0] ALUOp;
  input [2:0] NPCOp,WDSel;
  input [1:0] RegDst;
  input [7:0] whb;
  input CP0_Wen,EPCWr,EXLSet,EXLClr,MUL_DIV_Sel,MUL_DIV_Wr,IntReq;
  input [7:2] HWInt;
  input [31:0] PrDIn;
  input DM_Sel;
  output [3:0] be;
  output [31:0] B;
  output [31:0] ALUOUT;
 
 wire [5:0] op;
 wire [4:0] RS1,RS2,RD;
 wire [15:0] Imm;
 wire [31:0] RD1,RD2;
 wire [31:0] WData;
 wire [31:0] instr;
 wire [31:0] A,C,Ext,AS,BS,ReadData,R,ext,READDATA;
 wire [31:2] pC,nPC,Jal_O,EPC,pc;
 wire [31:0] H32,L32;
 wire [31:0] CP0_DOUT;
 
 assign Im={op,RS1,RS2,Imm};
 
 NPC npc(NPCOp,{op,RS1,RS2,Imm},RD1[31:2],EPC,pC,nPC,Jal_O,pc); 
 PC  U_PC(clk,reset,PCWr,nPC,pC);
 im_4k U_IM(pC[11:2],instr);
 ir  IR(clk,instr,IRWr,op,RS1,RS2,Imm);
 mux4 MUX41(RS2,Imm[15:11],5'b11111,5'b0,RegDst,RD);
     defparam MUX41.size_data = 5 ;
 regfile U_RF(clk,RS1,RS2,RD,WData,RegWr,RD1,RD2);
 a   A1(RD1,clk,A);
 b   B1(RD2,clk,B);
 ext EXT(Imm,ExtOp,Ext);
 mux2 MUX21(B,Ext,ALUSelB,BS);
      defparam MUX21.size_data = 32 ;
 mux2 MUX22(A,B,ALUSelA,AS);
      defparam MUX22.size_data = 32 ;
ALU ALU(ALUOp,AS,BS,C,Zero);
MUL_DIV mul_div(A,B,ALUOp,MUL_DIV_Sel,MUL_DIV_Wr,clk,A,H32,L32);
aluout ALUOUT1(C,clk,ALUOUT);
BE b(ALUOUT[1:0],whb,be);
dm_4k U_DM(ALUOUT[11:2],B,MemWr,clk,be,ReadData);
mux2 MUX23(ReadData,PrDIn,DM_Sel,READDATA);
      defparam MUX23.size_data = 32 ;
data_ext DATA_EXT(READDATA,be,whb,ext);
DMR DMR(ext,clk,R);
CP0 cp0(pc,B,HWInt,Imm[15:11],CP0_Wen,EPCWr,EXLSet,EXLClr,clk,reset,IntReq,EPC,CP0_DOUT);
mux8 MUX81(ALUOUT,R,{Jal_O,2'b00},{31'b0,Zero[2]},L32,H32,CP0_DOUT,32'b0,WDSel,WData);
      defparam MUX81.size_data = 32 ;
  
endmodule
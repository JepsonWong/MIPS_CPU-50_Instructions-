module datapath(clk,reset,Im,Zero,NPCOp,PCWr,IRWr,WDSel,RegDst,RegWr,ExtOp,ALUSelA,ALUSelB,ALUOp,MemWr,whb);
  input clk;
  input reset;
  output [31:0] Im;
  output [2:0] Zero;
  input PCWr,IRWr,RegWr,ExtOp,ALUSelA,ALUSelB,MemWr;
  input [3:0] ALUOp;
  input [1:0] NPCOp,WDSel,RegDst;
  input [7:0] whb;
 
 wire [5:0] op;
 wire [4:0] RS1,RS2,RD;
 wire [15:0] Imm;
 wire [31:0] RD1,RD2;
 wire [31:0] WData;
 wire [31:0] instr;
 wire [31:0] A,B,C,Ext,AS,BS,ALUOUT,ReadData,R,ext;
 wire [31:2] pC,nPC,Jal_O;
 wire [3:0] be;
 
 assign Im={op,RS1,RS2,Imm};
 
 NPC npc(NPCOp,{op,RS1,RS2,Imm},RD1[31:2],pC,nPC,Jal_O); 
 PC  U_PC(clk,reset,PCWr,nPC,pC);
 im_4k U_IM(pC[11:2],instr);
 ir  IR(clk,instr,IRWr,op,RS1,RS2,Imm);
 mux MUX1(RS2,Imm[15:11],5'b11111,5'b0,RegDst[0],RegDst[1],RD);
     defparam MUX1.size_data = 5 ;
 regfile U_RF(clk,RS1,RS2,RD,WData,RegWr,RD1,RD2);
 a   A1(RD1,clk,A);
 b   B1(RD2,clk,B);
 ext EXT(Imm,ExtOp,Ext);
 mux MUX2(B,Ext,32'b0,32'b0,ALUSelB,1'b0,BS);
      defparam MUX2.size_data = 32 ;
 mux MUX4(A,B,32'b0,32'b0,ALUSelA,1'b0,AS);
      defparam MUX4.size_data = 32 ;
ALU ALU(ALUOp,AS,BS,C,Zero);
aluout ALUOUT1(C,clk,ALUOUT);
BE b(ALUOUT[1:0],whb,be);
dm_4k U_DM(ALUOUT[11:2],B,MemWr,clk,be,ReadData);
data_ext DATA_EXT(ReadData,be,whb,ext);
DMR DMR(ext,clk,R);
mux MUX3(ALUOUT,R,{Jal_O,2'b00},{31'b0,Zero[2]},WDSel[0],WDSel[1],WData);
      defparam MUX3.size_data = 32 ;
  
endmodule
module Project_1(clk,A,B,C,D,OPMODE,BCIN,CARRYIN,RSTA,RSTB,RSTM ,RSTP,RSTC,
RSTD ,RSTCARRYIN ,RSTOPMODE ,CEA ,CEB,CEM ,CEP ,CEC ,CED ,CECARRYIN,CEOPMODE,PCIN,
BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);

parameter A0REG = 0 ;
parameter A1REG = 1 ; 
parameter B0REG = 0 ;
parameter B1REG = 1 ;
parameter CREG = 1 ;
parameter DREG = 1 ;
parameter MREG = 1 ; 
parameter PREG = 1 ;
parameter CARRYINREG = 1 ; 
parameter CARRYOUTREG = 1 ;
parameter OPMODEREG = 1 ;
parameter CARRYINSEL = "OPMODE5" ;   // CARRYIN or OPMODE5
parameter B_INPUT = "DIRECT" ;   // DIRECT or CASCADE
parameter RSTTYPE = "SYNC" ;   // ASYNC or SYNC

input [17:0] A,B,D,BCIN ;
input [47:0] C,PCIN ;
input [7:0] OPMODE ;
input   CARRYIN,clk,CEA,CEB,CEC,CECARRYIN,
        CED,CEM,CEOPMODE,CEP,RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,
        RSTM,RSTOPMODE,RSTP ;

output reg [47:0] P,PCOUT ;
output reg CARRYOUT,CARRYOUTF;
output reg [17:0] BCOUT;
output reg [35:0] M ;

wire [17:0] mux_B ;
reg [17:0] A0_reg,A1_reg,B0_reg,B1_reg,D_reg,mux_A0,mux_A1,mux_B0,mux_B1,mux_D,mux_ADD_1 ;
reg [47:0] C_reg,P_reg,mux_C,mux_P,mux_X,mux_Z ;
reg [35:0] M_reg,mux_M ;
reg [7:0] OPMODE_reg ;
reg CARRYIN_reg,CARRYOUT_reg,mux_CIN,mux_COUT,mux_CIN_SEL ;
reg [17:0] ADD_1 ;   // The output of Pre-Adder/Subtracter
reg [35:0] MULTI ;   // The output of Multiplication process
reg [48:0] ADD_2 ;   /* The output of Post-Adder/Subtracter but it is used 
                        49 bit to take the ADD_2[48] to give it to CARYYOUT*/


assign mux_B =  (B_INPUT == "DIRECT") ? B :
                (B_INPUT == "CASCADE") ? BCIN : 18'b0 ;  // B first selection


//FIRST Sequential Always Block of clk_1
generate
if (RSTTYPE == "ASYNC") begin
    always @(posedge clk or posedge RSTA or posedge RSTB or posedge RSTC or posedge RSTD or posedge RSTOPMODE) begin
        if (RSTA) A0_reg <= 0;
        else if (CEA) A0_reg <= A;

        if (RSTB) B0_reg <= 0;
        else if (CEB) B0_reg <= mux_B;

        if (RSTC) C_reg <= 0;
        else if (CEC) C_reg <= C;

        if (RSTD) D_reg <= 0;
        else if (CED) D_reg <= D;

        if (RSTOPMODE) OPMODE_reg <= 0;
        else if (CEOPMODE) OPMODE_reg <= OPMODE;
    end
end else if (RSTTYPE == "SYNC") begin
    always @(posedge clk) begin
        if (RSTA) A0_reg <= 0;
        else if (CEA) A0_reg <= A;

        if (RSTB) B0_reg <= 0;
        else if (CEB) B0_reg <= mux_B;

        if (RSTC) C_reg <= 0;
        else if (CEC) C_reg <= C;

        if (RSTD) D_reg <= 0;
        else if (CED) D_reg <= D;

        if (RSTOPMODE) OPMODE_reg <= 0;
        else if (CEOPMODE) OPMODE_reg <= OPMODE;
    end
end
endgenerate


//FIRST Combinational Always Block of clk_1
always @(*) begin

    // mux_A0 
    if(A0REG)
        mux_A0 = A0_reg ;
    else
        mux_A0 = A ;

    // mux_B0     
    if(B0REG)
        mux_B0 = B0_reg ;
    else
        mux_B0 = mux_B ;

    // mux_C
    if(CREG)
        mux_C = C_reg ;
    else
        mux_C = C ;

    // mux_D
    if(DREG)
        mux_D = D_reg ;
    else
        mux_D = D ;

    // Pre-Adder/Subtracter Output (ADD_1)
    if (OPMODE_reg[6])
        ADD_1 = mux_D - mux_B0 ;
    else
        ADD_1 = mux_D + mux_B0 ;

    // Mux of OPMODE[4] that choose bet. Pre-Adder/Subtracter OR Mux_B0
    if (OPMODE_reg[4])
        mux_ADD_1 = ADD_1 ;
    else
        mux_ADD_1 = mux_B0 ;

end


//SECOND Sequential Always Block of clk_2
generate
if (RSTTYPE == "ASYNC") begin
    always @(posedge clk or posedge RSTA or posedge RSTB) begin
        if (RSTA) A1_reg <= 0;
        else if (CEA) A1_reg <= mux_A0;

        if (RSTB) B1_reg <= 0;
        else if (CEB) B1_reg <= mux_ADD_1;
    end
end else if (RSTTYPE == "SYNC") begin
    always @(posedge clk) begin
        if (RSTA) A1_reg <= 0;
        else if (CEA) A1_reg <= mux_A0;

        if (RSTB) B1_reg <= 0;
        else if (CEB) B1_reg <= mux_ADD_1;
    end
end
endgenerate


//SECOND Combinational Always Block of clk_2
always @(*) begin
    
    // mux_A1
    if (A1REG)
        mux_A1 = A1_reg ;
    else 
        mux_A1 = mux_A0 ;

    // mux_B1
    if (B1REG)
        mux_B1 = B1_reg ;
    else
        mux_B1 = mux_ADD_1 ;

    // BCOUT from mux_B1
    BCOUT = mux_B1 ;

    // Multiplication Process
    MULTI = mux_A1 * mux_B1 ;

    // Carry Cascade Input Mux
    if (CARRYINSEL == "OPMODE5")
        mux_CIN_SEL = OPMODE_reg[5] ;
    else if (CARRYINSEL == "CARRYIN")
        mux_CIN_SEL = CARRYIN ;
    else 
        mux_CIN_SEL = 0 ;

end


//THIRD Sequential Always Block of clk_3
generate
if (RSTTYPE == "ASYNC") begin
    always @(posedge clk or posedge RSTM or posedge RSTCARRYIN) begin
        if (RSTM) M_reg <= 0;
        else if (CEM) M_reg <= MULTI;

        if (RSTCARRYIN) CARRYIN_reg <= 0;
        else if (CECARRYIN) CARRYIN_reg <= mux_CIN_SEL;
    end
end else if (RSTTYPE == "SYNC") begin
    always @(posedge clk) begin
        if (RSTM) M_reg <= 0;
        else if (CEM) M_reg <= MULTI;

        if (RSTCARRYIN) CARRYIN_reg <= 0;
        else if (CECARRYIN) CARRYIN_reg <= mux_CIN_SEL;
    end
end
endgenerate


//THIRD Combinational Always Block of clk_3
always @(*) begin
    
    // mux_M
    if (MREG)
        mux_M = M_reg ;
    else
        mux_M = MULTI ;

    // mux_CIN
    if (CARRYINREG)
        mux_CIN = CARRYIN_reg ;
    else
        mux_CIN = mux_CIN_SEL ;

    // M Output
    M = mux_M ;

    // mux_X
    case (OPMODE_reg[1:0])
        2'b00: mux_X = 0 ;
        2'b01: mux_X = mux_M ;
        2'b10: mux_X = mux_P ;
        2'b11: mux_X = {mux_D[11:0] , mux_A1[17:0] , mux_B1[17:0]} ;
    endcase

    // mux_Z
    case (OPMODE_reg[3:2])
        2'b00: mux_Z = 0 ;
        2'b01: mux_Z = PCIN ;
        2'b10: mux_Z = mux_P ;
        2'b11: mux_Z = mux_C ;
    endcase

    // Post-Adder/Subtracter Output (ADD_2)
    if (OPMODE_reg[7])
        ADD_2 = mux_Z - (mux_X + mux_CIN) ;
    else
        ADD_2 = mux_Z + mux_X + mux_CIN ;

end


//FORTH Sequential Always Block of clk_4
generate
if (RSTTYPE == "ASYNC") begin
    always @(posedge clk or posedge RSTP or posedge RSTCARRYIN) begin
        if (RSTP) P_reg <= 0;
        else if (CEP) P_reg <= ADD_2[47:0];

        if (RSTCARRYIN) CARRYOUT_reg <= 0;
        else if (CECARRYIN) CARRYOUT_reg <= ADD_2[48];
    end
end else if (RSTTYPE == "SYNC") begin
    always @(posedge clk) begin
        if (RSTP) P_reg <= 0;
        else if (CEP) P_reg <= ADD_2[47:0];

        if (RSTCARRYIN) CARRYOUT_reg <= 0;
        else if (CECARRYIN) CARRYOUT_reg <= ADD_2[48];
    end
end
endgenerate


//FORTH Combinational Always Block of clk_4
always @(*) begin
    
    // Carry Cascade Output Mux
    if (CARRYOUTREG)
        mux_COUT = CARRYOUT_reg ;
    else
        mux_COUT = ADD_2[48] ;

    // CARRYOUT & CARRYOUTF Output
    CARRYOUT = mux_COUT ;
    CARRYOUTF = mux_COUT ;

    // mux_P
    if(PREG)
        mux_P = P_reg ;
    else
        mux_P = ADD_2[47:0] ;

    // P & PCOUT Output
    P = mux_P ;
    PCOUT = mux_P ;

end

endmodule

+
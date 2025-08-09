module Project_1_tb();
    

reg [17:0] A,B,D,BCIN ;
reg [47:0] C,PCIN ;
reg [7:0] OPMODE ;
reg   CARRYIN,clk,CEA,CEB,CEC,CECARRYIN,
        CED,CEM,CEOPMODE,CEP,RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,
        RSTM,RSTOPMODE,RSTP ;

wire [47:0] P,PCOUT ;
wire CARRYOUT,CARRYOUTF;
wire [17:0] BCOUT;
wire [35:0] M ;

Project_1 #(
    .A0REG(0),
    .A1REG(1),
    .B0REG(0),
    .B1REG(1),
    .CREG(1),
    .DREG(1),
    .MREG(1),
    .PREG(1),
    .CARRYINREG(1),
    .CARRYOUTREG(1),
    .OPMODEREG(1),
    .CARRYINSEL("OPMODE5"),
    .B_INPUT("DIRECT"),
    .RSTTYPE("SYNC")
)tb (  clk,A,B,C,D,OPMODE,BCIN,CARRYIN,RSTA,RSTB,RSTM,RSTP,RSTC,
        RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,
        CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF
    );



initial begin
    clk = 0 ;
    forever begin
        #1 clk = ~clk ;
    end
end

initial begin

//2.1. Verify Reset Operation
RSTA = 1 ;
RSTB = 1 ;
RSTC = 1 ;
RSTD = 1 ;
RSTCARRYIN = 1 ;
RSTOPMODE = 1 ;
RSTM = 1 ;
RSTP = 1 ;

CEA = 0 ;
CEB = 0 ;
CEC = 0 ;
CED = 0 ;
CEP = 0 ;
CEM = 0 ;
CECARRYIN = 0 ; 
CEOPMODE = 0 ;

A = $random ;
B = $random ;
C = $random ;
D = $random ;
CARRYIN = $random ;
OPMODE = $random ;
PCIN = $random ;
BCIN = $random ;

@(negedge clk) ;

if (M != 0 || P != 0 || CARRYOUT != 0 || CARRYOUTF != 0 || BCOUT != 0 || PCOUT != 0) begin
    $display ("error in 2.1. Verify Reset Operation") ;
    $stop ;
end



//2.2. Verify DSP Path 1
RSTA = 0 ;
RSTB = 0 ;
RSTC = 0 ;
RSTD = 0 ;
RSTCARRYIN = 0 ;
RSTOPMODE = 0 ;
RSTM = 0 ;
RSTP = 0 ;

CEA = 1 ;
CEB = 1 ;
CEC = 1 ;
CED = 1 ;
CEP = 1 ;
CEM = 1 ;
CECARRYIN = 1 ; 
CEOPMODE = 1 ;

OPMODE = 8'b11011101 ;  
A = 20 ; 
B = 10 ; 
C = 350 ;
D = 25 ; 
BCIN = $random ;
PCIN = $random ;
CARRYIN = $random ;

repeat(4) @(negedge clk) ;

if (M != 36'h12c || P != 48'h32 || CARRYOUT != 0 || CARRYOUTF != 0 || BCOUT != 18'hf || PCOUT != 48'h32) begin
    $display ("error in 2.2. Verify DSP Path 1") ;
    $stop ;
end



//2.3. Verify DSP Path 2
OPMODE = 8'b00010000 ;  
A = 20 ; 
B = 10 ; 
C = 350 ;
D = 25 ; 
BCIN = $random ;
PCIN = $random ;
CARRYIN = $random ;

repeat(3) @(negedge clk) ;

if (M != 36'h2bc || P != 0 || CARRYOUT != 0 || CARRYOUTF != 0 || BCOUT != 18'h23 || PCOUT != 0) begin
    $display ("error in 2.3. Verify DSP Path 2") ;
    $stop ;
end



//2.4. Verify DSP Path 3
OPMODE = 8'b00001010 ;  
A = 20 ; 
B = 10 ; 
C = 350 ;
D = 25 ; 
BCIN = $random ;
PCIN = $random ;
CARRYIN = $random ;

repeat(3) @(negedge clk) ;

if (M != 36'hc8 || P != 0 || CARRYOUT != 0 || CARRYOUTF != 0 || BCOUT != 18'ha || PCOUT != 0) begin
    $display ("error in 2.4. Verify DSP Path 3") ;
    $stop ;
end



//2.5. Verify DSP Path 4
OPMODE = 8'b10100111 ;  
A = 5 ; 
B = 6 ; 
C = 350 ;
D = 25 ; 
BCIN = $random ;
PCIN = 3000 ;
CARRYIN = $random ;

repeat(3) @(negedge clk) ;

if (M != 36'h1e || P != 48'hfe6fffec0bb1 || CARRYOUT != 1 || CARRYOUTF != 1 || BCOUT != 18'h6 || PCOUT != 48'hfe6fffec0bb1) begin
    $display ("error in 2.5. Verify DSP Path 4") ;
    $stop ;
end

$stop;

end

endmodule



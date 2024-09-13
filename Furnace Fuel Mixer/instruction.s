#equations found at: https://stationeers-wiki.com/Pipe_Gas_Mixer
alias idealRatio r15
alias tHotGas r14
alias tColdGas r13
alias gasMode r12 #1 for H2 Warmer, 2 for O2 Warmer
alias outputRatio r11

Init:
s db Setting 0

loop:
move outputRatio 0
yield
yield
yield
jal selectHotGas
jal calcRatio
jal updateGasMixer
j loop

selectHotGas:
lbn r2 435685051 HASH("F-PSensor-H2") Temperature Maximum
lbn r3 435685051 HASH("F-PSensor-O2") Temperature Maximum
bgt r3 r2 handleO2Warmer
handleH2Warmer:
move tHotGas r2
move tColdGas r3
move idealRatio 0.6667
j ra
handleO2Warmer:
move tHotGas r3
move tColdGas r2
move idealRatio 0.3333
j ra

calcRatio:
#numerator
mul r0 idealRatio tHotGas
#denominator
sub r1 1.0 idealRatio
mul r1 r1 tColdGas
mul r2 idealRatio tHotGas
add r1 r1 r2
#divide
beqz r2 handleDivZero
div outputRatio r0 r1
j ra

handleDivZero:
s db Setting -9999
j killGasMixer

updateGasMixer:
s db Setting outputRatio
sbn -1134459463 HASH("F-GasMixer-H2/O2") Setting outputRatio
j ra

killGasMixer:
sbn -1134459463 HASH("F-GasMixer-H2/O2") On 0
j loop
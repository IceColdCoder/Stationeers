alias premixTank d0
alias iTemp r15
alias fTemp r14
alias iPressure r13
alias fPressure r12
alias sumSpecHeat r11
alias tFuelRatio r10 #target fuel ratio
alias combustionStatus r9
alias ratioO2H2 r8
alias ra2 r7
alias fuelSpecHeat r6
define lLedHash -1949054743

init:
s db Setting 0

loop:
yield
yield
yield
move sumSpecHeat 0.0
move fTemp 0.0
move sumSpecHeat 0.0
move tFuelRatio 0.0
jal readTank
j handleCalcs
jCalcReturn:
j loop

noCompustion:
move combustionStatus -1

readTank:
l iTemp premixTank Temperature
l iPressure premixTank Pressure
j ra

handleCalcs:
#Execution is order dependant.
jal calcO2H2Ratio
jal sumSpecifcHeat
jal calcPeakTemp
jal calcPeakPressure
jal calcFuelRatio
j jCalcReturn

calcPeakTemp:
#numerator
mul fTemp ratioO2H2 563452.0
mul r0 sumSpecHeat iTemp
add fTemp fTemp r0
#demonimator
mul r0 ratioO2H2 172.615
add r0 r0 sumSpecHeat
#divide
beqz r0 handleTDivZero
div fTemp fTemp r0
sbn lLedHash HASH("D-P/T-PTemp") Setting fTemp
j ra

calcO2H2Ratio:
l r0 premixTank RatioOxygen
l r1 premixTank RatioVolatiles
mul r1 r1 0.5
min ratioO2H2 r0 r1
j ra

sumSpecifcHeat:
l r0 premixTank RatioOxygen
mul r0 r0 21.1
add sumSpecHeat sumSpecHeat r0
l r0 premixTank RatioVolatiles
mul r0 r0 20.4
add sumSpecHeat sumSpecHeat r0
move fuelSpecHeat sumSpecHeat
l r0 premixTank RatioCarbonDioxide
mul r0 r0 28.2
add sumSpecHeat sumSpecHeat r0
l r0 premixTank RatioPollutant
mul r0 r0 24.8
add sumSpecHeat sumSpecHeat r0
l r0 premixTank RatioNitrogen
mul r0 r0 20.6
add sumSpecHeat sumSpecHeat r0
l r0 premixTank RatioNitrousOxide
mul r0 r0 23.0
add sumSpecHeat sumSpecHeat r0
j ra

calcPeakPressure:
#numerator
mul r0 5.7 ratioO2H2
add r0 r0 1.0
mul r0 r0 fTemp
mul r0 r0 iPressure
beqz iTemp handlePDivZero
div fPressure r0 iTemp
sbn lLedHash HASH("D-P/T-PPressure") Setting fPressure
j ra

calcFuelRatio:
sub r4 sumSpecHeat fuelSpecHeat #dilutant spec heat
#denominator
div r3 563452 3 #187817
sub r0 20.663 r4
mul r0 r0 iTemp
add r0 r0 r3
sub r1 78.172 r4
mul r1 r1 fTemp
sub r0 r0 r1
#numerator
sub r1 fTemp iTemp
mul r1 r1 r4
beqz r0 handleFRDivZero
div tFuelRatio r1 r0
sbn lLedHash HASH("D-P/T-iFuelRatio") Setting tFuelRatio
j ra

handleTDivZero:
sbn lLedHash HASH("D-P/T-PTemp") Setting -9999
j loop
handlePDivZero:
sbn lLedHash HASH("D-P/T-PPressure") Setting -9999
j loop
handleFRDivZero:
sbn lLedHash HASH("D-P/T-iFuelRatio") Setting -9999
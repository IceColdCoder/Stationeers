alias iTemp r15
alias fTemp r14
alias iPressure r13
alias fPressure r12
alias ratioFuel r11
define lLed -1949054743
define insTank 272136332
define mem -851746783

init:
s db Setting 0

loop:
yield
yield
yield
jal readDisplays
jal calcInitPressure
j loop

readDisplays:
lbn iTemp insTank HASH("F-Tank-Premix") Temperature Maximum
lbn fTemp lLed HASH("D-P/T-PTemp") Setting Maximum
lbn fPressure mem HASH("PC-Mem-iTPressure") Setting Maximum
lbn ratioFuel lLed HASH("D-P/T-iFuelRatio") Setting Maximum
j ra

calcInitPressure:
#numerator
mul r1 fPressure iTemp
#denominator
mul r0 ratioFuel 1.9
add r0 r0 1.0
mul r0 r0 fTemp
beqz r0 handlePDivZero
div iPressure r1 r0
sbn lLed HASH("D-P/T-TPressure") Setting iPressure
j ra

handlePDivZero:
sbn lLed HASH("D-P/T-TPressure") Setting -9999
j loop
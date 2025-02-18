alias GSensor d0
alias CO2N2Mixer d1
alias O2Co2N2Mixer d2
alias VentP d3
alias VentDP d4
alias PipeSensor d5

define PressureMaxSet 101
define PressureMinSet 90
define O2RatioSet 0.90
define CO2RatioSet 0.08
define N2RatioSet 0.02
define CO2N2RatioSet 0.6 #.6/(CO2RatioSet+N2RatioSet)
define MixToO2RatioSet 0.4
define PowerOn 1
define PowerOff 0
define PipeMaxPressure 5000

VentSetup:
s VentP Mode 0
s VentDP Mode 1
s VentDP PressureInternal 5000
s VentDP PressureExternal 90

LoopStart:
yield

read:
l r15 GSensor Pressure
l r14 GSensor RatioOxygen
l r13 GSensor RatioCarbonDioxide
l r12 GSensor RatioNitrogen
add r11 r13 r12 #Sum of CO2 &amp; N2.
add r10 r11 r14 #Sum of gas ratios.
l r9 PipeSensor Pressure

HandleCo2N2:
div r0 r13 r11 #Ratio of Co@ to Co2+N2 Mix.
sub r0 r0 CO2N2RatioSet #Get diff between ratios.
mul r0 r0 -1.0
add r0 r0 CO2N2RatioSet #Add diff to final ratio.
mul r0 r0 100.0 #Multiply by 100.
#s db Setting r0
s CO2N2Mixer Setting r0


HandleO2Mix:
div r1 r11 r10
sub r1 r1 MixToO2RatioSet
mul r1 r1 -1.0
add r1 r1 MixToO2RatioSet
s db Setting r1
mul r1 r1 100.0

s O2Co2N2Mixer Setting r1

HandlePressure:
sub r2 r15 PressureMaxSet
bgtz r2 HandlePowerOff #Jump if over pressure.
sub r2 r9 PipeMaxPressure
bgtz r2 HandlePipePressure #Jump if pipe over pressure.

HandlePowerOn:
#s db Setting 1
s CO2N2Mixer On PowerOn
s O2Co2N2Mixer On PowerOn
j ManageVents

HandlePowerOff:
#s db Setting 2
s CO2N2Mixer On PowerOff
s O2Co2N2Mixer On PowerOff
j ManageVents

HandlePipePressure:
#s db Setting 3
s CO2N2Mixer On PowerOff
s O2Co2N2Mixer On PowerOn
j ManageVents

ManageVents:
sub r2 r15 PressureMaxSet
bgtz r2 HandleOverPressure
bltz r2 HandleUnderPressure
s VentP On PowerOn
s VentDP On PowerOn
j LoopStart

HandleOverPressure:
s VentP On PowerOff
s VentDP On PowerOn
j LoopStart

HandleUnderPressure:
s VentP On PowerOn
s VentDP On PowerOff
j LoopStart
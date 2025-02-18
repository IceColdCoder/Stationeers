#prediction of the ignition temperature and pressure of a furnace
#if combustion can't occur, display current temperature and pressure

alias furnace d0        #advanced or regular
alias consoleTemp d1    #console, small LED
alias consolePres d2    #console, small LED

alias ratioOx r5
alias ratioVol r6
alias specificHeat r12
alias fuel r13
alias temp r14
alias pres r15

define energyReleased 563452
define specificHeatInc 172.615
define gasMolInc 5.7

main:
yield
#calculate the specific heat of the gas mix
l r5 furnace RatioOxygen
l r6 furnace RatioVolatiles
l r7 furnace RatioCarbonDioxide
l r8 furnace RatioPollutant
l r9 furnace RatioNitrogen
l r10 furnace RatioNitrousOxide
l r11 furnace RatioWater
mul r0 r5 21.1
mul r1 r6 20.4
add r0 r0 r1
mul r1 r7 28.2
add r0 r0 r1
mul r1 r8 24.8
add r0 r0 r1
mul r1 r9 20.6
add r0 r0 r1
mul r1 r10 23
add r0 r0 r1
mul r1 r11 72
add specificHeat r0 r1
#calculate the fuel amount
div ratioVol ratioVol 2
min fuel ratioOx ratioVol
#calculate Temp after ignition
mul r0 fuel specificHeatInc
add r0 r0 specificHeat
mul r1 fuel energyReleased
l r2 furnace Temperature
mul r2 r2 specificHeat
add r1 r1 r2
div temp r1 r0
#calculate Pressure after ignition
l r0 furnace Temperature
l r1 furnace Pressure
mul r2 fuel gasMolInc
add r2 r2 1
mul r2 r2 temp
mul r2 r2 r1
div pres r2 r0
#check if pressure &lt;10kPa and ratios &lt;0.05
blt r1 10 noCombustion
blt ratioOx 0.05 noCombustion
blt ratioVol 0.05 noCombustion
s consoleTemp Color 6
s consolePres Color 1
j displayResults
noCombustion:
s consoleTemp Color 3
s consolePres Color 2
move temp r0
move pres r1
displayResults:
s consoleTemp Setting temp
s consolePres Setting pres
j main

### End Script ###
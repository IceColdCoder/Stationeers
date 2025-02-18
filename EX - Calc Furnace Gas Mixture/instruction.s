#A script for calculating how to dilute fuel..
#..inside a furnace to reach a desired temperature..
#..and pressure on ignition

# This script requires perfect fuel (O2 + 2 H2)
# The diluting gas can be anything, even a mix
# Temperature of fuel and dilutant can be different
# BLUE color = dilutant must provide missing oxygen
# ORANGE color = gas will ignite

#Inputs are desired temperature (K) and pressure (kPa)
#Outputs are the pressure of fuel (kPa) and the..
#..total pressure (kPa) after adding the dilutant

alias inputTemp d0          #logic memory
alias inputPres d1          #logic memory
alias outputFuel d2         #console, small LED
alias outputTotal d3        #console, small LED
alias fuelAnalyzer d4       #pipe analyzer
alias dilutantAnalyzer d5   #pipe analyzer

alias oldTmix r10
alias Tmix r11
alias fuelSpecificHeat r12
alias dilutantSpecificHeat r13
alias ratioFuel r14
alias pressureTotal r15
s outputTotal Color 1

main:
yield
s outputFuel Color 3
#calculate specific heat values
div r0 61.9 3
move fuelSpecificHeat r0
jal specficHeatCalculation
#calculate how to reach input values
l r5 fuelAnalyzer Temperature
l r6 inputTemp Setting
l r7 dilutantAnalyzer Temperature
move oldTmix r5
move r9 5
iterate:
jal fuelRatioCalculation
jal temperatureMixCalculation
sub r9 r9 1
move oldTmix Tmix
blt r9 1 iterate
#calculate total fuel+dilutant pressure
l r8 inputPres Setting
mul r1 ratioFuel 1.9
add r1 r1 1
mul r1 r1 r6
mul r0 r8 Tmix
div pressureTotal r0 r1
#calculate fuel pressure
mul r0 r5 pressureTotal
mul r0 ratioFuel r0
div r0 r0 Tmix
#calculate dilutant pressure (not used)
#sub r1 1 ratioFuel
#mul r1 r1 pressureTotal
#mul r1 r1 r7
#div r1 r1 Tmix
#check for too high input temperature
blt pressureTotal r0 noCombustion
#display result
bltal ratioFuel 0.15 dilutantMustHaveOxygen
bltal ratioFuel 0.10 noCombustion
s outputFuel Setting r0
s outputTotal Setting pressureTotal
j main
noCombustion:
s outputFuel Setting -1
s outputTotal Setting -1
j main
dilutantMustHaveOxygen:
s outputFuel Color 0
j ra

fuelRatioCalculation:
div r0 563452 3
sub r4 fuelSpecificHeat dilutantSpecificHeat
mul r1 Tmix r4
add r0 r0 r1
mul r1 r6 r4
sub r0 r0 r1
div r1 172.615 3
mul r1 r6 r1
sub r0 r0 r1
sub r1 r6 Tmix
mul r1 r1 dilutantSpecificHeat
div ratioFuel r1 r0
j ra
temperatureMixCalculation:
sub r4 1 ratioFuel
mul r0 dilutantSpecificHeat r4
mul r1 ratioFuel fuelSpecificHeat
add r3 r0 r1
mul r0 r7 r4
mul r0 r0 dilutantSpecificHeat
mul r1 r5 ratioFuel
mul r1 r1 fuelSpecificHeat
add r0 r0 r1
div Tmix r0 r3
j ra
specficHeatCalculation:
l r5 d5 RatioOxygen
l r6 d5 RatioVolatiles
l r7 d5 RatioCarbonDioxide
l r8 d5 RatioPollutant
l r9 d5 RatioNitrogen
l r10 d5 RatioNitrousOxide
bne r5 r5 noCombustion #protection against null
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
add dilutantSpecificHeat r0 r1
j ra
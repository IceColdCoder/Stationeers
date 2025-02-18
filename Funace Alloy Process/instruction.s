alias dDebug d5
alias tTemp r15
alias tPressure r14
alias pTemp r13
alias pPressure r12
alias cTemp r11
alias cPressure r10
alias deltaTemp r9
alias deltaPressure r8
alias startState r7
define mChip -851746783
define ledLarge -1949054743
define advFurnace 545937711
define dDebug -53151617
define lGate 1942143074
define bpr -1149857558
define fLight -2107840748
define gasMixer 2104106366
define furnaceMaxPressure 60000
define furnacePressureMargin 58000
define pSensor 435685051
define pSafety 50000
define pMax 60000
define insTank 272136332

init:
s db Setting 0

loop:
yield
yield
yield
jal loadValues
jal writeReadDebug
jal calcDeltas
jal checkRunState
jal handleFill
j loop

checkRunState:
lbn r0 lGate HASH("F-Logic-KillGate") Setting Maximum
beqzal r0 handleKill
lbn r0 mChip HASH("F-MemErr-FPressure") Setting Maximum
bgtzal r0 handleKill
lbn r1 mChip HASH("F-MemErr-PPressure") Setting Maximum
nor r0 r0 r1
beqz r0 loop
lbn r0 mChip HASH("F-Mem-StartStateMirror") Setting Maximum
beqz r0 loop
j ra

handleKill:
sbn advFurnace HASH("F-AdvFurnace") SettingInput 0
sbn advFurnace HASH("F-AdvFurnace") SettingOutput 100
jal handleGasShutoff
j ra

handleFill:
sbn advFurnace HASH("F-AdvFurnace") SettingOutput 0
bgtz deltaTemp handleInputFuel #Input fuel until pressure.
bgtz deltaPressure handleInputDilutant #Input dilutant until pre
j handleGasShutoff #Shut off all fuel inputs.

handleGasShutoff:
sbn gasMixer HASH("F-Gas Mixer-Fuel/N2") On 0
sbn gasMixer HASH("F-Gas Mixer-H2/O2") On 0
j ra

handleInputFuel:
div r0 deltaTemp tTemp
mul r0 r0 100
sbn dDebug HASH("DDebug-8") Setting r0
sbn gasMixer HASH("F-Gas Mixer-Fuel/N2") Setting r0
sbn gasMixer HASH("F-Gas Mixer-Fuel/N2") On 1
sbn gasMixer HASH("F-Gas Mixer-H2/O2") On 1
j loop

handleInputDilutant:
div r0 deltaPressure tPressure
mul r0 r0 100
sbn dDebug HASH("DDebug-9") Setting r0
sbn gasMixer HASH("F-Gas Mixer-Fuel/N2") Setting r0
sbn gasMixer HASH("F-Gas Mixer-Fuel/N2") On 1
sbn gasMixer HASH("F-Gas Mixer-H2/O2") On 0
j loop

calcDeltas:
sub deltaTemp tTemp pTemp
sub deltaPressure tPressure pPressure
j ra

loadValues:
lbn startState mChip HASH("F-Mem-StartStateMirror") Setting Sum
lbn tTemp mChip HASH("A-Steel-Mem-Temp") Setting Sum
lbn tPressure mChip HASH("A-Steel-Mem-Pres") Setting Sum
sbn mChip HASH("PC-Mem-iTTemp") Setting tTemp
sbn mChip HASH("PC-Mem-iTPressure") Setting tPressure
sbn ledLarge HASH("D-P/T-STemp") Setting tTemp
sbn ledLarge HASH("D-P/T-SPressure") Setting tPressure
lbn pTemp ledLarge HASH("D-P/T-PTemp") Setting Sum
lbn pPressure ledLarge HASH("D-P/T-PPressure") Setting Sum
lbn cTemp insTank HASH("F-Tank-Premix") Temperature Sum
lbn cPressure insTank HASH("F-Tank-Premix") Pressure Sum
j ra

writeReadDebug:
sbn dDebug HASH("DDebug-0") Setting tTemp
sbn dDebug HASH("DDebug-1") Setting tPressure
sbn dDebug HASH("DDebug-2") Setting pTemp
sbn dDebug HASH("DDebug-3") Setting pPressure
sbn dDebug HASH("DDebug-4") Setting cTemp
sbn dDebug HASH("DDebug-5") Setting cPressure
j ra
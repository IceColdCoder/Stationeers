define mChip -851746783
define advFurnace 545937711
define bpr -1149857558
define fLight -2107840748
define gasMixer 2104106366
define furnaceMaxPressure 60000
define furnacePressureMargin 58000
define pSensor 435685051
define pSafety 50000
define pMax 60000
define pBleed 57500
define icHousing -128473777
define lGate 1942143074
alias pFAlarm r15
alias pPAlarm r14

init:
sbn bpr HASH("F-BPR-Bleed-H2O2") Setting pBleed
sbn bpr HASH("F-BPR-Bleed-H2O2") On 1
sbn bpr HASH("F-BPR-Bleed-N2") Setting pBleed
sbn bpr HASH("F-BPR-Bleed-N2") On 1
sbn bpr HASH("F-BPR-Bleed-FuelMix") Setting pBleed
sbn bpr HASH("F-BPR-Bleed-FuelMix") On 1

loop:
yield
jal handleFurnacePSafety
jal handlePipeSafety
jal handleAlarm
j loop

triggerBlowout:
sbn bpr HASH("F-BPR-Line Bleed") Setting 0
j ra

dumpFurnace:
sbn advFurnace HASH("F-AdvFurnace") SettingInput 0
sbn advFurnace HASH("F-AdvFurnace") SettingOutput 100
j ra

shutoffGas:
sbn gasMixer HASH("F-Gas Mixer-Fuel/N2") On 0
sbn gasMixer HASH("F-Gas Mixer-H2/O2") On 0
sbn advFurnace HASH("F-AdvFurnace") SettingInput 0
yield
lbn r0 gasMixer HASH("F-Gas Mixer-Fuel/N2") On Maximum
bnez r0 shutoffGas
lbn r0 gasMixer HASH("F-Gas Mixer-H2/O2") On 0
bnez r0 shutoffGas
lbn r0 advFurnace HASH("F-AdvFurnace") SettingInput Maximum
bnez r0 shutoffGas
j ra

handleAlarm:
sbn mChip HASH("F-MemErr-FPressure") Setting pFAlarm
sbn mChip HASH("F-MemErr-PPressure") Setting pPAlarm
or r1 pFAlarm pPAlarm
sbn fLight HASH("F-Light-Alarm") On r1
j ra

handleFurnacePSafety:
lbn r0 advFurnace HASH("F-AdvFurnace") Pressure Maximum
bgtal r0 furnacePressureMargin dumpFurnace
bgtal r0 furnaceMaxPressure triggerBlowout
bgtal r0 furnacePressureMargin triggerShutdown
bgtal r0 furnacePressureMargin shutoffGas
sgt pFAlarm r0 furnacePressureMargin
j ra

handlePipeSafety:
lbn r0 pSensor HASH("F-PSensor-FInput") Pressure Maximum
lbn r1 pSensor HASH("F-PSensor-H2/O2") Pressure Maximum
lbn r2 pSensor HASH("F-PSensor-Fuel+N2") Pressure Maximum
max r0 r0 r1
max r0 r0 r2
bgtal r0 pSafety shutoffGas
sgt pPAlarm r0 pSafety
j ra

triggerShutdown:
sbn icHousing HASH("A-Steel-IC Housing") On 0
sbn mChip HASH("F-Mem-Alarm") Setting 1
j ra

handleKillSwitch:
lbn r0 lGate HASH("F-Logic-KillGate") Setting Maximum
bnez r0 dumpFurnace
bnez r0 triggerShutdown
bnez r0 shutoffGas
j ra
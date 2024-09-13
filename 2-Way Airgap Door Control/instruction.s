alias door1 d0
alias door2 d1

alias door1OpenState r15
alias door2OpenState r14
alias doorDirection r13
alias door1Setting r12
alias door2Setting r13

Init:
yield
s door1 Mode 1
s door2 Mode 1
s door1 Lock 0
s door2 Lock 0
s door1 Setting 0
s door2 Setting 0
s door1 Open 0
s door2 Open 0

ReadDoors:
l door1OpenState door1 Open
l door2OpenState door2 Open
l door1Setting door1 Setting
l door2Setting door2 Setting

CheckDoorSettings:
yield
and r0 door1Setting door1OpenState
xor r0 r0 door1Setting
bgtz r0 OpenDoor1
and r1 door2Setting door2OpenState
xor r1 r1 door2Setting
bgtz r1 OpenDoor2
j ReadDoors

OpenDoor1:
s door2 Open 0
CycleDoor1Loop:
yield
l door2OpenState door2 Open
bnez door2OpenState CycleDoor1Loop
s door1 Open 1
s door2 Setting 0
j ReadDoors

OpenDoor2:
s door1 Open 0
CycleDoor2Loop:
yield
l door1OpenState door1 Open
bnez door1OpenState CycleDoor2Loop
s door2 Open 1
s door1 Setting 0
j ReadDoors

CloseAll:
s door1 Open 0
s door2 Open 0

ResetDoors:
s door1 Lock 0
s door2 Lock 0
j ReadDoors
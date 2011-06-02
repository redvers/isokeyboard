CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

VAR
  long r1
  
PUB main
  cognew(@entrypoint, @r1)

DAT
              org 0
entrypoint    mov Mem, PAR
              or DIRA, DIRMASK                  ' Set pins to stun
:outerloop    andn OUTA, LOADPIN                ' Set LD to low
              andn OUTA, CLKPIN                 ' Set clockpin low
              or OUTA, LOADPIN                  ' Set Load high
              mov bitcntr, #32                  ' We're reading 32 bits...
:loop         andn OUTA, CLKPIN                 ' Set LD to low (Yes, this is redundant
              or OUTA, CLKPIN                   ' Set CLK high

              test SERPIN, INA  WZ
        IF_NZ add KEYSTATE, $1
              rcl KEYSTATE, #1
              
              or OUTA, CLKPIN                   ' Set CLK high
              djnz bitcntr, #:loop              ' Around the loop we go
              wrlong KEYSTATE, Mem
              jmp #:outerloop                   ' ... and back for another snapshot

DIRMASK       long      %00000110_00000000_00000000_01111111
LOADPIN       long      %00000010_00000000_00000000_00000000
CLKPIN        long      %00000100_00000000_00000000_00000000  
SERPIN        long      %00001000_00000000_00000000_00000000
BITCNTR       long      $0
KEYSTATE      res       1      
Mem           res       1      
                  
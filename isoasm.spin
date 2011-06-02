CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

PUB main
  cognew(@entrypoint, 0)


VAR
  long r1
  
DAT
              org 0
entrypoint    or DIRA, DIRMASK                  ' Set pins to stun
:outerloop    andn OUTA, LOADPIN                ' Set LD to low
              andn OUTA, CLKPIN                 ' Set clockpin low
              or OUTA, LOADPIN                  ' Set Load high
              mov bitcntr, #32                  ' We're reading 32 bits...
:loop         andn OUTA, CLKPIN                 ' Set LD to low (Yes, this is redundant
                              
              ror INA, #28 NR,WC                ' C should contain value of CLK (27)
              rcl KEYSTATE, #1                  ' C should now be pushed into LSB of keystate
              or OUTA, CLKPIN                   ' Set CLK high
              djnz bitcntr, #:loop              ' Around the loop we go
              jmp #:outerloop                   ' ... and back for another snapshot

DIRMASK       long      %00000110_00000000_00000000_01111111
LOADPIN       long      %00000010_00000000_00000000_00000000
CLKPIN        long      %00000100_00000000_00000000_00000000  
SERPIN        long      %00001000_00000000_00000000_00000000
BITCNTR       long      $0
KEYSTATE      long   


{{


syncpll_1     mov       dira,dira1
              mov       ctra,ctra1
              mov       frqa,frqa1
              waitpeq   one1,one1
              mov       phsa,#0
:forever      jmp       #:forever

dira1         long      $0000_0002
ctra1         long      %00010<<26|%111<<23|1
frqa1         long      $0800_0000
one1          long      1

              org       0
syncpll_2     mov       dira,dira2
              mov       ctra,ctra2
              mov       frqa,frqa2
              waitpeq   one2,one2
              mov       phsa,#0
:forever      jmp       #:forever

dira2         long      $0000_0004
ctra2         long      %00010<<26|%111<<23|2
frqa2         long      $0800_0000
one2          long      1

}}
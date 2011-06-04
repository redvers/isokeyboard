CON 
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ                                  'include 2 ViewPort objects:
 vp    : "Conduit"                   'transfers data to/from PC
 qs    : "QuickSample"               'samples INA continuously in 1 cog- up to 20Msps
VAR
  long frame[400]                    'stores measurements of INA port
  long r1                        'vars shared with ViewPort
PUB main
  vp.register(qs.sampleINA(@frame,1))'sample INA into <frame> array
  vp.config(string("var:io"))
  vp.config(string("var:r1(base=2)"))
  vp.share(@r1,@r1)          'share variable
  cognew(@entrypoint, @r1)


DAT
              org 0 
entrypoint    mov Mem, PAR
              or DIRA, DIRMASK
rowscan       or OUTA, SCANPIN ' Scan row 1

:outerloop    andn OUTA, LOADPIN ' Set LD to low
              andn OUTA, CLKPIN ' Set clockpin low
              nop
              or OUTA, LOADPIN ' Set Load high
              mov KEYSTATE, #0
              mov bitcntr, #32 ' We're reading 32 bits...
:loop         andn OUTA, CLKPIN ' Set LD to low (Yes, this is redundant

              rcl KEYSTATE, #1 
              test SERPIN, INA WZ
        IF_NZ  add KEYSTATE, #1
              
              or OUTA, CLKPIN ' Set CLK high
              djnz bitcntr, #:loop ' Around the loop we go
              wrlong KEYSTATE, Mem
              jmp #:outerloop ' ... and back for another snapshot

DIRMASK       long %00000110_00000000_00000000_01111111
LOADPIN       long %00000010_00000000_00000000_00000000
CLKPIN        long %00000100_00000000_00000000_00000000
SERPIN        long %00001000_00000000_00000000_00000000
SCANPIN       long %00000000_00000000_00000000_00000010
BITCNTR       long %0                                
KEYSTATE      res 1
Mem           res 1                 

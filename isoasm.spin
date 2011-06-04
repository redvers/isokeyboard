CON 
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ                                  'include 2 ViewPort objects:
  vp    : "Conduit"                   'transfers data to/from PC
  qs    : "QuickSample"               'samples INA continuously in 1 cog- up to 20Msps
VAR
  long frame[400]
  long r1  
  long r2  
  long r3  
  long r4  
  long r5  
  long r6                      
  
PUB main
  r1 := $AAAAAAAA
  r2 := $BBBBBBBB
  r3 := $CCCCCCCC
  r4 := $DDDDDDDD
  r5 := $EEEEEEEE
  r6 := $FFFFFFFF

  vp.register(qs.sampleINA(@frame,1))'sample INA into <frame> array
  vp.config(string("var:io"))
  vp.config(string("var:r1(base=2),r2(base=2),r3(base=2),r4(base=2),r5(base=2),r6(base=2)"))
  vp.share(@r1,@r6)          'share variable
  cognew(@entrypoint, @r1)


DAT
              org 0 
entrypoint    mov Mem, PAR
              or DIRA, DIRMASK
:outerloop    rcl SCANPIN, #1
              or OUTA, SCANPIN
              andn OUTA, LOADPIN ' Set LD to low
              andn OUTA, CLKPIN ' Set clockpin low
              or OUTA, LOADPIN ' Set Load high
              mov KEYSTATE, #0
              mov bitcntr, #32 ' We're reading 32 bits...
:loop         andn OUTA, CLKPIN ' Set LD to low (Yes, this is redundant

              rcl KEYSTATE, #1 
              test SERPIN, INA WZ
        IF_NZ add KEYSTATE, #1
              
              or OUTA, CLKPIN ' Set CLK high
              djnz bitcntr, #:loop ' Around the loop we go

              ' First things first, copy the current value of
              ' SCANPIN to CalcPin
              mov MemVec, Mem
              'sub MemVec, #4
              mov CalcPin, SCANPIN
              ' Then compare against #$2
              
:vecfind      test CalcPin, #$2 WZ
        IF_NZ jmp #:foundvec     
              rcr CalcPin, #$1
              add MemVec, #$4
              jmp #:vecfind

:foundvec              
              wrlong KEYSTATE, MemVec
              andn OUTA, SCANPIN    ' Lower the keyboard pin just finished
              TEST SCANPIN, #$40 WZ ' Is it the last row in our keyboard array?
        IF_NZ mov SCANPIN, #1       ' If it is, sets the active row to 1.
              jmp #:outerloop       ' ... and back for another snapshot

DIRMASK       long %00000110_00000000_00000000_01111110
LOADPIN       long %00000010_00000000_00000000_00000000
CLKPIN        long %00000100_00000000_00000000_00000000
SERPIN        long %00001000_00000000_00000000_00000000
SCANPIN       long %00000000_00000000_00000000_00000010
CalcPin       long %00000000_00000000_00000000_00000000
BITCNTR       long %00000000_00000000_00000000_00000000                                
KEYSTATE      long %00000000_00000000_00000000_00000000
Mem           long %00000000_00000000_00000000_00000000
MemVec        long %00000000_00000000_00000000_00000000                 
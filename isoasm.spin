CON 
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ                                   'include 2 ViewPort objects:
  fds   : "FullDuplexSerial128"
VAR
  long r1  
  long r2  
  long r3  
  long r4  
  long r5  
  long r6
  long s1
  long s2
  long s3
  long s4
  long s5
  long s6
  long debugcount
  
PUB main
  r1 := $0 ' top row current state
  r2 := $0 ' you know, the next row
  r3 := $0 ' yadda yadda
  r4 := $0 ' ditto
  r5 := $0 ' ditto
  r6 := $0 ' bottom row current state
  s1 := $0 ' top row historical state
  s2 := $0 ' you know, the next row
  s3 := $0 ' yadda yadda
  s4 := $0 ' ditto
  s5 := $0 ' ditto
  s6 := $0 ' bottom row historical state
  debugcount := $0

  cognew(@entrypoint, @r1)

  fds.start(31,30,%0000, 38400)
 
  repeat
'   if r1 ^ s1
      compare(@r1, @s1, 0)
'      s1 := r1
'   if r2 ^ s2
      compare(@r2, @s2, 1)
'      s2 := r2
'   if r3 ^ s3
      compare(@r3, @s3, 0)
'      s3 := r3
'   if r4 ^ s4
      compare(@r4, @s4, 1)
'      s4 := r4
'   if r5 ^ s5
      compare(@r5, @s5, 0)
'      s5 := r5
'   if r6 ^ s6
      compare(@r6, @s6, 1)
'      s6 := r6             
    
    
PRI compare(x, y, offset) | t, pintest, pintestmask, tx, ty, delta
  repeat t from 31 to 0
    pintest := |< t
    delta := LONG[y] ^ LONG[x]
    if (delta & pintest)
      if (LONG[y] & pintest)
        fds.tx($80)  ' noteoff
        fds.tx((95-(t*2))+offset)
        fds.tx($40)
        !pintest
        LONG[y] := LONG[y] & pintest
        next                                                       

      if (LONG[x] & pintest)
    
        fds.tx($90)   'noteon
        fds.tx((95-(t*2))+offset)
        fds.tx($40)
        LONG[y] := LONG[y] | pintest
        next
  
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
:loop         andn OUTA, CLKPIN 'Set LD to low (Yes, this is redundant

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

DIRMASK       long %00000110_00001000_00000000_01111111
LOADPIN       long %00000010_00000000_00000000_00000000
CLKPIN        long %00000100_00000000_00000000_00000000
SERPIN        long %00001000_00000000_00000000_00000000
SCANPIN       long %00000000_00000000_00000000_00000010
CalcPin       long %00000000_00000000_00000000_00000000
BITCNTR       long %00000000_00000000_00000000_00000000                                
KEYSTATE      long %00000000_00000000_00000000_00000000
Mem           long %00000000_00000000_00000000_00000000
MemVec        long %00000000_00000000_00000000_00000000                 
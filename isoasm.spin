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

  vp.register(qs.sampleINA(@frame,1))'sample INA into <frame> array
  vp.config(string("var:io(base=2)"))
  vp.config(string("var:r1(base=2),r2(base=2),r3(base=2),r4(base=2),r5(base=2),r6(base=2),s1(base=2),s2(base=2),s3(base=2),s4(base=2),s5(base=2),s6(base=2),debugcount"))
  vp.share(@r1,@debugcount)          'share variable
  cognew(@entrypoint, @r1)
'  cognew(@delta, @r1)

  repeat
    if r1 ^ s1
      compare(r1, s1)
      s1 := r1
    if r2 ^ s2
      compare(r2, s2)
      s2 := r2
    if r3 ^ s3
      compare(r3, s3)
      s3 := r3
    if r4 ^ s4
      compare(r4, s4)
      s4 := r4
    if r5 ^ s5
      compare(r5, s5)
      s5 := r5
    if r6 ^ s6
      compare(r6, s6)
      s6 := r6
    
    
    
PRI compare(x,y)
  y := x
  debugcount += 1


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

DIRMASK       long %00000110_00000000_00000000_01111111
LOADPIN       long %00000010_00000000_00000000_00000000
CLKPIN        long %00000100_00000000_00000000_00000000
SERPIN        long %00001000_00000000_00000000_00000000
SCANPIN       long %00000000_00000000_00000000_00000010
CalcPin       long %00000000_00000000_00000000_00000000
BITCNTR       long %00000000_00000000_00000000_00000000                                
KEYSTATE      long %00000000_00000000_00000000_00000000
Mem           long %00000000_00000000_00000000_00000000
MemVec        long %00000000_00000000_00000000_00000000                 

















































org 0
delta         mov baseptr, PAR              

' Soooo... read the row scan data from main memory...
deltaloop     rdlong ROWDATA, baseptr
' Next, we must check for changes.  If no changae, we can look back around.
              xor ROWDATA, PERSDATA             NR,WZ
        IF_Z  jmp #deltaloop        ' Short Circuit

' If we reached this point, then there must be a change.
              mov count, #$20   ' We have 32 keys

:inner        rol PERSDATA, count  NR,WZ
        IF_NZ jmp #:notedon
              jmp #:notedoff

:notedon      rol ROWDATA, count   NR,WZ
              
        IF_Z  jmp #:sendnoteoff
              djnz count, #:inner  ' Note still on - no change.  Decrement + loop
              mov PERSDATA, ROWDATA
              jmp #deltaloop

        
:notedoff     rol ROWDATA, count   NR,WZ
              ' Note was already off       
       IF_NZ  jmp #:sendnoteon
              djnz count, #:inner
              mov PERSDATA, ROWDATA
              jmp #deltaloop
                                                                   
:sendnoteoff  mov txwork, #83
              jmp #:transmit
              
:sendnoteon   mov txwork, #82
              jmp #:transmit

:transmit      or txwork, STOP_BITS               ' set stop bit(s)
               shl     txwork, #1                      ' add start bit
               mov     txcount, #11                    ' start + 8 data + 2 stop
               mov     txtimer, bitticks               ' load bit timing
               add     txtimer, cnt                    ' sync with system counter

:txbit         shr     txwork, #1              wc      ' move bit0 to C
               muxc    outa, txmask                    ' output the bit
               waitcnt txtimer, bitticks               ' let timer expire, reload   
               djnz    txcount, #:txbit                 ' update bit count

               djnz count, #:inner
               mov PERSDATA, ROWDATA
               jmp #deltaloop
                                          

count         long      0
baseptr       long      0
ROWDATA       long      0
PERSDATA      long      0
XOREDATA      long      0
SEP           long      %11011110_10101101_10111110_11101111
STOP_BITS     long      $FFFF_FF00                                                                                 
bitticks      long      8333                           ' ticks per bit
txwork        res       1                               ' byte to transmit
txcount       res       1                               ' bits to transmit
txtimer       res       1                               ' tx bit timer
txmask        long      %00000000_00000001_00000000_00000000

              
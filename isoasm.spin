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
  vp.config(string("var:io(base=2)"))
  vp.config(string("var:r1(base=2),r2(base=2),r3(base=2),r4(base=2),r5(base=2),r6(base=2)"))
  vp.share(@r1,@r6)          'share variable
  cognew(@entrypoint, @r1)
'   cognew(@fakeentry, @r1)
   cognew(@delta, @r1)


DAT
              org 0
delta         mov baseptr, PAR              

' Soooo... read the row scan data from main memory...
deltaloop     rdlong ROWDATA, baseptr
' Next, we must check for changes.  If no changae, we can look back around.
              xor ROWDATA, PERSDATA             NR,WZ
        IF_Z  mov DEBUGFLAG, #1     ' IF_Z means no change
        IF_Z  jmp #deltaloop        ' Short Circuit

' If we reached this point, then there must be a change.
              mov count, #$20   ' We have 32 keys

:inner        rol PERSDATA, count  NR,WZ
        IF_NZ jmp #:notedon
              jmp #:notedoff

:notedon      rol ROWDATA, count   NR,WZ
              ' Note was already on
        IF_Z  jmp #:sendnoteoff
              djnz count, #:inner  ' Note still on - no change.  Decrement + loop
              jmp #deltaloop

        
:notedoff     rol ROWDATA, count   NR,WZ
              ' Note was already off       
       IF_NZ  jmp #:sendnoteon
              djnz count, #:inner
              jmp #deltaloop
                                                                   
:sendnoteoff  nop
              djnz count, #:inner
              mov PERSDATA, ROWDATA
              jmp #deltaloop
              
:sendnoteon   nop
              nop
              djnz count, #:inner
              mov PERSDATA, ROWDATA
              jmp #deltaloop



              mov PERSDATA, ROWDATA
end           jmp #deltaloop
            

count         long      0
baseptr       long      0
ROWDATA       long      0
PERSDATA      long      0
XOREDATA      long      0
SEP           long      %11011110_10101101_10111110_11101111
DEBUGFLAG     long      0





                                                                                                        
{{ The following section fakes a key being pressed and release in global r1.  Used for testing}}                                     
              org 0
fakeentry     mov r1ptr, PAR
              mov time, CNT
              add time, period
                            
:loop         waitcnt time, period
              mov tmp, #1
              wrlong tmp, r1ptr
              waitcnt time, period
              mov tmp, #0
              wrlong tmp, r1ptr              
              jmp #:loop
time          long      0
period        long      80*1000
r1ptr         res 1
tmp           res 1

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
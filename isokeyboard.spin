CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
OBJ                                  'include 2 ViewPort objects:
 vp    : "Terminal"                 'transfers data to/from PC
 qs    : "QuickSample"               'samples INA continuously in 1 cog- up to 20Msps
VAR
  long stack[20]
  long stack2[20]
  long frame[400]
  long tmpscan
  long line1state,line2state,line3state,line4state,line5state,line6state
  long line1persist,xorx1
  long line2persist,xorx2
  long line3persist,xorx3
  long line4persist,xorx4
  long line5persist,xorx5
  long line6persist,xorx6
  
CON
  SHLD = 23 'Low means load in.  High means load-out.
  CLK = 24  'Data shifts on a positive transition.
  SER = 25  'DataZ
PUB main
  vp.config(string("start:terminal::terminal:1"))
  vp.register(qs.sampleINA(@frame,1))'sample INA into <frame> array
  optional_configure_viewport
  vp.config(string("var:io"))
  vp.config(string("var:line1state(base=2),line2state(base=2),line3state(base=2)"))
  vp.config(string("var:line4state(base=2),line5state(base=2),line6state(base=2)"))
  vp.config(string("start:dll"))
  vp.share(@line1state,@line6state)          'share variable
  cognew(pollboard, @stack)
 
PUB pollboard
  dira[9]~~
  dira[10]~~
  dira[11]~~
  dira[12]~~
  dira[13]~~
  dira[14]~~
  dira[SHLD]~~ 'We write this.
  dira[CLK]~~  'We write this.
  dira[SER]~   'We read this.

  repeat
    outa[8]~~
    outa[9]~
    outa[10]~
    outa[11]~
    outa[12]~
    outa[13]~
    outa[14]~~
    line1state := singlescan
    outa[9]~
    outa[10]~
    outa[11]~
    outa[12]~
    outa[13]~~
    outa[14]~
    line2state := singlescan
    outa[9]~
    outa[10]~
    outa[11]~
    outa[12]~~
    outa[13]~
    outa[14]~
    line3state := singlescan
    outa[9]~
    outa[10]~
    outa[11]~~
    outa[12]~
    outa[13]~
    outa[14]~
    line4state := singlescan
    outa[9]~
    outa[10]~~
    outa[11]~
    outa[12]~
    outa[13]~
    outa[14]~
    line5state := singlescan
    outa[9]~~
    outa[10]~
    outa[11]~
    outa[12]~
    outa[13]~
    outa[14]~
    line6state := singlescan


PUB singlescan
   outa[SHLD]~ 'Load 'em up!
   outa[CLK]~~ 'Get clock in correct position for...                    
   outa[SHLD]~~'Clock transitions now shift data.                   
   tmpscan := tmpscan << 1 + ina[SER] 'First bit is already in position.
   repeat (32)           
     outa[CLK]~~            'Transit up and shift         
     tmpscan := tmpscan << 1 + ina[SER] 'Read bit    
     outa[CLK]~ 'Drop the clock in preparation for next cycle     
   return tmpscan  
  
  
  
pub optional_configure_viewport  
  vp.config(string("lsa:view=io,timescale=1ms,trigger=io[23]r"))
  vp.config(string("start:lsa"))


DAT
  janko byte  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
OBJ                                  'include 2 ViewPort objects:
 vp    : "Conduit"                 'transfers data to/from PC
 qs    : "QuickSample"               'samples INA continuously in 1 cog- up to 20Msps
VAR
  long stack[20]
  long stack2[20]
  long frame[400]
  long v1,outP,inP,v2,db,xorx
CON
  SHLD = 23 'Low means load in.  High means load-out.
  CLK = 24  'Data shifts on a positive transition.
  SER = 25  'DataZ
PUB main
  vp.register(qs.sampleINA(@frame,1))'sample INA into <frame> array
  optional_configure_viewport
  vp.config(string("var:v1,v2,v3(base=2),db(base=2),xorx(base=2)"))
  vp.config(string("start:dll"))
  vp.share(@outP,@xorx)          'share variable
cognew(pollboard, @stack)
cognew(deltaboard, @stack2)  
  
  
PUB deltaboard
  db := 0
  repeat
    xorx := v2 ^ db
    db := v2
    

PUB pollboard
  dira[12]~~
  dira[13]~~
  dira[14]~~
  dira[SHLD]~~ 'We write this.
  dira[CLK]~~  'We write this.
  dira[SER]~   'We read this.

  repeat
    outa[12]~
    outa[13]~
    outa[14]~~
    singlescan
    outa[12]~
    outa[13]~~
    outa[14]~
    singlescan
    outa[12]~~
    outa[13]~
    outa[14]~
    singlescan

PUB singlescan
   outa[SHLD]~ 'Load 'em up!
   outa[CLK]~~ 'Get clock in correct position for...                    
   outa[SHLD]~~'Clock transitions now shift data.                   
   v1 := v1 << 1 + ina[SER] 'First bit is already in position.
   repeat (32)           
     outa[CLK]~~            'Transit up and shift         
     v1 := v1 << 1 + ina[SER] 'Read bit    
     outa[CLK]~ 'Drop the clock in preparation for next cycle     
   v2 := v1
   v1 := 0
  
pub optional_configure_viewport  
  vp.config(string("var:io(bits=[cntr[12..14,23..25]]),v1,v2,v3(base=2)"))
  vp.config(string("lsa:view=io,timescale=1ms,trigger=io[23]r"))
  vp.config(string("start:lsa"))

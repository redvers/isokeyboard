CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
OBJ                                  'include 2 ViewPort objects:
 vp    : "Conduit"                 'transfers data to/from PC
 qs    : "QuickSample"               'samples INA continuously in 1 cog- up to 20Msps
 sr    : "Simple_Serial"
VAR
  long stack[20]
  long stack2[20]
  long frame[400]
  long line1persist,line2persist,line3persist,line4persist,line5persist,line6persist
  long line1s
CON
  SHLD = 25 'Low means load in.  High means load-out.
  CLK = 26  'Data shifts on a positive transition.
  SER = 27  'DataZ
PUB main
  vp.config(string("start:terminal::terminal:1"))
  vp.register(qs.sampleINA(@frame,1))'sample INA into <frame> array
  optional_configure_viewport
  vp.config(string("var:io"))
  vp.config(string("var:line1persist(base=2),line2persist(base=2),line3persist(base=2)"))
  vp.config(string("var:line4persist(base=2),line5persist(base=2),line6persist(base=2)"))
  vp.config(string("var:line1s(base=2)"))
  vp.config(string("start:dll"))
  vp.share(@line1persist,@line1s)          'share variable

  sr.init(1,0,9600)
  sr.str(String("Hello World"))
  sr.tx(13)
  sr.tx(10)
'  sr.str(String("Hello again!"))

  cognew(pollboard, @stack)
  cognew(delta, @stack2)

PUB delta | xorx, ptr,t
  repeat
    xorx := line1persist ^ line1s
    if xorx == 0
        return
    sr.str(String("X"))
{{    repeat ptr from 31 to 0
      t := line1persist & $0000_0000_0000_0001
      if t == 1
        sr.str(String("Pin "))
        sr.str(ptr)
        sr.tx(13)
        sr.tx(10)
      line1persist ->= 1
 }}
 
PUB pollboard
  dira[1]~~
  dira[2]~~
  dira[3]~~
  dira[4]~~
  dira[5]~~
  dira[6]~~
  dira[SHLD]~~ 'We write this.
  dira[CLK]~~  'We write this.
  dira[SER]~   'We read this.

  repeat
    outa[1]~
    outa[2]~
    outa[3]~
    outa[4]~
    outa[5]~
    outa[6]~~
    line1persist := singlescan
    outa[1]~
    outa[2]~
    outa[3]~
    outa[4]~
    outa[5]~~
    outa[6]~
    line2persist := singlescan    
    outa[1]~
    outa[2]~
    outa[3]~
    outa[4]~~
    outa[5]~
    outa[6]~
    line3persist := singlescan
    outa[1]~
    outa[2]~
    outa[3]~~
    outa[4]~
    outa[5]~
    outa[6]~
    line4persist := singlescan
    outa[1]~
    outa[2]~~
    outa[3]~
    outa[4]~
    outa[5]~
    outa[6]~
    line5persist := singlescan
    outa[1]~~
    outa[2]~
    outa[3]~
    outa[4]~
    outa[5]~
    outa[6]~
    line6persist := singlescan


PUB singlescan | tmpscan,t,b
   outa[SHLD]~ 'Load 'em up!
   outa[CLK]~ 'Get clock in correct position for...                    
   outa[SHLD]~~'Clock transitions now shift data.                   

   repeat t from 31 to 0
     outa[CLK]~ 'Transit up and shift
     
     tmpscan := tmpscan << 1 + ina[SER] 'Read bit
     outa[CLK]~~ 'Drop the clock in preparation for next cycle 
  
   return tmpscan
  
  
  
pub optional_configure_viewport  
  vp.config(string("lsa:view=io,timescale=1ms,trigger=io[25]r"))
  vp.config(string("start:lsa"))


DAT
  janko byte  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
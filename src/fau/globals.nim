import fmath, framebuffer, shader, batch, color, patch, texture, mesh, atlas

type KeyCode* = enum
  keyA, keyB, keyC, keyD, keyE, keyF, keyG, keyH, keyI, keyJ, keyK, keyL, keyM, keyN, keyO, keyP, keyQ, keyR, keyS, keyT, keyU,
  keyV, keyW, keyX, keyY, keyZ, key1, key2, key3, key4, key5, key6, key7, key8, key9, key0, keyReturn, keyEscape, keyBackspace,
  keyTab, keySpace, keyMinus, keyEquals, keyLeftbracket, keyRightbracket, keyBackslash, keyNonushash, keySemicolon, keyApostrophe, keyGrave, keyComma, keyPeriod,
  keySlash, keyCapslock, keyF1, keyF2, keyF3, keyF4, keyF5, keyF6, keyF7, keyF8, keyF9, keyF10, keyF11, keyF12, keyPrintscreen, keyScrolllock,
  keyPause, keyInsert, keyHome, keyPageup, keyDelete, keyEnd, keyPagedown, keyRight, keyLeft, keyDown, keyUp, keyNumlockclear, keyKpDivide, keyKpMultiply,
  keyKpMinus, keyKpPlus, keyKpEnter, keyKp1, keyKp2, keyKp3, keyKp4, keyKp5, keyKp6, keyKp7, keyKp8, keyKp9, keyKp0, keyKpPeriod, keyNonusbackslash,
  keyApplication, keyPower, keyKpEquals, keyF13, keyF14, keyF15, keyF16, keyF17, keyF18, keyF19, keyF20, keyF21, keyF22, keyF23, keyF24,
  keyExecute, keyHelp, keyMenu, keySelect, keyStop, keyAgain, keyUndo, keyCut, keyCopy, keyPaste, keyFind, keyMute, keyVolumeup, keyVolumedown,
  keyKpComma, keyAlterase, keySysreq, keyCancel, keyClear, keyPrior, keyReturn2, keySeparator, keyOut, keyOper, keyClearagain,
  keyCrsel, keyExsel, keyDecimalseparator, keyLctrl, keyLshift, keyLalt, keyLgui, keyRctrl,
  keyRshift, keyRalt, keyRgui, keyMode, keyUnknown,
  keyMouseLeft, keyMouseMiddle, keyMouseRight

#discriminator for the various types of input events
type FauEventKind* = enum
  ## any key down/up, including mouse
  feKey,
  ## mouse/pointer moved across screen
  feDrag,
  ## finger up/down at location
  feTouch,
  ## mousewheel scroll up/down
  feScroll,
  ## window resized
  feResize

#a generic input event
type FauEvent* = object
  case kind*: FauEventKind
  of feKey:
    key*: KeyCode
    keyDown*: bool
  of feDrag:
    dragId*: int
    dragPos*: Vec2
  of feTouch:
    touchId*: int
    touchPos*: Vec2
    touchDown*: bool
    touchButton*: KeyCode
  of feScroll:
    scroll*: Vec2
  of feResize:
    size*: Vec2i

type FauListener* = proc(e: FauEvent)
  
#A touch position.
type Touch* = object
  pos*, delta*, last*: Vec2
  down*: bool

#Hold all the graphics state.
type FauState* = object
  #Screen clear color
  clearColor*: Color
  #The batch that does all the drawing
  batch*: Batch
  #Scaling of each pixel when drawn with a batch
  pixelScl*: float32
  #A white 1x1 patch
  white*: Patch
  #A white circle patch
  circle*: Patch
  #The global camera.
  cam*: Cam
  #Fullscreen quad mesh.
  quad*: SMesh
  #Screenspace shader
  screenspace*: Shader
  #Global texture atlas.
  atlas*: Atlas
  #Frame number
  frameId*: int64
  #Smoothed frames per second
  fps*: int
  #Delta time between frames in 60th of a second
  delta*: float32
  #Maximum value that the delta can be - prevents erratic behavior at low FPS values. Default: 1/60
  maxDelta*: float32
  #Time passed since game launch, in seconds
  time*: float32
  #All input listeners
  listeners*: seq[FauListener]

  #Game window size
  sizei*: Vec2i
  #Game window size in floats
  size*: Vec2
  #Screen density, for mobile devices
  screenDensity*: float32
  #Safe insets for mobile devices. Order: top, right, bot, left
  insets*: array[4, float32]

  #Mouse position
  mouse*: Vec2
  #Last scroll values
  scroll*: Vec2
  #All last known touch pointer states
  touches*: array[10, Touch]

#Global instance of fau state.
var fau* = FauState()

proc fireFauEvent*(ev: FauEvent) =
  for l in fau.listeners: l(ev)

proc addFauListener*(ev: FauListener) =
  fau.listeners.add ev

#TODO not sure where else to put this?

#Turns pixel units into world units
proc px*(val: float32): float32 {.inline.} = val * fau.pixelScl
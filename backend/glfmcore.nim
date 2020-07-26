import glfm, glad, ../common

var keysPressed: array[KeyCode, bool]
var keysJustDown: array[KeyCode, bool]
var keysJustUp: array[KeyCode, bool]
var lastScrollX, lastScrollY: float

proc down*(key: KeyCode): bool {.inline.} = keysPressed[key]
proc tapped*(key: KeyCode): bool {.inline.} = keysJustDown[key]
proc released*(key: KeyCode): bool {.inline.} = keysJustUp[key]

#[
proc toKeyCode(scancode: cint): KeyCode = 
  result = case scancode:
    of KEY_SPACE: keySpace
    of KEY_APOSTROPHE: keyApostrophe
    of KEY_COMMA: keyComma
    of KEY_MINUS: keyMinus
    of KEY_PERIOD: keyPeriod
    of KEY_SLASH: keySlash
    of KEY_0: key0
    of KEY_1: key1
    of KEY_2: key2
    of KEY_3: key3
    of KEY_4: key4
    of KEY_5: key5
    of KEY_6: key6
    of KEY_7: key7
    of KEY_8: key8
    of KEY_9: key9
    of KEY_SEMICOLON: keySemicolon
    of KEY_EQUAL: keyEquals
    of KEY_A: keyA
    of KEY_B: keyB
    of KEY_C: keyC
    of KEY_D: keyD
    of KEY_E: keyE
    of KEY_F: keyF
    of KEY_G: keyG
    of KEY_H: keyH
    of KEY_I: keyI
    of KEY_J: keyJ
    of KEY_K: keyK
    of KEY_L: keyL
    of KEY_M: keyM
    of KEY_N: keyN
    of KEY_O: keyO
    of KEY_P: keyP
    of KEY_Q: keyQ
    of KEY_R: keyR
    of KEY_S: keyS
    of KEY_T: keyT
    of KEY_U: keyU
    of KEY_V: keyV
    of KEY_W: keyW
    of KEY_X: keyX
    of KEY_Y: keyY
    of KEY_Z: keyZ
    of KEY_LEFT_BRACKET: keyLeftBracket
    of KEY_BACKSLASH: keyBackslash
    of KEY_RIGHT_BRACKET: keyRightBracket
    of KEY_GRAVE_ACCENT: keyGrave
    of KEY_ESCAPE: keyEscape
    of KEY_ENTER: keyReturn
    of KEY_TAB: keyTab
    of KEY_BACKSPACE: keyBackspace
    of KEY_INSERT: keyInsert
    of KEY_DELETE: keyDelete
    of KEY_RIGHT: keyRight
    of KEY_LEFT: keyLeft
    of KEY_DOWN: keyDown
    of KEY_UP: keyUp
    of KEY_PAGE_UP: keyPageUp
    of KEY_PAGE_DOWN: keyPageDown
    of KEY_HOME: keyHome
    of KEY_END: keyEnd
    of KEY_CAPS_LOCK: keyCapsLock
    of KEY_SCROLL_LOCK: keyScrollLock
    of KEY_NUM_LOCK: keyNumlockclear
    of KEY_PRINT_SCREEN: keyPrintScreen
    of KEY_PAUSE: keyPause
    of KEY_F1: keyF1
    of KEY_F2: keyF2
    of KEY_F3: keyF3
    of KEY_F4: keyF4
    of KEY_F5: keyF5
    of KEY_F6: keyF6
    of KEY_F7: keyF7
    of KEY_F8: keyF8
    of KEY_F9: keyF9
    of KEY_F10: keyF10
    of KEY_F11: keyF11
    of KEY_F12: keyF12
    of KEY_F13: keyF13
    of KEY_F14: keyF14
    of KEY_F15: keyF15
    of KEY_F16: keyF16
    of KEY_F17: keyF17
    of KEY_F18: keyF18
    of KEY_F19: keyF19
    of KEY_F20: keyF20
    of KEY_F21: keyF21
    of KEY_F22: keyF22
    of KEY_F23: keyF23
    of KEY_F24: keyF24
    of KEY_KP_0: keyKp0
    of KEY_KP_1: keyKp1
    of KEY_KP_2: keyKp2
    of KEY_KP_3: keyKp3
    of KEY_KP_4: keyKp4
    of KEY_KP_5: keyKp5
    of KEY_KP_6: keyKp6
    of KEY_KP_7: keyKp7
    of KEY_KP_8: keyKp8
    of KEY_KP_9: keyKp9
    of KEY_KP_DIVIDE: keyKpDivide
    of KEY_KP_MULTIPLY: keyKpMultiply
    of KEY_KP_ENTER: keyKpEnter
    of KEY_LEFT_SHIFT: keyLshift
    of KEY_LEFT_CONTROL: keyLctrl
    of KEY_LEFT_ALT: keyLalt
    of KEY_RIGHT_SHIFT: keyRShift
    of KEY_RIGHT_CONTROL: keyRCtrl
    of KEY_RIGHT_ALT: keyRAlt
    of KEY_MENU: keyMenu
    else: keyUnknown

proc mapMouseCode(code: cint): KeyCode = 
  result = case code:
    of MOUSE_BUTTON_LEFT: keyMouseLeft
    of MOUSE_BUTTON_RIGHT: keyMouseRight
    of MOUSE_BUTTON_MIDDLE: keyMouseMiddle
    else: keyUnknown
]#

proc NimMain() {.importc.} # use --noMain:on which generates NimMain() instead of C main()

var
  cloopProc: proc()
  cinitProc: proc()
  cclearColor: Color

proc glfmMain*(display: ptr GLFMDisplay) {.exportc.} =
  NimMain()

  display.glfmSetSurfaceErrorFunc(proc(display: ptr GLFMDisplay; message: cstring) {.cdecl.} =
    raise Exception.newException("GLFM error: " & $message)
  )

  echo "Initialized GLFM v" & $GLFM_VERSION_MAJOR & "." & $GLFM_VERSION_MINOR

  #TODO should probably respect config options for this
  display.glfmSetDisplayConfig(GLFMRenderingAPIOpenGLES2, GLFMColorFormatRGBA8888, GLFMDepthFormatNone, GLFMStencilFormatNone, GLFMMultisampleNone)

  if not loadGl(glfmGetProcAddress):
    raise Exception.newException("Failed to load OpenGL.")

  echo "Initialized OpenGL v" & $glVersionMajor & "." & $glVersionMinor

  #listen to window size changes and relevant events.

  display.glfmSetSurfaceResizedFunc(proc(surf: ptr GLFMDisplay, width, height: cint) {.cdecl.} = 
    (fuse.width, fuse.height) = (width.int, height.int)
    glViewport(0.GLint, 0.GLint, width.GLsizei, height.GLsizei)
  )

  display.glfmSetTouchFunc(proc(display: ptr GLFMDisplay, touch: cint, phase: GLFMTouchPhase, x, y: cdouble): bool {.cdecl.} = 
    (fuse.mouseX, fuse.mouseY) = (x.float32, fuse.height.float32 - 1 - y.float32)
    return true
  )

  #[
  display.glfmSetKeyFunc(proc(display: ptr GLFMDisplay, keyCode: GLFMKey, action: GLFMKeyAction, modifiers: cint): bool = 
    let code = toKeyCode(key)
    
    case action:
      of PRESS: 
        keysJustDown[code] = true
        keysPressed[code] = true
      of RELEASE: 
        keysJustUp[code] = true
        keysPressed[code] = false
      else: discard

      return true
  )]#

  #grab the state
  var 
    inWidth: cint = 0
    inHeight: cint = 0

  display.glfmGetDisplaySize(addr inWidth, addr inHeight)
  fuse.width = inWidth.int
  fuse.height = inHeight.int
  
  glViewport(0.GLint, 0.GLint, inWidth.GLsizei, inHeight.GLsizei)

  cinitProc()

  display.glfmSetMainLoopFunc(proc(display: ptr GLFMDisplay; frameTime: cdouble) {.cdecl.} =
    clearScreen(cclearColor)

    cloopProc()

    #clean up input
    for x in keysJustDown.mitems: x = false
    for x in keysJustUp.mitems: x = false
    lastScrollX = 0
    lastScrollY = 0
  )

#most parameters are ignored here
proc initCore*(loopProc: proc(), initProc: proc() = (proc() = discard), windowWidth = 800, windowHeight = 600, windowTitle = "Unknown", maximize = true, depthBits = 0, stencilBits = 0, clearColor = rgba(0, 0, 0, 0)) =
  cloopProc = loopProc
  cinitProc = initProc
  cclearColor = clearColor

#implemented as a stub method for feature parity
proc `windowTitle=`*(title: string) = discard

#stops the game immediately
proc quitApp*() = quit(0)
import os, nimterop/[cimport, build], macros

const
  FLAGS {.strdefine.} = ""

  baseDir = getProjectCacheDir("fuse" / "soloud")
  incl = baseDir/"include"
  src = baseDir/"src"

#TODO switch to own fork, it's not (as) bugged
static:
  gitPull("https://github.com/Anuken/soloud", baseDir, "include/*\nsrc/*\n", checkout = "master")

cOverride:
  type
    Soloud* = pointer
    AlignedFloatBuffer* = pointer

  proc Soloud_destroy*(aSoloud: ptr Soloud) {.importc: "Soloud_destroy", header: cSearchPath(incl/"soloud_c.h").}

cIncludeDir(incl)

when defined(emscripten):
  {.passL: "-lpthread".}
  cDefine("WITH_SDL2_STATIC")
  cCompile(src/"backend/sdl2_static/*.cpp")
elif defined(osx):
  cDefine("WITH_COREAUDIO")
  {.passL: "-framework CoreAudio -framework AudioToolbox".}
  cCompile(src/"backend/coreaudio/*.cpp")
elif defined(Android):
  {.passL: "-lOpenSLES".}
  cDefine("WITH_OPENSLES")
  cCompile(src/"backend/opensles/*.cpp")
elif defined(Linux):
  {.passL: "-lpthread".}
  cDefine("WITH_MINIAUDIO")
  cCompile(src/"backend/miniaudio/*.cpp")
elif defined(Windows):
  {.passC: "-msse".}
  {.passL: "-lwinmm".}
  cDefine("WITH_WINMM")
  cCompile(src/"backend/winmm/*.cpp")
else:
  static: doAssert false

cCompile(src/"c_api/soloud_c.cpp")
cCompile(src/"core/*.cpp")
cCompile(src/"audiosource", "cpp", exclude="ay/")
cCompile(src/"audiosource", "c")
cCompile(src/"filter/*.cpp")

cImport(incl/"soloud_c.h", flags = FLAGS)
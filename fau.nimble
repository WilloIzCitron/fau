version       = "0.0.1"
author        = "Anuken"
description   = "WIP Nim game framework"
license       = "MIT"
srcDir        = "src"
bin           = @["fau/tools/faupack"]
binDir        = "build"

requires "nim >= 2.0.0"
requires "https://github.com/Anuken/staticglfw#4c4152b22299c5344472a792e55a1aede296e33d"
requires "https://github.com/Anuken/glfm#be73f6862533c4cccedfac512d7766c8a30f3122"
requires "https://github.com/Anuken/nimsoloud#c74878dcb60fd2e2af84f894a8a8ffe901aecd51"
requires "https://github.com/Anuken/polymorph#15bbc5da4223194d27520581e155521e495a9528"
requires "cligen == 1.6.17"
requires "chroma == 0.2.7"
requires "pixie == 5.0.6"
requires "vmath == 2.0.0"
requires "stbimage == 2.5"
requires "jsony == 1.1.5"
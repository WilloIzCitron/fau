version       = "0.0.1"
author        = "Anuken"
description   = "WIP Nim game framework"
license       = "MIT"
srcDir        = "src"
bin           = @["fau/tools/faupack", "fau/tools/antialias", "fau/tools/fauproject", "fau/tools/bleed"]
binDir        = "build"

requires "nim >= 1.4.8"
requires "https://github.com/treeform/staticglfw#f6a40acf98466c3a11ab3f074a70d570c297f82b"
requires "polymorph >= 0.3.0"
requires "cligen >= 1.5.19"
requires "chroma >= 0.2.5"
requires "pixie >= 4.0.1"
requires "vmath >= 1.0.8"
requires "stbimage >= 2.5"
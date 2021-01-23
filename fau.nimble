version       = "0.0.1"
author        = "Anuken"
description   = "WIP Nim game framework"
license       = "MIT"
srcDir        = ""
bin           = @["tools/faupack", "tools/antialias", "tools/fauproject"]
binDir        = "build"

requires "nim >= 1.4.2"
requires "https://github.com/rlipsc/polymorph#0241b43d60ae37aea881f4a0a550705741b28dc0"
requires "https://github.com/treeform/staticglfw#d299a0d1727054749100a901d3b4f4fa92ed72f5"
requires "nimPNG >= 0.3.1"
requires "cligen >= 1.3.2"
requires "chroma >= 0.2.1"

#TODO: pixie 0.0.14 has multiple issues; https://github.com/treeform/pixie/pull/66 + https://github.com/treeform/pixie/pull/65
requires "typography >= 0.7.3"
requires "pixie >= 0.0.14"
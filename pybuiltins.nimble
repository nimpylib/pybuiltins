# Package

version       = "0.1.0"
author        = "litlighilit"
description   = "Python builtins function porting to Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim > 2.0.8"

var pylibPre = "https://github.com/nimpylib"
let envVal = getEnv("NIMPYLIB_PKGS_BARE_PREFIX")
if envVal != "": pylibPre = ""
#if pylibPre == Def: pylibPre = ""
elif pylibPre[^1] != '/':
  pylibPre.add '/'
template pylib(x, ver) =
  requires if pylibPre == "": x & ver
           else: pylibPre & x

pylib "pyrepr", " ^= 0.1.1"
pylib "pystrbytes_decl", " ^= 0.1.0"
pylib "handy_sugars", " ^= 0.1.0"
pylib "auditfunc", " ^= 0.1.0"
pylib "py_sys_stdio", " ^= 0.1.0"
pylib "py_commontypes", " ^= 0.1.0"
pylib "py_constants", " ^= 0.1.0"
pylib "collections_abc", " ^= 0.1.0"
pylib "pyerrors", " ^= 0.1.0"
pylib "float_utils", " ^= 0.1.1"

import std/os
proc runTestament(targets = "c") =
  exec "testament --targets:" & targets.quoteShell &  " p 'tests/pkgs/*.nim'"

task testament, "run testament":
  runTestament(if defined(js): "js" else: "c")

task test, "test all":
  testamentTask()



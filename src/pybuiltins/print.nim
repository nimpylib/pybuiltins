import std/macros
import pkg/py_sys_stdio as sys
import pkg/py_constants/noneType
import pkg/pystrbytes_decl/strimpl

when defined(nimPreviewSlimSystem):
  import std/[syncio, assertions]
import pkg/vsyncio

when not defined(js) and not defined(nimscript):
  import std/locks
  when NimMajor == 1:
    template addExitProc(f) = addQuitProc(f)
  else:
    import std/exitprocs
else:
  template withLock(_; body) = body

from std/strutils import join, escape

# NOTE: `echo`'s newline is `\n`
template isEchoNL(c: char): bool = c == '\n'
template isEchoNL(c: string): bool = c == "\n"

template vmPrintStdoutNoNL(msg: string) =
  when defined(windows):
    # relay on PowerShell
    let
      nmsg = msg.escape.escape("", "")
      cmd = "powershell -c \"[System.Console]::Write(" & nmsg & ")\""
  else:
    let
      nmsg = escape msg
      cmd = "echo -n " & nmsg
  when declared(exec):  # NimScript
    exec cmd
  else:
    # gorge cannot help as it just returns output
    discard cmd  ## for lint check: [XDeclaredButNotUsed]
    notImpl "nimvm"

type PriArgs = openArray[string]
proc printImpl(objects: PriArgs; sep:char|string=' ', endl:char|string='\n',
              file: auto = None, flush=false) =
  bind withLock
  template notImpl(backend; supportEnd=false; extraMsg="") =
    const msg = "print with file != None " & 
        (when supportEnd: "" else: "or endl != '\\n'") &
        " is not supported for " &
        astToStr(backend) & " backend." & extraMsg
    when defined(nimscript):
      {.error: "not impl: " & msg.}
    else:
      raise newException(OSError, msg)
  template vmPrintImpl =
    when file is_not NoneType:
      notImpl "NimScript", true
    # We know sys.std* cannot be modified at compile-time
    if not endl.isEchoNL:
      vmPrintStdoutNoNL(objects.join(sep) & endl)
    else:
      echo objects.join sep
    return
  when sep is char:
    let sep = $sep  # strutils.join only accept string sep
  when nimvm: vmPrintImpl
  else:
    when defined(nimscript):
      vmPrintImpl
    else:
      static:
        # check here instead of using `file: xxx` in param list
        # as `File` cannot appear when nimvm
        when declared(sys.stdout):
          type Param = NoneType|syncio.File|vsyncio.File|typeof(sys.stdout)
        else:
          type Param = NoneType|syncio.File|vsyncio.File
        assert file is Param
      when defined(js):
        template toStdout(objects) =
          vsyncio.stdout.write objects.join(sep) & endl

        when file is syncio.File:
          if file == syncio.stdout: toStdout objects
          else: notImpl "JavaScript", true, " please use vsyncio.File instead of syncio.File"
      else:
        var lockPrint{.global.}: Lock
        when nimvm: discard
        else:
          once:
            lockPrint.initLock()
            addExitProc( proc(){.noconv.} = lockPrint.deinitLock() )
      when file is NoneType:
        let file = sys.stdout
        if file.isNil:
          return
      # Write all objects joined by sep
      let le = len objects
      withLock lockPrint:
        if le != 0:
          file.write(objects[0])
          for i in 1..<le:
            file.write(sep)
            file.write(objects[i])
        # Write end of line
        file.write(endl)
        # If flush is needed, flush the file
        if flush:
          when file is syncio.File|vsyncio.File: file.flushFile
          else: file.flush()

template printImpl(objects: PriArgs; sep:char|string=' ', `end`:char|string='\n',
  file: untyped = None, flush=false) = printImpl(objects, sep, `end`, file, flush)

macro print*(data: varargs[untyped]): untyped =
  ## Print macro identical to Python `print()` function.
  ##
  ## .. hint::
  ##   Due to `end` being keyword of Nim,
  ##   it has to be written as `endl` or **\`end\`** here.
  let printProc = bindSym("printImpl")
  var objects = newTree(nnkBracket)
  var arguments = newTree(nnkArglist)
  for arg in data:
    if arg.kind == nnkExprEqExpr:
      # Add keyword argument
      arguments.add(arg)
    else:
      # Add object and stringify it automatically
      objects.add(newCall("$", newCall(bindSym"str", arg)))
  result = quote do:
    `printProc`(`objects`, `arguments`)

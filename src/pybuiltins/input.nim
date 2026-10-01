
import ./print
import pkg/pystrbytes_decl/strimpl
import pkg/vsyncio/extra/rdstdinMayAsync
import ./private/sys

const hasStdio = declared(sys.stdin) and declared(sys.stdout)

when hasStdio:
  import pkg/pyerrors/rterr
  template lost(std) = raise newException(RuntimeError, "input() lost " & std)

proc inputImpl: PyStr =
  when defined(nimscript):
    # XXX: currently sys.stdin is not available on nimscript
    static: assert not compiles(sys.stdin)
    readLineFromStdin()
  elif npythonJsAsyncReadline:
    sys.stdin.readline()
  else:
    readLineFromStdinMayAsync("")

proc inputImpl(prompt: string): PyStr =
    if prompt.len != 0:
      print(prompt, endl="")
    inputImpl()

proc input*(prompt = str("")): PyStr =
  ##
  ## when on non-nodejs JavaScript backend,
  ## uses `prompt`
  sys.audit("builtins.input", prompt)
  when hasStdio:
    if sys.stdin.isNil: lost "stdin"
    if sys.stdout.isNil: lost "stdout"
  inputImpl prompt


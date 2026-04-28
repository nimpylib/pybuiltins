discard """
  cmd: "nim c --hints:off -d:testing $options $file"
  nimout: '''
abc
'''
"""

import pybuiltins/print

static:
  #print("a1 ", endl="")  # XXX: cannot impl
  print("abc")



discard """
  action: "run"
  targets: "c js"

  joinable: true

  batchable: true

  output: '''
34 321
'''
"""

import pybuiltins/print
print(34, endl=' ')
print(32, `end`="")
print(1)



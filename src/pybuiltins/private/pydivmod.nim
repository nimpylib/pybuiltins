
import std/math
import pkg/pyerrors/aritherr

template zeRaise(x) =
  if x == typeof(x)(0):
    raise newException(ZeroDivisionError, "division or modulo by zero")

func `%`*[T: SomeNumber](a, b: T): T =
  ## Python's modulo (a.k.a `floor modulo`)  (`quotient`)
  ## 
  ## .. hint:: Nim's `mod` is the same as `a - b * (a div b)` (`remainder`),
  ##   just like `C`.
  runnableExamples:
    assert 13 % -3 == -2
    assert -13 % 3 == 2
  zeRaise b
  floorMod a,b

template `%`*[A: SomeFloat, B: SomeInteger](a: A, b: B): A = a % A(b)
template `%`*[A: SomeInteger; B: SomeFloat](a: A, b: B): B = B(a) % b

func `//`*[A, B: SomeFloat | SomeInteger](a: A, b: B): SomeNumber {.inline.} =
  ## Python's division (a.k.a. `floor division`)
  ## 
  ## .. hint:: Nim's `div` is division with any fractional part discarded
  ##    (a.k.a."truncation toward zero"), just like `C`.
  runnableExamples:
    assert 13 // -3 == -5
    assert 13 div -3 == -4
  when A is SomeInteger and B is SomeInteger:
    (a - a % b) div b
  else:
    (a.float - a % b) / b.float
func divmod*[T: SomeNumber](x, y: T): (T, T) = 
  ## differs from `std/math` `divmod`, see `//`_ and `%`_ for details.
  (x//y, x%y)


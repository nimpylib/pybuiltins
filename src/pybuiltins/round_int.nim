
import ./round/int_round
import pkg/py_constants/noneType

func round*(x: int, _: NoneType): int = int_round.round(x)
export int_round.round


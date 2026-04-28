
import pkg/pystrbytes_decl/strimpl
import ./private/format_impl

proc format*[T](self: T, spec: static[string]|string): PyStr =
  str format_impl.format(self, spec)

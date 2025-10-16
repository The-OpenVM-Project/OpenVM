package OpenVM

import "base:runtime"
import "core:c"

OPEN_VM_ODIN_CTX := runtime.default_context()


Value :: union {
    c.double,
    cstring,
    c.bool
}

ExecuteSingleInstruction :: proc(stack: Stack, bytecode: u8) {

}



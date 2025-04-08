package IO

import "core:fmt"
import "core:os"

@export
OpenVM_Print :: proc(str: string) {
    when ODIN_DEBUG {
        fmt.printf("(DEBUG MODE) [OpenVM/IO]: <STDIO> ~ %s", str)
    }
    else {
        fmt.print(str)
    }
}

@export
OpenVM_Input :: proc(prompt: string) -> string {
}
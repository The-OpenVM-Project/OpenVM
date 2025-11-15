package OpenVM

import "core:fmt"
import "core:sync"




Level :: enum {
    DEBUG,
    INFO,
    WARN,
    ERROR,
    CRITICAL
}

@(private="file")
logger_mutex: ^sync.Mutex

@(init, private="file")
InitLogger :: proc() {
    logger_mutex = new(sync.Mutex)
}

@(fini, private="file")
ShutdownLogger :: proc() {
    free(logger_mutex)
}

// --- Logging function ---
Log :: proc(level: Level, component, msg: string) {
    sync.lock(logger_mutex)
    defer sync.unlock(logger_mutex)
    if !ODIN_DEBUG  && level == .DEBUG {
        // no op
    }
    else if level == .CRITICAL {
        fmt.panicf("[%s]: <%s> ~ %s\n", component, level, msg)
    }
    else {
        fmt.printfln("[%s]: <%s> ~ %s\n", component, level, msg)
    }
}

@(cold)
DumpStack :: proc(stack: ^Stack) {
    fmt.println("OPEN_VM STACK_TRACE:")
    fmt.println("Capacity:", stack.cap, "Pointer:", stack.ptr)

    for value,  i in stack.data[0:stack.ptr] {
        fmt.print("  [", i, "] = ")

        switch v in value {
        case f32le:
            fmt.println(v)
        case string:
            fmt.println("\"", v, "\"")
        case b8:
            if value.(b8) != false {
               fmt.println("true")
            } else {
                fmt.println("false")
            }
        case uintptr:
            fmt.println("uintptr:", v)
        }
    }
}
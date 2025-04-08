package ExceptionSystem

import "../../OpenVMLibraryLoader/Types"
import "../../OpenVMLibraryLoader"
import "core:fmt"
import "core:sync"

/* NOTE: the exeption system only cares about ERR_REG_A 
   witch means that you are free to use ERR_REG_B and ERR_REG_C for minor errors or custom error data
*/


LibLoader :: OpenVMLibraryLoader
@export
MM: LibLoader.INTERNAL_MemoryManager

@init
OpenVM_CheckLoadedMM :: proc() {
    if &MM == nil {
        panic("[OpenVM/Exception System]: <ERR_MEMORY_MANAGER_LOAD_FAILURE> ~ Failed to load MemoryManager!")
    }
}

@export
// CALL THIS WHEN SHIT HITS THE FAN
OpenVM_CrashAndBurn :: proc(error_code: Types.EXCEPTIONS, error_message: string, cleanup_func: proc()) {
    fmt.printf("[OpenVM/Exception System]: <ERR_BYTECODE_EXEPTION> ~ %d\n", error_code);
    fmt.printf("Error Message: %s\n", error_message);
    cleanup_func()

}

@export
OpenVM_SetERR_REG_A :: proc(error_code: Types.EXCEPTIONS) {
    sync.lock(MM.ERR_REG_A_MUTEX)
    defer sync.unlock(MM.ERR_REG_A_MUTEX)
    MM.ERR_REG_A^ = error_code

}

@export
OpenVM_GetERR_REG_A :: proc() -> Types.EXCEPTIONS {
    sync.lock(MM.ERR_REG_A_MUTEX)
    result := MM.ERR_REG_A^
    sync.unlock(MM.ERR_REG_A_MUTEX)
    return result
}

@export
OpenVM_SetERR_REG_B :: proc(error_code: i32) {
    sync.lock(MM.ERR_REG_B_MUTEX)
    defer sync.unlock(MM.ERR_REG_B_MUTEX)
    MM.ERR_REG_B^ = error_code

}

@export
OpenVM_GetERR_REG_B :: proc() -> i32 {
    sync.lock(MM.ERR_REG_B_MUTEX)
    result := MM.ERR_REG_B^
    sync.unlock(MM.ERR_REG_B_MUTEX)
    return result
}

@export
OpenVM_SetERR_REG_C :: proc(error_code: i8) {
    sync.lock(MM.ERR_REG_C_MUTEX)
    defer sync.unlock(MM.ERR_REG_C_MUTEX)
    MM.ERR_REG_C^ = error_code

}

@export
OpenVM_GetERR_REG_C :: proc() -> i8 {
    sync.lock(MM.ERR_REG_C_MUTEX)
    result := MM.ERR_REG_C^
    sync.unlock(MM.ERR_REG_C_MUTEX)
    return result
}
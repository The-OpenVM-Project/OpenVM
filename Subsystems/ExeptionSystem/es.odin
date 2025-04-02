package ExceptionSystem

import "../../OpenVMLibraryLoader/Types"
import "../../OpenVMLibraryLoader"

LibLoader :: OpenVMLibraryLoader
@export
MM: LibLoader.INTERNAL_MemoryManager

@init
OpenVM_CheckLoadedMM :: proc() {
    if &MM == nil {
        panic("[OpenVM/Exception System]: <ERR_MEMORY_MANAGER_LOAD_FAILURE> Failed to load MemoryManager!")
    }
}


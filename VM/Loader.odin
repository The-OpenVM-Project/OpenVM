package OpenVMLoader

import "core:fmt"
import "core:dynlib"

OpenVM :: struct {
    
    _handle: dynlib.Library
}

LoadOpenVM :: proc(openvm_shared_obj_path: string) -> (^OpenVM, int) {
    table := new(OpenVM)
    count, ok := dynlib.initialize_symbols(table, openvm_shared_obj_path)
    if !ok {
        panic(dynlib.last_error())
    }
    return table, count
}

UnloadOpenVM :: proc(table: ^OpenVM) {
    did_unload := dynlib.unload_library(table._handle)
    if !did_unload {
        panic("Could not unload OpenVM")
    }
    free(table)
}
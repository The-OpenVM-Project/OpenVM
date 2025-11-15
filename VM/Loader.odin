package OpenVMLoader

import "core:dynlib"

/*
The OpenVM stack
NOTE(A-Boring-Square): this is opaque because
the Stack is technicaly an internal implmentation detail
*/
Stack :: struct {}

// External function type
ExternalFunction :: #type proc(stack: ^Stack)

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
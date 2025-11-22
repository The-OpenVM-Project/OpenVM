package OpenVMLoader

import "core:dynlib"

VM_VERSION_MAJOR :: "1"
VM_VERSION_MINOR :: "0"
VM_VERSION_PATCH :: "0"

VM_VERSION :: VM_VERSION_MAJOR + "." + VM_VERSION_MINOR + "." + VM_VERSION_PATCH
VM_ODIN_COMPILER_VERSION :: ODIN_VERSION


VM_LOGO :: `
Part of the
  ____              _   ____  ___
 / __ \___  ___ ___| | /  /  |/  /
/ /_/ / _ \/ -_) _ \ |/  / /|_/ /
\____/ .__/ \__/_//_/___/_/  /_/
    /_/
Project

Text-Based Bytecode Virtual Machine
VERSION: ` + VM_VERSION


/*
The OpenVM stack
NOTE(A-Boring-Square): this is opaque because
the Stack is technicaly an internal implmentation detail
*/
Stack :: struct {}

/*
A value stored in the VM 
To get the data stored use the API
*/
Value :: union {}

NUMBER :: f32le
STRING :: string
BOOL :: b8
HANDLE :: uintptr


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
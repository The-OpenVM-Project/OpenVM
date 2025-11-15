package OpenVMInterpreter

import "core:os/os2"
import "base:intrinsics"


import OpenVM "../"
import "../../../lib/Neutron"


EXTERNAL_FUNTION_TABLE_CAPACITY :: #config(openvm_external_function_table_capacity, 600)
PROGRAM_FUNCTION_TABLE_CAPACITY :: #config(openvm_program_function_table_capacity, 1000)

// External function type
ExternalFunction :: #type proc(stack: ^OpenVM.Stack)

ExternalFunctionTable: map[string]ExternalFunction

ProgramFunctionTable: map[string]u32

InstructionPointer: u32


@(init)
InitFunctionTables :: proc() {
    ExternalFunctionTable = make_map_cap(map[string]ExternalFunction, EXTERNAL_FUNTION_TABLE_CAPACITY)
    ProgramFunctionTable = make_map_cap(map[string]u32, PROGRAM_FUNCTION_TABLE_CAPACITY)
}


@(fini)
DestroyFunctionTables :: proc() {
    delete_map(ExternalFunctionTable)
    delete_map(ProgramFunctionTable)
}

AddExternalFunction :: proc (name: string, function: ExternalFunction) {
    value := map_insert(&ExternalFunctionTable, name, function)
    if value == nil {

    }
}


// This procedure deliberately crashes the VM immediately without cleanup
@(cold)
CRASH_AND_BURN :: proc() -> ! {
    // Log the critical failure
    OpenVM.Log(
        .CRITICAL,
        "OPENVM.BYTECODE_INTERPRETER",
        "Well shit\nSomething has gone seriously wrong and the VM has crashed and burned"
    )
    // If this is a debug build, trigger a debug trap
    when ODIN_DEBUG {
        intrinsics.debug_trap() // halt execution in debugger
    }
    os2.exit(-1)
}
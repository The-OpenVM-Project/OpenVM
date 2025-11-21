package OpenVMInterpreter

import "core:fmt"
import "core:os/os2"
import "base:intrinsics"


import OpenVM "../"
import "../../../lib/Neutron"


EXTERNAL_FUNTION_TABLE_CAPACITY :: #config(openvm_external_function_table_capacity, 600)
PROGRAM_FUNCTION_TABLE_CAPACITY :: #config(openvm_program_function_table_capacity, 1000)

// External function type
ExternalFunction :: #type proc(stack: ^OpenVM.Stack)


@(private="file")
ExternalFunctionTable: map[string]ExternalFunction

@(private="file")
ProgramFunctionTable: map[string]u32



@(private="file")
FunctionIPSave: u32 // used only to save the instruction pointer for a `CALL` operation

@(private="file")
InstructionPointer: u32 // Instruction pointer after transforms to exclude functions

@(private="file")
RawInstructionPointer: u32 // Raw instruction pointer (where the VM currently is in the bytecode stream)

@(private="file")
IsVMRunning: bool = true


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
    if len(ExternalFunctionTable) + 1 > EXTERNAL_FUNTION_TABLE_CAPACITY {
        OpenVM.Log(
            .ERROR,
            "OPENVM.BYTECODE_INTERPRETER",
            "An external function has failed to register"
        )
    }
    ExternalFunctionTable[name] = function
}

AddProgramFunction :: proc(name: string, ip: u32) {
        if len(ExternalFunctionTable) + 1 > EXTERNAL_FUNTION_TABLE_CAPACITY {
        OpenVM.Log(
            .ERROR,
            "OPENVM.BYTECODE_INTERPRETER",
            "Registering a function has failed"
        )
    }
    ProgramFunctionTable[name] = ip
}


IsFunctionExternal :: proc(name: string) {

}

CallExternalFunction :: proc(name: string, stack: ^OpenVM.Stack) {
    OpenVM.LOCAL_VAR_END_SCOPE() // Clear last scope if it exists
    OpenVM.LOCAL_VAR_INIT_SCOPE()
    extern := ExternalFunctionTable[name]
    msg := fmt.tprintf("Failed to call an external function named: %s", name)
    if extern == nil {
        OpenVM.Log(
            .CRITICAL,
            "OPENVM.BYTECODE_INTERPRETER",
            msg

        )
    }
    OpenVM.LOCAL_VAR_END_SCOPE()
    free_all(context.temp_allocator)

    extern(stack) // call the function
}



// This procedure deliberately crashes the VM immediately without cleanup
@(cold)
CRASH_AND_BURN :: proc() -> ! {
    // Log the critical failure
    OpenVM.Log(
        .CRITICAL,
        "OPENVM.BYTECODE_INTERPRETER",
        "Well shit\nSomething has gone seriously wrong and the VM has crashed"
    )
    // If this is a debug build, trigger a debug trap
    when ODIN_DEBUG {
        intrinsics.debug_trap() // halt execution in debugger
    }
    os2.exit(-1)
}
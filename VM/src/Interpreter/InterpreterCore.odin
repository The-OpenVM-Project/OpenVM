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


Function :: struct {
    name: string,
    code: []Token
}



@(private="file")
ExternalFunctionTable: map[string]ExternalFunction

@(private="file")
ProgramFunctionTable: map[string]Function




InstructionPointer: u32 // Instruction pointer

FunctionIP: u32 // Function internal instruction pointer


IsVMRunning: bool = true


@(init)
InitFunctionTables :: proc() {
    ExternalFunctionTable = make_map_cap(map[string]ExternalFunction, EXTERNAL_FUNTION_TABLE_CAPACITY)
    ProgramFunctionTable = make_map_cap(map[string]Function, PROGRAM_FUNCTION_TABLE_CAPACITY)
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



IsFunctionExternal :: #force_inline proc(name: string) -> bool {
    extern := ExternalFunctionTable[name]
    if extern == nil {
        return false
    }
    else {
        return true
    }
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
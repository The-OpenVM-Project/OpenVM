package OpenVMInterpreter

import OpenVM "../"

FunctionRange :: struct {
    start_ip: u32,
    end_ip: u32,
}

ProgramFunctionRanges: map[string]FunctionRange

@(init)
InitFunctionRangeTable :: proc() {
    ProgramFunctionRanges = make_map_cap(map[string]FunctionRange, PROGRAM_FUNCTION_TABLE_CAPACITY)
}
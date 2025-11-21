package OpenVMInterpreter

import OpenVM "../"

FunctionRange :: struct {
    start_ip: u32,
    end_ip: u32,
}

ProgramFunctionRanges: map[string]FunctionRange
package Types

import "core:sync"

// Memory Manager Types

// Queue Definition
Queue :: [dynamic]any

// Stack structure
OpenVM_Stack :: struct {
    stack: [dynamic]any,
    function_arg_stack: []any,
    stack_size: uint,
    function_arg_stack_size: uint,
    mutex: sync.Mutex
}


OpenVM_HeapObject :: struct {
    id: string,    // Unique UUID for the object
    size: uint,
    data: any,
    refcount: u128,
}

OpenVM_Heap :: struct {
    size: uint,
    heap_objects: [dynamic]^OpenVM_HeapObject,
    mutex: sync.Mutex,
}

// Exeption System Types

EXCEPTIONS :: enum {
    NONE,                 // No error
    SYNTAX_ERR,           // Invalid syntax (e.g., malformed bytecode)
    LOGIC_ERR,            // Logical error (e.g., faulty program flow)
    DIVIDE_BY_ZERO,       // Division by zero error
    OUT_OF_BOUNDS,        // Accessing memory out of bounds (e.g., array index error)
    STACK_OVERFLOW,       // Stack overflow (e.g., too many nested function calls)
    STACK_UNDERFLOW,      // Stack underflow (e.g., popping from an empty stack)
    HEAP_ALLOC_FAILED,    // Memory allocation failure
    INVALID_OPCODE,       // Unknown or invalid opcode
    SEGMENTATION_FAULT    // Invalid memory access (e.g., access violation)
}
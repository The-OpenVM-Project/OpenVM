package Types

import "core:sync"

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

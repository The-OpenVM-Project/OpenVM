package OpenVM

import "core:mem"


// Initial number of slots to preallocate in the OpenVM heap
OPEN_VM_HEAP_PREALLOC_SIZE :: #config(openvm_heap_prealloc_size, 25)

// Initial capacity of OpenVM's stack
// Set to 600 slots at default but openVM can run with as little as 3
OPEN_VM_STACK_INITIAL_CAPACITY :: #config(openvm_stack_initial_cap, 600)


// Preallocated block for fast initial allocations
PreallocHeap: []Value

// Number of slots used in the preallocated block
PreallocUsed: uint

// Initializes the OpenVM heap
@init
InitHeap :: proc() {
    PreallocHeap = make([]Value, OPEN_VM_HEAP_PREALLOC_SIZE)
    PreallocUsed = 0
}

// Allocates a Value on the OpenVM heap
AllocHeap :: proc(val: Value) -> uintptr {
    slot: ^Value

    if PreallocUsed < OPEN_VM_HEAP_PREALLOC_SIZE {
        slot = &PreallocHeap[PreallocUsed]
        PreallocUsed += 1
        slot, err := new(Value)
        if err != .None {
            panic("OPENVM.INTERNAL.MEMORY.HEAP.FAILED_ALLOCATION")
        }
    }

    slot^ = val
    return cast(uintptr)slot
}

// Frees a previously allocated Value
FreeHeap :: proc(ptr: uintptr) {
    slot := cast(^Value)ptr

    prealloc_start := &PreallocHeap[0]
    prealloc_end := &PreallocHeap[PreallocUsed-1]

    if slot < prealloc_start || slot > prealloc_end {
        val := slot^
        err := mem.free(slot)
        if err != .None {
            panic("OPENVM.INTERNAL.MEMORY.HEAP.FAILED_FREE")
        }
    }
}

// Loads a Value from a heap pointer
Load :: proc(ptr: uintptr) -> Value {
    slot := cast(^Value)ptr
    val := slot^
    return val
}

// Stores a Value to a heap pointer
Store :: proc(ptr: uintptr, val: Value) {
    slot := cast(^Value)ptr
    slot^ = val
}

// OpenVM stack type
Stack :: [dynamic]Value

// Creates a new stack
CreateStack :: proc() -> Stack {
    return make(Stack, 0, OPEN_VM_STACK_INITIAL_CAPACITY)
}

// Deletes a stack
DeleteStack :: proc(stack: ^Stack) {
    delete(stack^)
}

// Pops the top value from a stack
PopStack :: proc(stack: ^Stack) -> Value {
    return pop(stack)
}

// Peeks the top value of the stack
PeekStack :: proc(stack: ^Stack) -> Value {
    if len(stack^) == 0 {
        panic("OPENVM.MEMORY.STACK.PEEK.EMPTY")
    }
    return stack^[len(stack^)-1]
}

// Pushes a value onto the stack
PushStack :: proc(stack: ^Stack, data: Value) {
    append(stack, data)
}

// Injects a value into a specific slot of the stack
InjectStack :: proc(stack: ^Stack, slot: uint, data: Value) {
    if slot < len(stack^) {
        stack^[slot] = data
    } else {
        panic("OPENVM.MEMORY.STACK.INJECT.INVALID_SLOT")
    }
}

// Gets a value from a specific stack slot
GetValueFromSlot :: proc(stack: ^Stack, slot: uint) -> Value {
    if slot < len(stack^) {
        return stack^[slot]
    } else {
        panic("OPENVM.MEMORY.STACK.EXTERNAL.GET_VALUE.INVALID_SLOT")
    }
}

package OpenVM

import "base:runtime"
import "../../lib/Neutron"
import "core:mem"

// Memory Layout Explanation:
// ----------------------------------------------------------
// The union takes the size of its largest member and is aligned 
// according to that member’s natural alignment. Here’s the breakdown:
//
// 1. On an 8-bit CPU:
//    - f32le: 4 bytes (software-emulated floating-point)
//    - string: 2 bytes (pointer size on 16-bit addressing, may be 1 byte on small 8-bit MCUs)
//    - b8: 1 byte
//    - uintptr: 2 bytes
//    => Union size = 4 bytes (f32le is largest), alignment = 2 bytes (largest member alignment)
//
// 2. On a 16-bit CPU:
//    - f32le: 4 bytes
//    - string: 2 bytes (pointer)
//    - b8: 1 byte
//    - uintptr: 2 bytes
//    => Union size = 4 bytes, alignment = 2 bytes
//
// 3. On a 32-bit CPU:
//    - f32le: 4 bytes
//    - string: 4 bytes (pointer)
//    - b8: 1 byte
//    - uintptr: 4 bytes
//    => Union size = 4 bytes, alignment = 4 bytes
//
// 4. On a 64-bit CPU:
//    - f32le: 4 bytes
//    - string: 8 bytes (pointer)
//    - b8: 1 byte
//    - uintptr: 8 bytes
//    => Union size = 8 bytes, alignment = 8 bytes
//
// Notes:
// - Accessing smaller members like b8 may involve padding depending on CPU alignment.
// - All arithmetic or copying operations must operate on the full union size to remain safe.
// - Using b8 for booleans keeps memory usage low and avoids expensive emulation on small CPUs.
// - The union is portable across 8/16/32/64-bit CPUs as long as the backing allocator respects alignment.
//
// Overall, this layout ensures:
//   • Efficient memory usage on small CPUs
//   • Correct alignment for all members
//   • Portability across architectures
Value :: union {
    f32le,   // Numbers
    string,  // Strings
    b8,      // Bool 
             // (NOTE: We use b8 instead of b32 to avoid emulating 32-bit values on an 8-bit CPU,
             // which would be very expensive in terms of CPU cycles. On 8-bit CPUs, arithmetic
             // and comparisons on values larger than 8 bits require multiple instructions,
             // so using b8 keeps boolean operations cheap and efficient.)
    uintptr  // Heap handle
             // This is the largest member on 32-bit and 64-bit CPUs. Its size determines the 
             // alignment and overall size of the union. On 32-bit CPUs, uintptr is 4 bytes; 
             // on 64-bit CPUs, it's 8 bytes; on 16-bit, it's 2 bytes.
}

HeapAllocator: ^Neutron.Allocator

@private
InitHeap :: proc() {
    HeapAllocator = Neutron.InitAllocator(false)
}

@private
DestroyHeap :: proc() {
    Neutron.DeleteAllocator(HeapAllocator)
}

@(require_results, private)
AllocateValue :: proc(data: Value) -> uintptr {
    data := data
    dat_ptr := Neutron.Alloc(.NUMERIC, size_of(Value), HeapAllocator)
    mem.copy(dat_ptr, &data, size_of(Value))
    return cast(uintptr)dat_ptr
}

@private
FreeValue :: proc(handle: uintptr) {
    Neutron.Free(cast(rawptr)handle, HeapAllocator)
}

// OpenVM can work with as little as 4 without any external functions
// if you are realy memory constrained
STACK_CAP :: #config(openvm_stack_cap, 600)

Stack :: struct {
    data: []Value,
    cap: u32,
    ptr: u32 // points to next free slot, also indicates stack size
}

@private
InitStack :: proc(cap: u32 = STACK_CAP) -> ^Stack {
    stack := new(Stack)
    stack.data = make([]Value, cap)
    stack.ptr = 0
    stack.cap = cap
    return stack
}

@private
DestroyStack :: proc(#no_alias stack: ^Stack) {
    delete(stack.data)
    free(stack)
}

/*
NOTE(A-Boring-Square):
Vararg push for multiple values at once.
*/
StackPush :: proc(#no_alias stack: ^Stack, data: ..Value) {
    for value in data {
        if stack.ptr >= stack.cap {
            Log(.CRITICAL, "OPEN_VM.MEMORY_MANAGER.STACK", "Stack overflow")
            panic("OPEN_VM.MEMORY_MANAGER.STACK_OVERFLOW")
        }

        stack.data[stack.ptr] = value
        stack.ptr += 1
    }
}

StackPop :: proc(#no_alias stack: ^Stack) -> Value {
    if stack.ptr == 0 {
        Log(.CRITICAL, "OPEN_VM.MEMORY_MANAGER.STACK", "Stack underflow")
        panic("OPEN_VM.MEMORY_MANAGER.STACK_UNDERFLOW")
    }

    stack.ptr -= 1
    return stack.data[stack.ptr]
}

StackTop :: proc(stack: ^Stack) -> Value {
    if stack.ptr == 0 {
        Log(.CRITICAL, "OPEN_VM.MEMORY_MANAGER.STACK", "Stack is empty")
        panic("OPEN_VM.MEMORY_MANAGER.STACK_EMPTY")
    }

    return stack.data[stack.ptr - 1]
}
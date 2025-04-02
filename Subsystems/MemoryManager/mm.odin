package MemoryManager

import "core:thread"
import "core:sync"
import "core:mem"
import "core:encoding/uuid"
import "../../OpenVMLibraryLoader/Types"

// Global queue and mutex
GlobalQueue: Types.Queue
QueueMutex: sync.Mutex

// Registers
REG_A_MUTEX: sync.Mutex
REG_A: int

REG_B_MUTEX: sync.Mutex
REG_B: f64

REG_C_MUTEX: sync.Mutex
REG_C: string


ERR_REG_A_MUTEX: sync.Mutex
ERR_REG_A: i128

ERR_REG_B_MUTEX: sync.Mutex
ERR_REG_B: i32

ERR_REG_C_MUTEX: sync.Mutex
ERR_REG_C: i8

// Initialize the global queue (must be called before use)
@export
OpenVM_InitQueue :: proc() {
    sync.lock(&QueueMutex)
    defer sync.unlock(&QueueMutex)
    GlobalQueue = [dynamic]any{}
}

// Enqueue operation (thread-safe)
@export
OpenVM_Enqueue :: proc(value: any) {
    sync.lock(&QueueMutex)
    defer sync.unlock(&QueueMutex)
    append_elem(&GlobalQueue, value)
}

// Dequeue operation (thread-safe)
@export
OpenVM_Dequeue :: proc() -> any {
    sync.lock(&QueueMutex)
    defer sync.unlock(&QueueMutex)
    if len(GlobalQueue) == 0 {
        return nil
    }
    return pop(&GlobalQueue)
}

// Stack operations
@export
OpenVM_CreateStack :: proc() -> (^Types.OpenVM_Stack, mem.Allocator_Error) {
    return new(Types.OpenVM_Stack)
}

@export
OpenVM_DeleteStack :: proc(stack: ^Types.OpenVM_Stack) -> mem.Allocator_Error {
    return free(stack)
}

@export
OpenVM_PushStack :: proc(data: any, stack: ^Types.OpenVM_Stack) {
    sync.lock(&stack.mutex)
    defer sync.unlock(&stack.mutex)
    append_elem(&stack.stack, data)
    stack.stack_size = size_of(stack.stack)
}

@export
OpenVM_PopStack :: proc(stack: ^Types.OpenVM_Stack) -> any {
    sync.lock(&stack.mutex)
    defer sync.unlock(&stack.mutex)
    data := pop(&stack.stack)
    stack.stack_size = size_of(stack.stack)
    return data
}

// Heap operations
@export
OpenVM_CreateHeap :: proc() -> Types.OpenVM_Heap {
    return new(Types.OpenVM_Heap)^
}

@export
OpenVM_DeleteHeap :: proc(heap: ^Types.OpenVM_Heap) -> mem.Allocator_Error {
    sync.lock(&heap.mutex)
    defer sync.unlock(&heap.mutex)
    for heap_obj in heap.heap_objects {
        free(heap_obj)
    }
    return free(heap)
}

@export
OpenVM_HeapAllocate :: proc(heap: ^Types.OpenVM_Heap, data: any) -> (Types.OpenVM_HeapObject, string) {
    sync.lock(&heap.mutex)
    defer sync.unlock(&heap.mutex)
    heap_object: ^Types.OpenVM_HeapObject = new(Types.OpenVM_HeapObject)
    buffer := [32]byte{}
    heap_object.id = uuid.to_string_buffer(uuid.generate_v6(nil), buffer[:])
    heap_object.data = data
    heap_object.size = cast(uint)size_of(heap_object.data)
    heap_object.refcount = 1
    append_elem(&heap.heap_objects, heap_object)
    heap.size += heap_object.size
    return heap_object^, heap_object.id
}

@export
OpenVM_GC :: proc(heap: ^Types.OpenVM_Heap) {
    sync.lock(&heap.mutex)
    defer sync.unlock(&heap.mutex)
    for heap_obj in heap.heap_objects {
        if heap_obj.refcount == 0 {
            free(heap_obj)
        }
    }
}

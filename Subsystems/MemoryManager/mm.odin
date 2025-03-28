package MemoryManager

/*
MIT License

Copyright (c) 2025 The OpenVM Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import "core:thread"
import "core:sync"
import "core:mem"

QueueMutex: sync.Mutex // Mutex for queue operations
HeapMutex: sync.Mutex // Mutex for the heap

// Queue Definition
Queue :: [dynamic]any

// Creates an empty queue
@export
OpenVM_CreateQueue :: proc() -> Queue {
    return [dynamic]any{} // Initialize an empty dynamic array for the queue
}

// Enqueue operation to add a value to the queue (thread-safe)
@export
Enqueue :: proc(queue: ^Queue, value: any) {
    sync.lock(&QueueMutex)
    defer sync.unlock(&QueueMutex)
    append_elem(queue, value)
}

// Dequeue operation to remove and return the value from the queue (thread-safe)
@export
Dequeue :: proc(queue: ^Queue) -> any {
    sync.lock(&QueueMutex)
    defer sync.unlock(&QueueMutex)

    if len(queue) == 0 {
        return nil // Return nil if queue is empty
    }

    return pop(queue) // Directly pop from queue
}

// Delete the queue to free its memory (thread-safe)
@export
OpenVM_DeleteQueue :: proc(queue: ^Queue) {
    sync.lock(&QueueMutex)
    defer sync.unlock(&QueueMutex)
    delete_dynamic_array(queue^) // Properly free queue memory
}



// Stack structure
OpenVM_Stack :: struct {
    stack: [dynamic]any,
    function_arg_stack: []any,
    stack_size: uint,
    function_arg_stack_size: uint,
    mutex: sync.Mutex
}

@export
OpenVM_CreateStack :: proc() -> (^OpenVM_Stack, mem.Allocator_Error) {
    return new(OpenVM_Stack)
}

@export
OpenVM_DeleteStack :: proc(stack: ^OpenVM_Stack) -> mem.Allocator_Error {
    return free(stack)
}

@export
OpenVM_PushStack :: proc(data: any, stack: ^OpenVM_Stack) {
    stack_mutex := &stack.mutex
    sync.lock(stack_mutex)
    defer sync.unlock(stack_mutex)
    append_elem(&stack.stack, data)
    stack.stack_size = size_of(stack.stack)

}

@export
OpenVM_PopStack :: proc(stack: ^OpenVM_Stack) -> any {
    stack_mutex := &stack.mutex
    sync.lock(stack_mutex)
    defer sync.unlock(stack_mutex)
    data := pop(&stack.stack)
    stack.stack_size = size_of(stack.stack)
    return data
}

OpenVM_PushFunctionArgs :: proc(data: []any, stack: ^OpenVM_Stack) {
    stack_mutex := &stack.mutex
    sync.lock(stack_mutex)
    defer sync.unlock(stack_mutex)
    stack.function_arg_stack = data
    stack.function_arg_stack_size = size_of(stack.function_arg_stack)
}

OpenVM_ClearFunctionArgs :: proc(stack: ^OpenVM_Stack) {
    stack_mutex := &stack.mutex
    sync.lock(stack_mutex)
    defer sync.unlock(stack_mutex)
}

// heap and gc suffering


OpenVM_HeapObject :: struct {
    size: uint,
    data: any,
    refcount: u128,


}

OpenVM_Heap :: struct {
    size: uint,
    heap_objects: [dynamic]^OpenVM_HeapObject
}
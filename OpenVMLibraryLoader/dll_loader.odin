package OpenVMLbraryLoader

import "core:dynlib"
import "core:os"
import "core:mem"
import "core:fmt"
import "Types"

/*
MIT License

Copyright (c) 2025 The OpenVM Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


/*
 OpenVMLbraryLoader Module
 =========================

 This module is responsible for dynamically loading the core subsystems of OpenVM, following the modular
 structure outlined in the PROJECT_STRUCTURE.md file. OpenVM is composed of multiple dynamically linked
 libraries (DLLs), each handling a specific aspect of the virtual machine, such as memory management,
 runtime execution, and exception handling.

 How This Module Works
 ---------------------
 - It determines the appropriate file extension for dynamic libraries based on the operating system.
 - It defines constants for the main OpenVM subsystems:
     - `RUNTIME_DYNAMIC_LIB`: The core execution environment for OpenVM.
     - `MEMORY_MANAGER_DYNAMIC_LIB`: Handles memory allocation, deallocation, and garbage collection.
     - `EXEPTION_SYSTEM_DYNAMIC_LIB`: Manages error handling and stack unwinding.
 - It defines `MemoryManager` and `ExeptionSystem` structures that store function pointers to subsystem
   functions, allowing programs to interact with them in a modular way.
 - It includes `OpenVM_LoadSubsystems`, which will load these DLLs at runtime, enabling
   external programs to use OpenVM's subsystems as needed.

 Integration with OpenVM
 -----------------------
 - OpenVM itself loads these subsystems automatically when executed, but this module provides a way to
   load them separately if a program needs direct access.
 - The dynamically loaded subsystems provide the foundation for OVMB bytecode execution and can be used
   to implement custom runtime environments for OpenVM-based programs.

 For more details, refer to the OpenVM PROJECT_STRUCTURE.md file.
*/
OPENVM_VERSION :: "0.0.1"

// Whether to load the Runtime dynamic library or not (Useful if you are coding a custom runtime)
OPENVM_CUSTOM_RUNTIME :: #config(openvm_use_custom_runtime, false)
RUNTIME_DYNAMIC_LIB :: "Runtime" + dynlib.LIBRARY_FILE_EXTENSION
MEMORY_MANAGER_DYNAMIC_LIB :: "MemoryManager" + dynlib.LIBRARY_FILE_EXTENSION
EXCEPTION_SYSTEM_DYNAMIC_LIB :: "ExceptionSystem" + dynlib.LIBRARY_FILE_EXTENSION



INTERNAL_MemoryManager :: struct {
    OpenVM_CreateQueue: proc() -> Types.Queue,
    OpenVM_Enqueue:  proc(queue: ^Types.Queue, value: any),
    OpenVM_Dequeue: proc(queue: ^Types.Queue) -> any,
    OpenVM_DeleteQueue: proc(queue: ^Types.Queue),
    OpenVM_CreateStack: proc() -> (^Types.OpenVM_Stack, mem.Allocator_Error),
    OpenVM_DeleteStack: proc(stack: ^Types.OpenVM_Stack) -> mem.Allocator_Error,
    OpenVM_PushStack: proc(data: any, stack: ^Types.OpenVM_Stack),
    OpenVM_PopStack: proc(stack: ^Types.OpenVM_Stack) -> any,
    OpenVM_PushFunctionArgs: proc(data: []any, stack: ^Types.OpenVM_Stack),
    OpenVM_CreateHeap: proc() -> Types.OpenVM_Heap,
    OpenVM_DeleteHeap: proc(heap: ^Types.OpenVM_Heap) -> mem.Allocator_Error,
    OpenVM_HeapAllocate: proc(heap: ^Types.OpenVM_Heap, data: any) -> (Types.OpenVM_HeapObject, string),
    OpenVM_EditHeapObject: proc(heap: ^Types.OpenVM_Heap, id: string, new_data: any),
    OpenVM_AddRefCount: proc(heap: ^Types.OpenVM_Heap, id: string),
    OpenVM_SubRefCount: proc(heap: ^Types.OpenVM_Heap, id: string),
    OpenVM_GC: proc(heap: ^Types.OpenVM_Heap),

    __handle: dynlib.Library
}

INTERNAL_ExeptionSystem :: struct {
    MM: ^INTERNAL_MemoryManager,

    __handle: dynlib.Library
}

/*
NOTE: In exacutables using the subsystems
set this to the Path to OpenVM + the `lib` directory
*/
LIB_DIRECTORY :: ""


/*
NOTE: ONLY CALL IN AN EXACUTABLE
as the all subsystems expect to already be loaded before they initalize
*/
OpenVM_LoadSubsystems :: proc(MM_struct: ^INTERNAL_MemoryManager, ES_struct: ^INTERNAL_ExeptionSystem) {
    count, ok := dynlib.initialize_symbols(MM_struct, LIB_DIRECTORY + MEMORY_MANAGER_DYNAMIC_LIB)
    if !ok {
        fmt.panicf("[OpenVM/Subsystem Loader]: <LOAD_DYNAMIC_LIB_ERR> ~ %s", dynlib.last_error())
    }
    else {
        when ODIN_DEBUG {
            fmt.printfln("(DEBUG_MODE) [OpenVM/Subsystem Loader]: <LOADED_SYMBOLS_COUNT_MEM_MANAGER_SUBSYS>  ~ %d", count)
        }
    }
    count, ok = dynlib.initialize_symbols(ES_struct, LIB_DIRECTORY + EXCEPTION_SYSTEM_DYNAMIC_LIB)
    if !ok {
        fmt.panicf("[OpenVM/Subsystem Loader]: <LOAD_DYNAMIC_LIB_ERR> ~ %s", dynlib.last_error())
    }
    else {
        when ODIN_DEBUG {
            fmt.printfln("(DEBUG_MODE) [OpenVM/Subsystem Loader]: <LOADED_SYMBOLS_COUNT_EXEPTION_SYS_SUBSYS>  ~ %d", count)
        }
    }
}
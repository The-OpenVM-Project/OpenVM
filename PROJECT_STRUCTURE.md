OpenVM Subsystems
=================

A modular virtual machine system for your programs

What is OpenVM?
---------------

OpenVM is a virtual machine system that is composed of multiple subsystems. Each subsystem is a separate Dynamic Link Library (DLL), providing modular functionality that can be utilized by other programs. The OpenVM executable itself integrates all of these subsystems, offering a unified environment for running programs that require memory management, runtime services, I/O handling, and more.

Key Subsystems of OpenVM
------------------------

OpenVM offers a variety of subsystems, each implemented as a DLL. These subsystems can be used in your applications to perform specific tasks. The main subsystems include:

*   **Memory Management** - Handles dynamic memory allocation, garbage collection, and deallocation. It provides efficient memory usage for programs that load OpenVM.
*   **Runtime** - The core execution environment of OpenVM, responsible for program execution, threading, scheduling, and task management.
*   **IO (Input/Output)** - Manages all I/O operations, such as file handling, network communications, and interacting with user interfaces.
*   **Exception Handling** - A subsystem dedicated to managing errors, exceptions, and stack unwinding. It helps ensure that programs can gracefully handle unexpected situations.

How OpenVM Works
----------------

The OpenVM executable is designed to utilize all of the above subsystems internally. When you run OpenVM, it loads these subsystems automatically to provide the necessary functionality for executing programs. However, OpenVM is also designed to let other programs use these subsystems as well, just like how Python offers access to its core functionality through `python.dll`.

DLL Integration for Your Programs
---------------------------------

OpenVM's subsystems are packaged as DLLs, which are dynamically loaded when needed. These DLLs can be used in your own programs to take advantage of OpenVM's capabilities. You do not need to manage these subsystems manually—just link your program to OpenVM, and the subsystems will be available for use.

### Example: Using Memory Management in Your Program

To use OpenVM's memory management subsystem in your own project, you need to include the corresponding header file and link against the OpenVM DLLs. Here's an example:

    #include "openvm_memory.h"
    
    void* myData = openvm_malloc(1024); // Allocate 1KB of memory
    // Use the memory...
    openvm_free(myData); // Free the memory when done
        

Header Files and Linking
------------------------

OpenVM provides header files that define the API for interacting with its subsystems. These headers offer function declarations, constants, and data types necessary for integration. You need to include the relevant header files in your program and link against the appropriate OpenVM DLL to use the subsystems. The following steps outline how to get started:

1.  Include the necessary OpenVM header files in your program (e.g., `openvm_memory.h`, `openvm_runtime.h`).
2.  Link your project with the OpenVM DLLs. The OpenVM executable includes these DLLs, but they are also available for linking into your program independently.
3.  Call the provided functions to interact with the subsystems (e.g., allocate memory, execute code, handle I/O).

Why Use OpenVM?
---------------

OpenVM offers a convenient, modular way to add support to your programs of the OVMB bytecode spec, allowing you to extend and use the VM in your own programs. By utilizing OpenVM's subsystems, you can seamlessly integrate features like memory management, runtime execution, I/O handling, and exception management into your projects.

© 2025 The OpenVM Project
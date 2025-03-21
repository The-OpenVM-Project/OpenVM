#ifndef MEMORY_MANAGER_STACK_MANAGER
#define MEMORY_MANAGER_STACK_MANAGER

#include <common_includes.h>
#include <dll_internal_util.h>

// @STRUCT stack_list
// @PURPOSE Defines a stack that holds data in a dynamic array
// @FIELDS
//   - void** data - Dynamic array of pointers, holding the elements of the stack
//   - size_t top - The index of the top element in the stack
//   - size_t capacity - The maximum number of elements the stack can hold
typedef struct stack_list {
    void** data;     // Dynamic array of pointers
    size_t top;      // Index of the top element
    size_t capacity; // Maximum size of the stack
} stack_list;

// @STRUCT stack
// @PURPOSE Defines a stack structure that includes a global object stack and a function arguments stack
// @FIELDS
//   - stack_list global_stack - Stack used for global objects
//   - stack_list func_args - Stack used for function arguments
typedef struct stack {
    stack_list global_stack;  // Global object stack
    stack_list func_args;     // Function argument stack
} stack;


// @PURPOSE Initialize the stack with given capacities for global objects and function arguments
// @ARG stack* s - Pointer to the stack structure to initialize
// @ARG size_t global_capacity - Initial capacity for the global object stack
// @ARG size_t args_capacity - Initial capacity for the function arguments stack
// @RETURNS void
dll void init_stack(stack* s, size_t global_capacity, size_t args_capacity);

// @PURPOSE Push a value onto the stack
// @ARG stack_list* s - Pointer to the stack list where the value should be pushed
// @ARG void* value - Pointer to the value to be pushed onto the stack
// @RETURNS void
dll void stack_push(stack_list* s, void* value);

// @PURPOSE Pop a value from the stack
// @ARG stack_list* s - Pointer to the stack list from which the value should be popped
// @RETURNS void* - Pointer to the popped value, or NULL if the stack is empty
dll void* stack_pop(stack_list* s);

// @PURPOSE Free the memory allocated for both stacks in the structure
// @ARG stack* s - Pointer to the stack structure to be freed
// @RETURNS void
dll void stack_free(stack* s);

#ifdef DLL_EXPORT

// @INTERNAL
// @PURPOSE Retrieves the raw data of the global stack for use by the garbage collector and runtime
// @ARG stack* s - Pointer to the stack structure to get the raw global stack data
// @RETURNS void** - Pointer to the raw global stack data (for GC or internal use)
// @NOTE This function is for internal use only
static void** stack_raw(stack* s);

// @INTERNAL
// @PURPOSE Retrieves the raw data of the function argument stack for use by the garbage collector and runtime
// @ARG stack* s - Pointer to the stack structure to get the raw function argument stack data
// @RETURNS void** - Pointer to the raw function argument stack data (for GC or internal use)
// @NOTE This function is for internal use only
static void** stack_raw_args(stack* s);
#else

#endif

#endif // MEMORY_MANAGER_STACK_MANAGER

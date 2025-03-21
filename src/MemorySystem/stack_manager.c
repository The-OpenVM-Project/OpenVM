
#define DLL_EXPORT

#include <MemorySystem/stack_manager.h>
#include <dll_internal_util.h>



dll void init_stack(stack* s, size_t global_capacity, size_t args_capacity) {
    if (!s) return;
    
    s->global_stack.data = (void**)malloc(global_capacity * sizeof(void*));
    s->global_stack.top = 0;
    s->global_stack.capacity = global_capacity;

    s->func_args.data = (void**)malloc(args_capacity * sizeof(void*));
    s->func_args.top = 0;
    s->func_args.capacity = args_capacity;
}



dll void stack_push(stack_list* s, void* value) {
    if (!s || !value) return;
    
    if (s->top >= s->capacity) {
        size_t new_capacity = s->capacity * 2;
        s->data = (void**)realloc(s->data, new_capacity * sizeof(void*));
        s->capacity = new_capacity;
    }

    s->data[s->top++] = value;
}


dll void* stack_pop(stack_list* s) {
    if (!s || s->top == 0) return NULL;
    return s->data[--s->top];
}


dll void stack_free(stack* s) {
    if (!s) return;
    
    free(s->global_stack.data);
    free(s->func_args.data);

    s->global_stack.data = NULL;
    s->func_args.data = NULL;
    s->global_stack.top = 0;
    s->func_args.top = 0;
    s->global_stack.capacity = 0;
    s->func_args.capacity = 0;
}


void** stack_raw(stack* s) {
    return (s) ? s->global_stack.data : NULL;
}


void** stack_raw_args(stack* s) {
    return (s) ? s->func_args.data : NULL;
}

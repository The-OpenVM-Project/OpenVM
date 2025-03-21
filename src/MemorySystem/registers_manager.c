
#define DLL_EXPORT

#include <MemorySystem/registers_manager.h>
#include <dll_internal_util.h>
#include "registers_manager.h"

// General Registers
static int64_t REG_A;
static char* REG_B;
static float REG_C;

dll void clear_registers() {
    REG_A = 0;
    REG_B = NULL;
    REG_C = 0.0;
}

dll void set_register_a(int64_t data) {
    REG_A = data;
}

dll void set_register_b(char* data) {
    REG_B = data;
}

dll void set_register_c(float data) {
    REG_C = data;
}

dll int64_t get_register_a() {
    return REG_A;
}

dll char* get_register_b() {
    return REG_B;
}

dll float get_register_c() {
    return REG_C;
}


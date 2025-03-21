#ifndef MEMORY_MANAGER_REGISTERS_MANAGER
#define MEMORY_MANAGER_REGISTERS_MANAGER

#include <common_includes.h>
#include <dll_internal_util.h>

/**
 * @PURPOSE Clears or resets all registers.
 * @RETURNS void
 */
dll void clear_registers();

/**
 * @PURPOSE Sets the value of register A to the given 64-bit integer.
 * @ARG int64_t data - The 64-bit integer value to set in register A.
 * @RETURNS void
 */
dll void set_register_a(int64_t data);

/**
 * @PURPOSE Sets the value of register B to the given string (char pointer).
 * @ARG char* data - The string (char*) value to set in register B.
 * @RETURNS void
 */
dll void set_register_b(char* data);

/**
 * @PURPOSE Sets the value of register C to the given floating-point number.
 * @ARG float data - The float value to set in register C.
 * @RETURNS void
 */
dll void set_register_c(float data);

/**
 * @PURPOSE Retrieves the current value stored in register A.
 * @RETURNS int64_t - The 64-bit integer value stored in register A.
 */
dll int64_t get_register_a();

/**
 * @PURPOSE Retrieves the current value stored in register B.
 * @RETURNS char* - The string (char*) value stored in register B.
 */
dll char* get_register_b();

/**
 * @PURPOSE Retrieves the current value stored in register C.
 * @RETURNS float - The floating-point number stored in register C.
 */
dll float get_register_c();

// global error registers meant to be used by the runtime subsytem
dll int64_t ERR_REG_A;
dll int64_t ERR_REG_B;
dll int64_t ERR_REG_C;
#endif

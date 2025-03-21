#ifndef MEMORY_SYSTEM_DLL_INTERNAL_UTIL
#define MEMORY_SYSTEM_DLL_INTERNAL_UTIL

#include <common_includes.h>

#ifdef _WIN32
    #define WINDOWS_LEAN_AND_MEAN
    #include <Windows.h>
    #ifdef DLL_EXPORT
    #define dll __declspec(dllexport)
    #else
    #define dll __declspec(dllimport)
    #endif
#else
    // For Unix-like systems (Linux/macOS), we use `__attribute__((visibility("default")))` to export symbols
    #ifdef DLL_EXPORT
    #define dll __attribute__((visibility("default")))
    #else
    #define dll
    #endif
#endif

#endif // MEMORY_SYSTEM_DLL_INTERNAL_UTIL

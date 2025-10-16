/*
 * openvm_loader.h
 *
 * Header-only loader for OpenVM shared library
 * Returns a struct of function pointers (GLAD-style)
 * Cross-platform: Windows + Linux/macOS
 */

#ifndef OPENVM_LOADER_H
#define OPENVM_LOADER_H

#ifdef _WIN32
  #define WIN32_LEAN_AND_MEAN
  #include <windows.h>
  typedef HMODULE shared_obj_handle;
#else
  #include <dlfcn.h>
  typedef void* shared_obj_handle;
#endif

#ifdef __cplusplus
extern "C" {
#endif

// -------------------------
// OpenVM public API function pointer types
// -------------------------

// Add more OpenVM public API function pointers here...

// -------------------------
// struct of function pointers
// -------------------------
typedef struct OpenVM {

    // internal handle to keep library loaded
    shared_obj_handle _lib;
} OpenVM_t;

// -------------------------
// Loader function
// -------------------------
static inline OpenVM_t OpenVM_load(const char *path) {
    OpenVM_t vm = {0};
    if (!path) return vm;

    shared_obj_handle lib = NULL;

#ifdef _WIN32
    int wlen = MultiByteToWideChar(CP_UTF8, 0, path, -1, NULL, 0);
    if (wlen == 0) return vm;
    WCHAR *wpath = (WCHAR*)_alloca((size_t)wlen * sizeof(WCHAR));
    if (!wpath) return vm;
    MultiByteToWideChar(CP_UTF8, 0, path, -1, wpath, wlen);
    lib = LoadLibraryW(wpath);
#else
    lib = dlopen(path, RTLD_NOW | RTLD_LOCAL);
#endif

    if (!lib) return vm;

    // Macro to load functions
#ifdef _WIN32
#define LOAD_FN(name) (name##_t)GetProcAddress(lib, #name)
#else
#define LOAD_FN(name) (name##_t)dlsym(lib, #name)
#endif



#undef LOAD_FN

    vm._lib = lib;  // keep the handle to unload later if needed
    return vm;
}

// -------------------------
// Unload function
// -------------------------
static inline void OpenVM_unload(OpenVM_t *vm) {
    if (!vm || !vm->_lib) return;

#ifdef _WIN32
    FreeLibrary(vm->_lib);
#else
    dlclose(vm->_lib);
#endif

}

#ifdef __cplusplus
}
#endif

#endif /* OPENVM_LOADER_H */

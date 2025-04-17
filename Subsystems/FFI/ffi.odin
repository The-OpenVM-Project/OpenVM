package FFI

import "core:fmt"
import "core:dynlib"
import "core:c"
import "core:strings"
import "core:strconv"

import "../../OpenVMLibraryLoader/Types"

// Function to translate an Odin type to C type.
@export
OpenVM_FFI_TranslateOdinTypeToC :: proc($T: typeid, object: T) -> any {
    // Check the type of T and translate accordingly.
    switch T {
    case typeid(int):
        return cast(c.int)object
    case typeid(f32):
        return cast(c.float)object
    case typeid(f64):
        return cast(c.double)object
    case typeid(string):
        str := strings.clone_to_cstring(object)
        str_out: cstring = str
        delete(str)
        return str_out
    case typeid(bool):
        return cast(c.bool)object
    case typeid(uint):
        return cast(c.uint)object
    case typeid(rune):
        return cast(c.char)object

    default:
    fmt.panicf("Unsupported type translation for %W", T)
        return nil
    }
}

OpenVM_FFI_TranslateCTypeToOdin :: proc($T: typeid, object: T) -> any {
    // Check the type of T and translate accordingly.
    switch T {
    case typeid(c.int):
        return cast(int)object
    case typeid(c.float):
        return cast(f32)object
    case typeid(c.double):
        return cast(f64)object
    case typeid(cstring):
        str := strings.clone_from_cstring(object)
        str_out := str
        delete(str)
        return str_out
    case typeid(c.bool):
        return cast(bool)object
    case typeid(c.uint):
        return cast(uint)object
    case typeid(c.char):
        return cast(rune)object

    default:
        fmt.panicf("Unsupported type translation for %W ", T)
        return nil
    }
}
OpenVM_FFI_LoadLibrary :: proc(path: string) -> (dynlib.Library, bool) {
    return dynlib.load_library(path)

}

OpenVM_FFI_FetchFunction :: proc(library: dynlib.Library, name: string) -> (rawptr, bool) {
    symbol, found := dynlib.symbol_address(library, name)
    return symbol, found
}


OpenVM_FFI_UnloadLibrary :: proc(library: dynlib.Library) {
    dynlib.unload_library(library)
}


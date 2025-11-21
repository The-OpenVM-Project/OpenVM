package OpenVM

/*
NOTE:
Variables are intentionally slow and meant for limited use only.
The stack should handle most operations for performance reasons.
*/

Variable :: struct {
    name: string,
    data: Value,
}

// ==========================================================
// GLOBAL VARIABLES
// ==========================================================

GlobalVariableTable: [dynamic]Variable

InitGlobalVarTable :: proc() {
    GlobalVariableTable = make([dynamic]Variable)
}

DestroyGlobalVarTable :: proc() {
    delete(GlobalVariableTable)
}

GetGlobalVariable :: proc(name: string) -> (Value, bool) {
    for var in GlobalVariableTable {
        if var.name == name {
            return var.data, true
        }
    }
    return {}, false
}

SetGlobalVariable :: proc(name: string, data: Value) -> bool {
    for &var in GlobalVariableTable {
        if var.name == name {
            var.data = data
            return true
        }
    }
    return false
}

NewGlobal :: proc(name: string) {
    // Only create if it doesn't exist
    for var in GlobalVariableTable {
        if var.name == name {
            return
        }
    }
    append(&GlobalVariableTable, Variable{name, {}})
}

RemoveGlobal :: proc(name: string) {
    for var, i in GlobalVariableTable {
        if var.name == name {
            unordered_remove(&GlobalVariableTable, i)
            return
        }
    }
}

// ==========================================================
// LOCAL VARIABLES
// ==========================================================

LocalVariableTable: [dynamic]Variable

LOCAL_VAR_INIT_SCOPE :: proc() {
    if LocalVariableTable == nil {
    LocalVariableTable = make([dynamic]Variable, context.temp_allocator)
    }
    // Else: no-op
}

LOCAL_VAR_END_SCOPE :: proc() {
    if LocalVariableTable != nil {
        delete(LocalVariableTable)
        LocalVariableTable = nil
    }
}

GetLocalVariable :: proc(name: string) -> (Value, bool) {
    for var in LocalVariableTable {
        if var.name == name {
            return var.data, true
        }
    }
    return {}, false
}

SetLocalVariable :: proc(name: string, data: Value) -> bool {
    for &var in LocalVariableTable {
        if var.name == name {
            var.data = data
            return true
        }
    }
    return false
}

NewLocal :: proc(name: string) {
    for var in LocalVariableTable {
        if var.name == name {
            return
        }
    }
    append(&LocalVariableTable, Variable{name, {}})
}

RemoveLocal :: proc(name: string) {
    for var, i in LocalVariableTable {
        if var.name == name {
            unordered_remove(&LocalVariableTable, i)
            return
        }
    }
}

package OpenVM

import "core:c"
import "core:fmt"



Value :: union {
    c.double,
    cstring,
    bool,
}



Opcode :: enum {
    OP_PUSH,
    OP_POP,
    OP_DUP,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_CALL,
    OP_RET,
    OP_PRINT,
    OP_PRINT_ERR,
    OP_READ,
    OP_FILE_WRITE,
    OP_FILE_READ,
    OP_FILE_APPEND,
    OP_FILE_DELETE,
    OP_FILE_EXISTS,
    OP_FILE_RENAME,
    OP_EQ,
    OP_NEQ,
    OP_LT,
    OP_GT,
    OP_LTE,
    OP_GTE,
    OP_NEG,
    OP_NOT,
    OP_HALT,
    OP_JMP,
    OP_JMP_IF_ZERO,
    OP_JMP_IF_NOT_ZERO,
    OP_GVAR,
    OP_GSET,
    OP_GGET,
    OP_ALLOC,
    OP_FREE,
    OP_STORE,
    OP_LOAD,
    OP_FUNCTION,
}



Token :: struct {
    opcode:  Opcode,
    value:   []u8,
    is_op:   bool   // true if opcode, false if literal
}



OPCODE_START :: 0xFF
OPCODE_END :: 0xFE

VALUE_START :: 0xEF
VALUE_END ::  0xFE

GetOpcode :: proc(byte: u8) -> Opcode {
    switch byte {
    case 0x01: return .OP_PUSH
    case 0x02: return .OP_POP
    case 0x03: return .OP_DUP
    case 0x04: return .OP_ADD
    case 0x05: return .OP_SUB
    case 0x06: return .OP_MUL
    case 0x07: return .OP_DIV
    case 0x08: return .OP_CALL
    case 0x09: return .OP_RET
    case 0x0A: return .OP_PRINT
    case 0x0B: return .OP_PRINT_ERR
    case 0x0C: return .OP_READ
    case 0x0D: return .OP_FILE_WRITE
    case 0x0E: return .OP_FILE_READ
    case 0x0F: return .OP_FILE_APPEND
    case 0x10: return .OP_FILE_DELETE
    case 0x11: return .OP_FILE_EXISTS
    case 0x12: return .OP_FILE_RENAME
    case 0x13: return .OP_EQ
    case 0x14: return .OP_NEQ
    case 0x15: return .OP_LT
    case 0x16: return .OP_GT
    case 0x17: return .OP_LTE
    case 0x18: return .OP_GTE
    case 0x19: return .OP_NEG
    case 0x1A: return .OP_NOT
    case 0x1B: return .OP_HALT
    case 0x1C: return .OP_JMP
    case 0x1D: return .OP_JMP_IF_ZERO
    case 0x1E: return .OP_JMP_IF_NOT_ZERO
    case 0x1F: return .OP_GVAR
    case 0x20: return .OP_GSET
    case 0x21: return .OP_GGET
    case 0x22: return .OP_ALLOC
    case 0x23: return .OP_FREE
    case 0x24: return .OP_STORE
    case 0x25: return .OP_LOAD
    case 0x30: return .OP_FUNCTION
    case: panic("OPENVM.BYTECODE_INTERPRETER.TOKENIZER.GET_OPCODE.INVALID_OPCODE")
    }
}


Tokenize :: proc(byecode_stream: []u8) -> []Token {
    tokens := make([dynamic]Token)
    index: int = 0

    for index < len(byecode_stream) {
        b := byecode_stream[index]

        // OPCODE FRAME
        if b == OPCODE_START {
            if index + 2 >= len(byecode_stream) || byecode_stream[index+2] != OPCODE_END {
                panic("OPENVM.BYTECODE_INTERPRETER.TOKENIZER.TOKENIZE.MALFORMED_OPCODE")
            }
            tok := Token{
                is_op = true,
                opcode = GetOpcode(byecode_stream[index+1]),
            }
            append(&tokens, tok)
            index += 3
            continue
        }

        // LITERAL FRAME
        if b == VALUE_START {
            start := index + 1
            index = start
            for index < len(byecode_stream) && byecode_stream[index] != VALUE_END {
                index += 1
            }
            if index >= len(byecode_stream) {
                panic("OPENVM.BYTECODE_INTERPRETER.TOKENIZER.TOKENIZE.MALFORMED_LITERAL")
            }
            literal := byecode_stream[start:index]
            tok := Token{
                is_op = false,
                value = literal,
            }
            append(&tokens, tok)
            index += 1 // skip VALUE_END
            continue
        }

        // skip unknown bytes
        index += 1
    }

    return tokens[:]
}

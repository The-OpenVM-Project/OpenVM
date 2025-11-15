package OpenVMInterpreter

import "core:strings"

TokenType :: enum {
    EOF,
    Instruction,
    Number,
    String,
    Identifier,
    Meta,
    Comment,
    Unknown,
}

Token :: struct {
    kind: TokenType,
    text: string
}


Tokenize :: proc(buff: ^[dynamic]Token, src: string) {
    tokens := buff
    i: int = 0
    len_src := len(src)

    for i < len_src {
        c := src[i]

        // Skip whitespace
        if c == ' ' || c == '\t' || c == '\n' || c == '\r' {
            i += 1
            continue
        }

        // Comments
        if c == ';' {
            start := i
            for i < len_src && src[i] != '\n' {
                i += 1
            }
            append(tokens, Token{TokenType.Comment, src[start:start+i-start]})
            continue
        }

        // Strings
        if c == '"' {
            start := i + 1
            i += 1
            for i < len_src && src[i] != '"' {
                i += 1
            }
            append(tokens, Token{TokenType.String, src[start:start+i-start]})
            if i < len_src && src[i] == '"' {
                i += 1
            }
            continue
        }

        // Meta lines: %META_NAME% <- "..."
        if c == '%' {
            start := i
            for i < len_src && src[i] != '\n' {
                i += 1
            }
            append(tokens, Token{TokenType.Meta, src[start:start+i-start]})
            continue
        }

        // Numbers
        if ('0' <= c && c <= '9') || (c == '-' && i + 1 < len_src && '0' <= src[i+1] && src[i+1] <= '9') {
            start := i
            if c == '-' {
                i += 1
            }
            for i < len_src && '0' <= src[i] && src[i] <= '9' {
                i += 1
            }
            if i < len_src && src[i] == '.' {
                i += 1
                for i < len_src && '0' <= src[i] && src[i] <= '9' {
                    i += 1
                }
            }
            append(tokens, Token{TokenType.Number, src[start:start+i-start]})
            continue
        }

        // Identifiers / Instructions
        if ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == '_' {
            start := i
            for i < len_src && (('a' <= src[i] && src[i] <= 'z') || ('A' <= src[i] && src[i] <= 'Z') || ('0' <= src[i] && src[i] <= '9') || src[i] == '_') {
                i += 1
            }
            append(tokens, Token{TokenType.Identifier, src[start:start+i-start]})
            continue
        }

        // Unknown character
        append(tokens, Token{TokenType.Unknown, src[i:i+1]})
        i += 1
    }
    append(tokens, Token{TokenType.EOF, ""})
}
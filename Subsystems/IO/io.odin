package IO

import "core:fmt"
import "core:os"
import "core:os/os2"

import "../../OpenVMLibraryLoader/Types"


@export
OpenVM_Print :: proc(str: string) {
    when ODIN_DEBUG {
        fmt.printf("(DEBUG MODE) [OpenVM/IO]: <STDOUT> ~ %s", str)
    }
    else {
        fmt.print(str)
    }
}

@export
OpenVM_Input :: proc(prompt: string) -> string {
    input_buffer: [4000]u8

    when ODIN_DEBUG {
        fmt.printf("(DEBUG MODE) [OpenVM/IO]: <STDIN_PROMPT> ~ %s", prompt)
    }
    else {
        fmt.printf("%s", prompt)
    }
    total_read, err := os.read(os.stdin, input_buffer[:])
    if err != os.ERROR_NONE || total_read <= 0 {
        return ""
    }

    if total_read > 0 && input_buffer[total_read-1] == '\n' {
         total_read -= 1
    }
    input := input_buffer[:total_read]

    return cast(string)input

}



OpenVM_OpenFile :: proc(file_path: string) -> ^Types.OpenVM_FileIOObject {
    handle, err := os.open(file_path, os.O_RDWR)
    file_obj := new(Types.OpenVM_FileIOObject)
    file_obj.err = err
    file_obj.file_path = file_path
    file_obj.handle = handle

    if err == nil {
        info, stat_err := os.stat(file_path)
        if stat_err == nil {
            file_obj.file_size = cast(u64)info.size
        } else {
            file_obj.err = stat_err
        }
    }

    return file_obj
}

OpenVM_ReadFile :: proc(openvm_file_obj: ^Types.OpenVM_FileIOObject) -> (file_data: []byte, ok: bool) {
    file_buff, is_ok :=os.read_entire_file_from_handle(openvm_file_obj.handle)
    return file_buff, is_ok
}

OpenVM_WriteFile :: proc(openvm_file_obj: ^Types.OpenVM_FileIOObject, data: []byte) -> bool {
    
   _, err := os.write(openvm_file_obj.handle, data)

   ok: bool = true if err != nil else false
   return ok,
}

OpenVM_CloseFile :: proc(openvm_file_obj: ^Types.OpenVM_FileIOObject) {
    os.close(openvm_file_obj.handle)
    free(openvm_file_obj)
}

OpenVM_RunComand :: proc(command: []string, working_dir: string) -> (stdout: []byte, stderr: []byte) {
    process: os2.Process_Desc
    process.command = command
    process.working_dir = working_dir

    state, out, err, exec_err := os2.process_exec(process, context.allocator)

    if exec_err != nil {
        return nil, nil
    }

    if state.exit_code != 0 {
        return out, err
    }
    command_out := out
    command_err := err
    delete(out)
    delete(err)

    return command_out, command_err
}
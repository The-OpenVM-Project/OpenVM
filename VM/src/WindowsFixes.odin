#+build windows
package OpenVM

import "core:sys/windows"

@(export, rodata)
NvOptimusEnablement: u32 = 1
@(export, rodata)
AmdPowerXpressRequestHighPerformance: u32 = 1

@(init, private)
FixWindowsShit :: proc() {
    // --- UTF-8 console setup ---
    windows.SetConsoleOutputCP(.UTF8)
    windows.SetConsoleCP(.UTF8)

    mode: windows.DWORD
    hOut := windows.GetStdHandle(windows.STD_OUTPUT_HANDLE)
    if hOut != windows.INVALID_HANDLE_VALUE && windows.GetConsoleMode(hOut, &mode) {
        mode |= windows.ENABLE_PROCESSED_OUTPUT | windows.ENABLE_VIRTUAL_TERMINAL_PROCESSING
        windows.SetConsoleMode(hOut, mode)
    }

    // --- Thread priority ---
    windows.SetThreadPriority(windows.GetCurrentThread(), windows.THREAD_PRIORITY_ABOVE_NORMAL)

    // --- CPU affinity ---
    hProc := windows.GetCurrentProcess()
    windows.SetProcessAffinityMask(hProc, 1) // bind to core 0

    // Increase timer resolution (1 ms)
    windows.timeBeginPeriod(1)
}

@(fini, private)
StopWindowsTimer :: proc() {
    windows.timeEndPeriod(1)
}
project('OpenVM', 'c', version: '1.0', default_options: ['c_std=c99'])

# Define the memory system as a dynamic library (shared object)
memory_system = shared_library('MemorySystem',
    sources: files(
        'src/MemorySystem/garbage_collector.c',
        'src/MemorySystem/heap_manager.c',
        'src/MemorySystem/queue_manager.c',
        'src/MemorySystem/registers_manager.c',
        'src/MemorySystem/stack_manager.c'
    ),
    include_directories: include_directories('headers'),
    install: true,  # Install the shared library automatically
    install_dir: meson.current_source_dir() / 'OpenVM' / 'lib'  # Install the library in the 'OpenVM/lib' directory inside the source directory
)

# Define the main executable and link it to the memory system
executable('OpenVM',
    'main.c',
    'src/common_includes.c',
    link_with: memory_system,  # Correct way to link
    include_directories: include_directories('headers'),
    install: true,  # Install the executable
    install_dir: meson.project_source_root() / 'OpenVM' / 'bin'  # Install the executable in the 'OpenVM/bin' directory inside the source directory
)

# Install the headers inside 'OpenVM/Headers' directory in the source directory
install_subdir('headers', install_dir: meson.project_source_root() / 'OpenVM' / 'Headers', strip_directory: true)

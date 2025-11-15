package OpenVM

/*
Exports the public api for OpenVM
*/

VM_VERSION_MAJOR :: "1"
VM_VERSION_MINOR :: "0"
VM_VERSION_PATCH :: "0"

VM_VERSION :: VM_VERSION_MAJOR + "." + VM_VERSION_MINOR + "." + VM_VERSION_PATCH
VM_ODIN_COMPILER_VERSION :: ODIN_VERSION


VM_LOGO :: `
Part of the
  ____              _   ____  ___
 / __ \___  ___ ___| | /  /  |/  /
/ /_/ / _ \/ -_) _ \ |/  / /|_/ /
\____/ .__/ \__/_//_/___/_/  /_/
    /_/
Project

Text-Based Bytecode Virtual Machine
VERSION: ` + VM_VERSION

// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "VLC3__pch.h"
#include "VLC3.h"
#include "VLC3___024root.h"
#include "VLC3___024unit.h"

// FUNCTIONS
VLC3__Syms::~VLC3__Syms()
{
}

VLC3__Syms::VLC3__Syms(VerilatedContext* contextp, const char* namep, VLC3* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
}

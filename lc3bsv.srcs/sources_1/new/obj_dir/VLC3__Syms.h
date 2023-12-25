// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VLC3__SYMS_H_
#define VERILATED_VLC3__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "VLC3.h"

// INCLUDE MODULE CLASSES
#include "VLC3___024root.h"
#include "VLC3___024unit.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)VLC3__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    VLC3* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    VLC3___024root                 TOP;

    // CONSTRUCTORS
    VLC3__Syms(VerilatedContext* contextp, const char* namep, VLC3* modelp);
    ~VLC3__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard

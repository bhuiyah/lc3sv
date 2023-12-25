// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See VLC3.h for the primary calling header

#ifndef VERILATED_VLC3___024UNIT_H_
#define VERILATED_VLC3___024UNIT_H_  // guard

#include "verilated.h"


class VLC3__Syms;

class alignas(VL_CACHE_LINE_BYTES) VLC3___024unit final : public VerilatedModule {
  public:

    // INTERNAL VARIABLES
    VLC3__Syms* const vlSymsp;

    // CONSTRUCTORS
    VLC3___024unit(VLC3__Syms* symsp, const char* v__name);
    ~VLC3___024unit();
    VL_UNCOPYABLE(VLC3___024unit);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard

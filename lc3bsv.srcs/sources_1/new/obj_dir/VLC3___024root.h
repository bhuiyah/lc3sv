// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See VLC3.h for the primary calling header

#ifndef VERILATED_VLC3___024ROOT_H_
#define VERILATED_VLC3___024ROOT_H_  // guard

#include "verilated.h"


class VLC3__Syms;

class alignas(VL_CACHE_LINE_BYTES) VLC3___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    VLC3__Syms* const vlSymsp;

    // CONSTRUCTORS
    VLC3___024root(VLC3__Syms* symsp, const char* v__name);
    ~VLC3___024root();
    VL_UNCOPYABLE(VLC3___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard

// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VLC3.h for the primary calling header

#include "VLC3__pch.h"
#include "VLC3__Syms.h"
#include "VLC3___024root.h"

void VLC3___024root___ctor_var_reset(VLC3___024root* vlSelf);

VLC3___024root::VLC3___024root(VLC3__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    VLC3___024root___ctor_var_reset(this);
}

void VLC3___024root::__Vconfigure(bool first) {
    if (false && first) {}  // Prevent unused
}

VLC3___024root::~VLC3___024root() {
}

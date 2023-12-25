// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VLC3.h for the primary calling header

#include "VLC3__pch.h"
#include "VLC3__Syms.h"
#include "VLC3___024unit.h"

void VLC3___024unit___ctor_var_reset(VLC3___024unit* vlSelf);

VLC3___024unit::VLC3___024unit(VLC3__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    VLC3___024unit___ctor_var_reset(this);
}

void VLC3___024unit::__Vconfigure(bool first) {
    if (false && first) {}  // Prevent unused
}

VLC3___024unit::~VLC3___024unit() {
}

// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VLC3.h for the primary calling header

#include "VLC3__pch.h"
#include "VLC3__Syms.h"
#include "VLC3___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void VLC3___024root___dump_triggers__act(VLC3___024root* vlSelf);
#endif  // VL_DEBUG

void VLC3___024root___eval_triggers__act(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___eval_triggers__act\n"); );
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VLC3___024root___dump_triggers__act(vlSelf);
    }
#endif
}

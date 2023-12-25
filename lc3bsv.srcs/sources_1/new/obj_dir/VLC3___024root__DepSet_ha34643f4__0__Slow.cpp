// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VLC3.h for the primary calling header

#include "VLC3__pch.h"
#include "VLC3___024root.h"

VL_ATTR_COLD void VLC3___024root___eval_static(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___eval_static\n"); );
}

VL_ATTR_COLD void VLC3___024root___eval_initial__TOP(VLC3___024root* vlSelf);

VL_ATTR_COLD void VLC3___024root___eval_initial(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___eval_initial\n"); );
    // Body
    VLC3___024root___eval_initial__TOP(vlSelf);
}

VL_ATTR_COLD void VLC3___024root___eval_initial__TOP(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___eval_initial__TOP\n"); );
    // Init
    VlUnpacked<QData/*34:0*/, 64> LC3__DOT__cont__DOT__control_store;
    for (int __Vi0 = 0; __Vi0 < 64; ++__Vi0) {
        LC3__DOT__cont__DOT__control_store[__Vi0] = 0;
    }
    VlWide<3>/*95:0*/ __Vtemp_1;
    // Body
    __Vtemp_1[0U] = 0x2e6d656dU;
    __Vtemp_1[1U] = 0x6f646533U;
    __Vtemp_1[2U] = 0x7563U;
    VL_READMEM_N(true, 35, 64, 0, VL_CVT_PACK_STR_NW(3, __Vtemp_1)
                 ,  &(LC3__DOT__cont__DOT__control_store)
                 , 0, ~0ULL);
}

VL_ATTR_COLD void VLC3___024root___eval_final(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___eval_final\n"); );
}

VL_ATTR_COLD void VLC3___024root___eval_settle(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___eval_settle\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VLC3___024root___dump_triggers__act(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void VLC3___024root___dump_triggers__nba(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VLC3___024root___ctor_var_reset(VLC3___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VLC3__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VLC3___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
}

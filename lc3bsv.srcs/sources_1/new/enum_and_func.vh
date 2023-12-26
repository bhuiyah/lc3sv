`ifndef ENUM_AND_FUNC_VH
`define ENUM_AND_FUNC_VH

package enum_and_pkg;
    typedef enum bit[5:0] {
        ird_idx,
        cond1_idx, cond0_idx,
        j5_idx, j4_idx, j3_idx, j2_idx, j1_idx, j0_idx,
        ld_mar_idx,
        ld_mdr_idx,
        ld_ir_idx,
        ld_ben_idx,
        ld_reg_idx,
        ld_cc_idx,
        ld_pc_idx,
        gate_pc_idx,
        gate_mdr_idx,
        gate_alu_idx,
        gate_marmux_idx,
        gate_shf_idx,
        pcmux1_idx, pcmux0_idx,
        drmux_idx,
        sr1mux_idx,
        addr1mux_idx,
        addr2mux1_idx, addr2mux0_idx,
        marmux_idx,
        aluk1_idx, aluk0_idx,
        mio_en_idx,
        r_w_idx,
        data_size_idx,
        lshf1_idx,
        control_store_bits
    } cs_bits;

    function automatic [15:0] sext(input [15:0] A, input [4:0] num_bits); 

        reg sign_bit;
        reg [15:0] mask;

        sign_bit = A[num_bits - 1] && 1;
        if(sign_bit) begin
            mask = {16'hFFFF << num_bits};
            sext = A | mask;
        end
        else begin
            sext = A;
        end
        return sext;
    endfunction
endpackage

`endif
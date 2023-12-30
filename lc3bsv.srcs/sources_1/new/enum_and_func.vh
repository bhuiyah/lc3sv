`ifndef ENUM_AND_FUNC_VH
`define ENUM_AND_FUNC_VH

package enum_and_pkg;
    typedef enum bit[5:0] {
        lshf1_idx,
        data_size_idx,
        r_w_idx,
        mio_en_idx,
        aluk0_idx, aluk1_idx,
        marmux_idx,
        addr2mux0_idx, addr2mux1_idx,
        addr1mux_idx,
        sr1mux_idx,
        drmux_idx,
        pcmux0_idx, pcmux1_idx,
        gate_shf_idx,
        gate_marmux_idx,
        gate_alu_idx,
        gate_mdr_idx,
        gate_pc_idx,
        ld_pc_idx,
        ld_cc_idx,
        ld_reg_idx,
        ld_ben_idx,
        ld_ir_idx,
        ld_mdr_idx,
        ld_mar_idx,
        j0_idx, j1_idx, j2_idx, j3_idx, j4_idx, j5_idx,
        cond0_idx, cond1_idx,
        ird_idx,
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
`ifndef SIGN_EXTEND_VH
`define SIGN_EXTEND_VH

package sign_extend;

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
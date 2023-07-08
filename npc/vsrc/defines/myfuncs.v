`ifndef MYRUNCS
`define MYRUNCS
    function integer myclog2;
        input integer n;
    begin
        myclog2 = 0;
        for(n=n-1; n>0; n = n>>1) begin
            myclog2 = myclog2 + 1;
        end
    end
    endfunction
`endif


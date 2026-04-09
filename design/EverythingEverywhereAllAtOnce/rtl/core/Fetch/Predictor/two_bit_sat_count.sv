module two_bit_sat_count #(
)
(
    input clk,
    input rst,
    input inc,
    input dec,

    output taken
);

logic[1:0] sat_count;

wire full;
assign full = sat_count[1] & sat_count[0];

wire empty;
assign empty = ~(sat_count[1] | sat_count[0]);

always_ff@(posedge clk)begin
    if(!rst)
        sat_count <= 2'b01;
    else begin
        if(inc & ~full) sat_count <= sat_count + 2'b01;
        else if(dec & ~empty) sat_count <= sat_count - 2'b01;
    end
end

assign taken = sat_count[1];

endmodule





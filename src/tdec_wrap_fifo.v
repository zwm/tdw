//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_wrap_fifo                                    //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : Fifo of 8 bits port width                         //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170809    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
module tdec_wrap_fifo (
    clk,
    rst,
    flush,
    wr_en,
    wr_data,
    rd_en,
    rd_data,
    fifo_empty,
    fifo_almost_full
    );

// port declearation
input                       clk;
input                       rst;
input                       flush;
input                       wr_en;
input   [7:0]               wr_data;
input                       rd_en;
output  [7:0]               rd_data;
output                      fifo_empty;
output                      fifo_almost_full;
// internal wire/register
reg     [7:0]                           fifo_mem [`TDEC_WRAP_FIFO_DEPTH-1:0];
reg     [`TDEC_WRAP_FIFO_AWIDTH-1:0]    fifo_wr_addr;
reg     [`TDEC_WRAP_FIFO_AWIDTH-1:0]    fifo_rd_addr;


//---------------------------------------------------------------------------
// FIFO Write Control
//---------------------------------------------------------------------------
// fifo write address update
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fifo_wr_addr <= 0;
    end
    else begin
        if (flush) begin
            fifo_wr_addr <= 0;
        end
        else if (wr_en) begin
            if (fifo_wr_addr == `TDEC_WRAP_FIFO_DEPTH-1) begin
                fifo_wr_addr <= 0;
            end
            else begin
                fifo_wr_addr <= fifo_wr_addr + 1;
            end
        end
    end
end
// fifo write data
integer iFIFO;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (iFIFO=0; iFIFO<`TDEC_WRAP_FIFO_DEPTH; iFIFO=iFIFO+1) begin
            fifo_mem[iFIFO] <= 0;
        end
    end
    else begin
        if (wr_en) begin
            fifo_mem[fifo_wr_addr] <= wr_data;
        end
    end
end

//---------------------------------------------------------------------------
// FIFO Read Control
//---------------------------------------------------------------------------
// fifo read address update
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fifo_rd_addr <= 0;
    end
    else begin
        if (flush) begin
            fifo_rd_addr <= 0;
        end
        else if (rd_en) begin
            if (fifo_rd_addr == `TDEC_WRAP_FIFO_DEPTH-1) begin
                fifo_rd_addr <= 0;
            end
            else begin
                fifo_rd_addr <= fifo_rd_addr + 1;
            end
        end
    end
end
// fifo read data
reg     [7:0]               fifo_rd_data;
always @(*) begin
    fifo_rd_data = fifo_mem[fifo_rd_addr];
end

assign rd_data = fifo_rd_data;


//---------------------------------------------------------------------------
// FIFO Full/Empty control
//---------------------------------------------------------------------------
reg                         fifo_empty;
reg                         fifo_almost_full;
// fifo_empty
always @(*) begin
    if (fifo_rd_addr == fifo_wr_addr) begin
        fifo_empty = 1;
    end
    else begin
        fifo_empty = 0;
    end
end
// fifo_almost_full
always @(*) begin
    if (fifo_wr_addr == fifo_rd_addr) begin
        fifo_almost_full = 0;
    end
    else if (fifo_wr_addr > fifo_rd_addr) begin
        if ((fifo_wr_addr-fifo_rd_addr) > `TDEC_WRAP_FIFO_THRES) begin
            fifo_almost_full = 1;
        end
        else begin
            fifo_almost_full = 0;
        end
    end
    else begin
        if ((fifo_rd_addr-fifo_wr_addr) < (`TDEC_WRAP_FIFO_DEPTH-`TDEC_WRAP_FIFO_THRES)) begin
            fifo_almost_full = 1;
        end
        else begin
            fifo_almost_full = 0;
        end
    end
end

endmodule

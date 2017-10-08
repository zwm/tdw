//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_wrap_derm                                    //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : Deratematching of sys/p1/p2                       //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170822    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
module tdec_wrap_derm (
    clk,
    rst,
    init,
    start,
    done,
    harq_cb_comb_mode,
    codeblk_size_m1,
    base_addr,
    rm_repeat,
    rm_ei,
    rm_em,
    rm_ep,
    tail_0,
    tail_1,
    tail_2,
    tail_3,
    diram_rd_req,
    diram_rd_req_ack,   // must be non-delay ack!!
    diram_rd_addr,
    diram_rd_data,
    doram_wr_req,
    doram_wr_addr,
    doram_wr_data
    );

// port declearation
input                       clk;
input                       rst;
input                       init;
input                       start;
output                      done;
input                       harq_cb_comb_mode;
input   [12:0]              codeblk_size_m1;
input   [17:0]              base_addr;
input                       rm_repeat;
input   [16:0]              rm_ei;
input   [16:0]              rm_em;
input   [16:0]              rm_ep;
output  [4:0]               tail_0;
output  [4:0]               tail_1;
output  [4:0]               tail_2;
output  [4:0]               tail_3;
output                      diram_rd_req;
input                       diram_rd_req_ack;
output  [15:0]              diram_rd_addr;
input   [19:0]              diram_rd_data;
output                      doram_wr_req;
output  [10:0]              doram_wr_addr;
output  [19:0]              doram_wr_data;
// reg
reg     [4:0]               tail_0;
reg     [4:0]               tail_1;
reg     [4:0]               tail_2;
reg     [4:0]               tail_3;
reg                         doram_wr_req;
reg     [10:0]              doram_wr_addr;
reg     [19:0]              doram_wr_data;
reg                         diram_rd_req;
reg     [15:0]              diram_rd_addr;
reg                         done;


// internal wire/register
reg                         work_en;
reg                         diram_rd_ack;
reg     [17:0]              rm_e;
reg     [12:0]              llr_cnt;
wire                        punc;
reg     [19:0]              cache_llr;
reg                         cache_flag;
reg     [1:0]               cache_ptr;
reg     [4:0]               cache_llr_cur;
wire    [4:0]               cache_llr_rev;
wire    [4:0]               llr_cur;
reg     [4:0]               llr_rm0;
reg     [4:0]               llr_rm1;
reg     [4:0]               llr_rm2;
wire                        llr_last;
reg                         tail_flag;
reg                         llr_done;
reg                         first_word_flag;    // non-8b alianed first word
//---------------------------------------------------------------------------
// work_en
//---------------------------------------------------------------------------
always @(posedge rst or posedge clk) begin
    if (rst) begin
        work_en <= 0;
    end
    else begin
        if (start) begin
            work_en <= 1;
        end
        else if (work_en == 1 && cache_flag == 1 && llr_cnt == codeblk_size_m1 + 4) begin
            work_en <= 0;
        end
    end
end
//---------------------------------------------------------------------------
// llr read
//---------------------------------------------------------------------------
// rd_req
always @(posedge rst or posedge clk) begin
    if (rst) begin
        diram_rd_req <= 0;
    end
    else begin
        if (init) begin
            diram_rd_req <= 0;
        end
        else if (start & (~cache_flag)) begin
            diram_rd_req <= 1;
        end
        else if (work_en & cache_flag & (~punc) & cache_ptr[0] & cache_ptr[1]) begin
            diram_rd_req <= 1;
        end
        else if (diram_rd_req_ack) begin
            diram_rd_req <= 0;
        end
    end
end
// rd_addr
// harq_cb_comb_mode == 0: all code blocks are stored continuously in memory
// harq_cb_comb_mode == 1: each code block start from base_addr
always @(posedge rst or posedge clk) begin
    if (rst) begin
        diram_rd_addr <= 0;
    end
    else begin
        if (init) begin
            diram_rd_addr <= base_addr[17:2];
        end
        else if (done && harq_cb_comb_mode) begin
            diram_rd_addr <= base_addr[17:2];
        end
        else if (diram_rd_req_ack) begin
            diram_rd_addr <= diram_rd_addr + 1;
        end
    end
end
// rd_ack delay
always @(posedge rst or posedge clk) begin
    if (rst) begin
        diram_rd_ack <= 0;
    end
    else begin
        if (init) begin
            diram_rd_ack <= 0;
        end
        else begin
            diram_rd_ack <= diram_rd_req_ack;
        end
    end
end
// cache_llr
always @(posedge rst or posedge clk) begin
    if (rst) begin
        cache_llr <= 0;
    end
    else begin
        if (init) begin
            cache_llr <= 0;
        end
        else if (diram_rd_ack) begin
            cache_llr <= diram_rd_data;
        end
    end
end
// cache_ptr
always @(posedge rst or posedge clk) begin
    if (rst) begin
        cache_ptr <= 0;
    end
    else begin
        if (init) begin
            cache_ptr <= 0;
        end
        else if (work_en & first_word_flag & diram_rd_ack) begin
            cache_ptr <= base_addr[1:0];
        end
        else if (work_en & cache_flag & (~punc)) begin
            cache_ptr <= cache_ptr + 1;
        end
    end
end
// first_word_flag
always @(posedge rst or posedge clk) begin
    if (rst) begin
        first_word_flag <= 1;
    end
    else begin
        if (init) begin
            first_word_flag <= 1;
        end
        else if (diram_rd_ack) begin
            first_word_flag <= 0;
        end
    end
end
// cache_flag
always @(posedge rst or posedge clk) begin
    if (rst) begin
        cache_flag <= 0;
    end
    else begin
        if (init) begin
            cache_flag <= 0;
        end
        else if (work_en & cache_flag & (~punc) & cache_ptr[0] & cache_ptr[1]) begin
            cache_flag <= 0;
        end
        else if (diram_rd_ack) begin
            cache_flag <= 1;
        end
    end
end
// cache_llr_cur
// dint_wcdma write ttram format
//      ttram_sel == 00 : ttram_din[23:18]
//      ttram_sel == 01 : ttram_din[17:12]
//      ttram_sel == 10 : ttram_din[11: 6]
//      ttram_sel == 11 : ttram_din[ 5: 0]
always @(*) begin
    case (cache_ptr)
        2'd0    : cache_llr_cur <= cache_llr[19:15];
        2'd1    : cache_llr_cur <= cache_llr[14:10];
        2'd2    : cache_llr_cur <= cache_llr[ 9: 5];
        default : cache_llr_cur <= cache_llr[ 4: 0];
    endcase
end
// llr calc of harq and tdec different
// assign cache_llr_rev = (cache_llr_cur == 5'b10000) ? 5'b01111 : (~cache_llr_cur + 1);        // one in tdec_core ????
assign cache_llr_rev = cache_llr_cur;

//---------------------------------------------------------------------------
// ratematching
//---------------------------------------------------------------------------
// rm_e
always @(posedge rst or posedge clk) begin
    if (rst) begin
        rm_e <= 0;
    end
    else begin
        if (start) begin
            rm_e <= {1'b0, rm_ei} - {1'b0, rm_em};
        end
        else if (work_en & cache_flag & (~rm_repeat)) begin
            if (punc) begin
                rm_e <= rm_e + {1'b0, rm_ep} - {1'b0, rm_em};
            end
            else begin
                rm_e <= rm_e - {1'b0, rm_em};
            end
        end
    end
end
// punc flag
assign punc = (~rm_repeat) & rm_e[17];
//---------------------------------------------------------------------------
// llr_cnt
//---------------------------------------------------------------------------
always @(posedge rst or posedge clk) begin
    if (rst) begin
        llr_cnt <= 0;
    end
    else begin
        if (start) begin
            llr_cnt <= 0;
        end
        else if (work_en & cache_flag) begin
            llr_cnt <= llr_cnt + 1;
        end
    end
end
//---------------------------------------------------------------------------
// deratematching llr cache
//---------------------------------------------------------------------------
// current llr value & last llr flag
assign llr_cur = punc ? 5'b00000 : cache_llr_rev;
assign llr_last = (llr_cnt == codeblk_size_m1) ? 1'b1 : 1'b0;
// llr after ratematching reg
always @(posedge rst or posedge clk) begin
    if (rst) begin
        llr_rm0 <= 0;
        llr_rm1 <= 0;
        llr_rm2 <= 0;
    end
    else begin
        // llr0
        if (work_en == 1 & cache_flag == 1 && llr_cnt[1:0] == 0) begin
            llr_rm0 <= llr_cur;
        end
        // llr1
        if (work_en == 1 & cache_flag == 1 && llr_cnt[1:0] == 1) begin
            llr_rm1 <= llr_cur;
        end
        // llr2
        if (work_en == 1 & cache_flag == 1 && llr_cnt[1:0] == 2) begin
            llr_rm2 <= llr_cur;
        end
    end
end
// tail_flag
always @(posedge rst or posedge clk) begin
    if (rst) begin
        tail_flag <= 0;
    end
    else begin
        if (start) begin
            tail_flag <= 0;
        end
        else if (llr_last) begin
            tail_flag <= 1;
        end
    end
end
// llr output
// wcdma2tbd_wd format {d3, d2, d1, d0}
always @(posedge rst or posedge clk) begin
    if (rst) begin
        doram_wr_req <= 0;
        doram_wr_addr <= 0;
        doram_wr_data <= 0;
    end
    else begin
        if (start) begin
            doram_wr_req <= 0;
            doram_wr_addr <= 0;
            doram_wr_data <= 0;
        end
        else if (work_en & llr_last) begin          // bugfix, 20170930, case421, if there is no this condition, en0 last for one more cycle
            doram_wr_req <= 0;
        end
        else if (work_en & cache_flag & (~tail_flag) & llr_cnt[0] & llr_cnt[1]) begin
            doram_wr_req <= 1;
            doram_wr_addr <= llr_cnt[12:2];
            doram_wr_data <= {llr_cur, llr_rm2, llr_rm1, llr_rm0};
        end
        else if (work_en & cache_flag & (~tail_flag) & llr_last) begin
            doram_wr_req <= 1;
            doram_wr_addr <= llr_cnt[12:2];
            case (llr_cnt[1:0])
                2'd0    : doram_wr_data <= {15'd0, llr_cur};
                2'd1    : doram_wr_data <= {10'd0, llr_cur, llr_rm0};
                2'd2    : doram_wr_data <= { 5'd0, llr_cur, llr_rm1, llr_rm0};
                default : doram_wr_data <= {llr_cur, llr_rm2, llr_rm1, llr_rm0};
            endcase
        end
        else begin
            doram_wr_req <= 0;
        end
    end
end
// tail output
always @(posedge rst or posedge clk) begin
    if (rst) begin
        tail_0 <= 0;
        tail_1 <= 0;
        tail_2 <= 0;
        tail_3 <= 0;
    end
    else begin
        // tail 0
        if (work_en == 1 && cache_flag == 1 && llr_cnt == codeblk_size_m1 + 1) begin
            tail_0 <= llr_cur;
        end
        // tail 1
        if (work_en == 1 && cache_flag == 1 && llr_cnt == codeblk_size_m1 + 2) begin
            tail_1 <= llr_cur;
        end
        // tail 2
        if (work_en == 1 && cache_flag == 1 && llr_cnt == codeblk_size_m1 + 3) begin
            tail_2 <= llr_cur;
        end
        // tail 3
        if (work_en == 1 && cache_flag == 1 && llr_cnt == codeblk_size_m1 + 4) begin
            tail_3 <= llr_cur;
        end
    end
end

// llr_done flag
always @(posedge rst or posedge clk) begin
    if (rst) begin
        llr_done <= 0;
    end
    else begin
        if (start) begin
            llr_done <= 0;
        end
        else if (work_en == 1 && cache_flag == 1 && llr_cnt == codeblk_size_m1 + 4) begin
            llr_done <= 1;
        end
        else begin
            llr_done <= 0;
        end
    end
end
// done output
always @(posedge rst or posedge clk) begin
    if (rst) begin
        done <= 0;
    end
    else begin
        done <= llr_done;
    end
end

endmodule

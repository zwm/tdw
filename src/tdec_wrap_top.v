//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_wrap_top                                     //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : Wrapper of unified tdec used for WCDMA            //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170807    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
module tdec_wrap_top (
    // clock & reset
    clk,
    rst,
    // control
    start,
    trch_index,
    busy,
    done,
    // interrupt
    ca0_tdec_int,           // to ARM
    ca0_tdec_int_dpa,       // to XDSP
    ca1_tdec_int,           // to ARM
    ca1_tdec_int_dpa,       // to XDSP
    // tdec related
    tdec_et_en,
    tdec_et_thres,
    // harq related
    harq_cb_comb_mode,
    hspdsch_uemask,
    hspdsch_cb_done,
    hspdsch_dec_done,
    diram_sel,
    harq_type,
    tdec_crc_match,
    // cmdram of carrier 1
    ca1_chan_type,
    ca1_prefill_size,
    ca1_num_codeblk_m1,
    ca1_codeblk_size_m1,
    ca1_crc_att_method,
    ca1_wcrc_sel,
    ca1_num_trblk,
    ca1_trblk_size,
    ca1_src_type,
    ca1_task_tag,
    ca1_app_scale,
    ca1_max_num_iter,
    ca1_min_num_iter,
    ca1_diram_sel,
    ca1_base_sys,
    ca1_base_p1,
    ca1_base_p2,
    ca1_harq_type,
    ca1_rm_deltaN_diff,
    ca1_rm_repeat,
    ca1_rm_p2_ei,
    ca1_rm_p2_ep,
    ca1_rm_p2_em,
    // unified tdec
    wcdma2tbd_req,
    tbd2wcdma_ack,
    wcdma2tbd_we0,
    wcdma2tbd_wa0,
    wcdma2tbd_wd0,
    wcdma2tbd_we1,
    wcdma2tbd_wa1,
    wcdma2tbd_wd1,
    wcdma2tbd_we2,
    wcdma2tbd_wa2,
    wcdma2tbd_wd2,
    wcdma2tbd_cmd,
    wcdma2tbd_dtail,
    wcdma2tbd_done,
    wcdma2tbd_rdy,
    tbd2wcdma_vld,
    tbd2wcdma_dat,
    tbd2wcdma_sts,
    tbd2wcdma_fst,
    tbd2wcdma_lst,
    // dbits output
    dbits_dump_sel,
    dbits_dump_hold,
    dbits_wr,
    dbits_wr_ack,
    dbits_waddr,
    dbits_wdata,
    dbits_cb_wlast,
    dbits_wlast,
    ribram_base_req,
    ribram_base_ack,
    ribram_req_size,
    ribram_base,
    ribram_header_req,
    ribram_header_ack,
    ribram_header_ptr,
    tdec_last_ptr,
    // ram
    cmdram_rd_req,
    cmdram_rd_ack,
    cmdram_rd_addr,
    cmdram_dout,
    cbbuf_rd_req,
    cbbuf_rd_req_ack,
    cbbuf_rd_addr,
    cbbuf_dout,
    hbuf_rd_req,
    hbuf_rd_req_ack,
    hbuf_rd_addr,
    hbuf_dout
    );

//---------------------------------------------------------------------------
// Port Declearation
//---------------------------------------------------------------------------
input                       clk;
input                       rst;
input                       start;
input   [5:0]               trch_index;
output                      busy;
output                      done;
output                      ca0_tdec_int;
output                      ca0_tdec_int_dpa;
output                      ca1_tdec_int;
output                      ca1_tdec_int_dpa;
input                       tdec_et_en;
input   [3:0]               tdec_et_thres;
input                       harq_cb_comb_mode;
input   [15:0]              hspdsch_uemask;
output                      hspdsch_cb_done;
output                      hspdsch_dec_done;
output                      diram_sel;
output  [2:0]               harq_type;
output                      tdec_crc_match;
input   [3:0]               ca1_chan_type;
input   [5:0]               ca1_prefill_size;
input   [3:0]               ca1_num_codeblk_m1;
input   [12:0]              ca1_codeblk_size_m1;
input                       ca1_crc_att_method;
input   [2:0]               ca1_wcrc_sel;
input   [5:0]               ca1_num_trblk;
input   [15:0]              ca1_trblk_size;
input   [1:0]               ca1_src_type;
input   [15:0]              ca1_task_tag;
input   [5:0]               ca1_app_scale;
input   [4:0]               ca1_max_num_iter;
input   [4:0]               ca1_min_num_iter;
input                       ca1_diram_sel;
input   [17:0]              ca1_base_sys;
input   [17:0]              ca1_base_p1;
input   [17:0]              ca1_base_p2;
input   [2:0]               ca1_harq_type;
input                       ca1_rm_deltaN_diff;
input                       ca1_rm_repeat;
input   [15:0]              ca1_rm_p2_ei;
input   [15:0]              ca1_rm_p2_ep;
input   [15:0]              ca1_rm_p2_em;
output                      wcdma2tbd_req;
input                       tbd2wcdma_ack;
output                      wcdma2tbd_we0;
output  [10:0]              wcdma2tbd_wa0;
output  [19:0]              wcdma2tbd_wd0;
output                      wcdma2tbd_we1;
output  [10:0]              wcdma2tbd_wa1;
output  [19:0]              wcdma2tbd_wd1;
output                      wcdma2tbd_we2;
output  [10:0]              wcdma2tbd_wa2;
output  [19:0]              wcdma2tbd_wd2;
output  [55:0]              wcdma2tbd_cmd;
output  [59:0]              wcdma2tbd_dtail;
output                      wcdma2tbd_done;
output                      wcdma2tbd_rdy;
input                       tbd2wcdma_vld;
input   [7:0]               tbd2wcdma_dat;
input   [7:0]               tbd2wcdma_sts;
input                       tbd2wcdma_fst;
input                       tbd2wcdma_lst;
input                       dbits_dump_sel;
input                       dbits_dump_hold;
output                      dbits_wr;
input                       dbits_wr_ack;
output  [9:0]               dbits_waddr;
output  [31:0]              dbits_wdata;
output                      dbits_cb_wlast;
output                      dbits_wlast;
output                      ribram_base_req;
input                       ribram_base_ack;
output  [12:0]              ribram_req_size;
input   [9:0]               ribram_base;
output                      ribram_header_req;
input                       ribram_header_ack;
input   [9:0]               ribram_header_ptr;
output  [9:0]               tdec_last_ptr;
output                      cmdram_rd_req;
input                       cmdram_rd_ack;
output  [9:0]               cmdram_rd_addr;
input   [31:0]              cmdram_dout;
output                      cbbuf_rd_req;
input                       cbbuf_rd_req_ack;
output  [11:0]              cbbuf_rd_addr;
input   [19:0]              cbbuf_dout;
output                      hbuf_rd_req;
input                       hbuf_rd_req_ack;
output  [15:0]              hbuf_rd_addr;
input   [19:0]              hbuf_dout;
// reg
reg                         wcdma2tbd_req;
reg                         wcdma2tbd_done;
reg                         dbits_cb_wlast;
reg                         dbits_wlast;
reg                         ribram_header_req;
reg                         ribram_base_req;
reg     [9:0]               tdec_last_ptr;
reg                         cmdram_rd_req;
reg                         busy;
reg                         done;
//---------------------------------------------------------------------------
// internal wire/register
//---------------------------------------------------------------------------
// FSMs
reg     [2:0]               in_cur_state;
reg     [2:0]               in_next_state;
parameter                   TDEC_IN_IDLE    = 3'b000;
parameter                   TDEC_IN_CMDRAM  = 3'b001;
parameter                   TDEC_IN_REQ     = 3'b010;
parameter                   TDEC_IN_LLR     = 3'b011;
reg     [2:0]               out_cur_state;
reg     [2:0]               out_next_state;
parameter                   TDEC_OUT_IDLE   = 3'b000;
parameter                   TDEC_OUT_REQ    = 3'b001;
parameter                   TDEC_OUT_DATA   = 3'b010;
parameter                   TDEC_OUT_HDR    = 3'b011;   // header output
// cmdram
reg     [5:0]               trch_index_reg;
reg     [3:0]               cmdram_rd_cnt;
wire                        cmdram_rd_end;
reg     [31:0]              trch_cfg0;
reg     [31:0]              trch_cfg1;
reg     [31:0]              trch_cfg2;
reg     [31:0]              trch_cfg3;
reg     [31:0]              trch_cfg4;
reg     [31:0]              trch_cfg5;
reg     [31:0]              trch_cfg6;
reg     [31:0]              trch_cfg7;
// reg     [31:0]              trch_cfg8;
// reg     [31:0]              trch_cfg9;
// reg     [31:0]              trch_cfgA;
// reg     [31:0]              trch_cfgB;
// reg     [31:0]              trch_cfgC;
// reg     [31:0]              trch_cfgD;
// reg     [31:0]              trch_cfgE;
// reg     [31:0]              trch_cfgF;
wire    [3:0]               chan_type;
wire    [5:0]               prefill_size;
wire    [3:0]               num_codeblk_m1;
wire    [12:0]              codeblk_size_m1;
wire                        crc_att_method;
wire    [2:0]               wcrc_sel;
wire    [5:0]               num_trblk;
wire    [15:0]              trblk_size;
wire    [1:0]               src_type;
wire    [15:0]              task_tag;
wire    [5:0]               app_scale;
wire    [4:0]               max_num_iter;
wire    [4:0]               min_num_iter;
wire                        diram_sel;
wire    [17:0]              base_sys;
wire    [17:0]              base_p1;
wire    [17:0]              base_p2;
wire    [2:0]               harq_type;
wire                        rm_repeat;
wire    [16:0]              rm_p1_ei;
wire    [16:0]              rm_p1_ep;
wire    [16:0]              rm_p1_em;
wire    [16:0]              rm_p2_ei;
wire    [16:0]              rm_p2_ep;
wire    [16:0]              rm_p2_em;
// input proc
wire                        init_sys;   // sys
wire                        start_sys;
wire                        done_sys;
wire    [17:0]              base_sys_cur;
wire    [4:0]               tail_0_sys;
wire    [4:0]               tail_1_sys;
wire    [4:0]               tail_2_sys;
wire    [4:0]               tail_3_sys;
wire                        sys_rd_req;
wire                        sys_rd_req_ack;
wire    [15:0]              sys_rd_addr;
wire    [19:0]              sys_rd_data;
wire                        init_p1;    // p1
wire                        start_p1;
wire                        done_p1;
wire    [17:0]              base_p1_cur;
wire    [4:0]               tail_0_p1;
wire    [4:0]               tail_1_p1;
wire    [4:0]               tail_2_p1;
wire    [4:0]               tail_3_p1;
wire                        p1_rd_req;
wire                        p1_rd_req_ack;
wire    [15:0]              p1_rd_addr;
wire    [19:0]              p1_rd_data;
wire                        init_p2;    // p2
wire                        start_p2;
wire                        done_p2;
wire    [17:0]              base_p2_cur;
wire    [4:0]               tail_0_p2;
wire    [4:0]               tail_1_p2;
wire    [4:0]               tail_2_p2;
wire    [4:0]               tail_3_p2;
wire                        p2_rd_req;
wire                        p2_rd_req_ack;
wire    [15:0]              p2_rd_addr;
wire    [19:0]              p2_rd_data;
reg                         sys_derm_finish;
reg                         p1_derm_finish;
reg                         p2_derm_finish;
wire                        in_finish;
wire    [4:0]               cmd_max_num;
wire    [4:0]               cmd_min_num;
wire    [5:0]               cmd_ext_scal;
wire    [1:0]               cmd_crc_poly;
wire                        cmd_uemask_en;
wire                        cmd_scramble_en;
wire                        cmd_force_hard;
wire    [3:0]               cmd_crc_thres;
wire                        cmd_et_method;
wire                        cmd_crc_en;
wire                        diram_rd_req;
wire                        diram_rd_req_ack;
wire    [19:0]              diram_rd_data;
reg     [15:0]              diram_rd_addr;
// output proc
reg     [15:0]              scram_y;
wire    [7:0]               scram_next;
wire    [3:0]               num_codeblk;
wire    [12:0]              codeblk_size;
wire    [2:0]               codeblk_size_mod8;
wire                        is_hspdsch;
reg     [6:0]               prefill_cnt;
wire    [6:0]               prefill_cnt_m8;
reg     [6:0]               info_cache;
reg     [2:0]               info_cache_num;
wire                        fifo_flush;
wire                        fifo_wr_en;
wire    [7:0]               fifo_wr_data;
wire                        fifo_rd_en;
reg                         fifo_rd_en_d1;
wire    [7:0]               fifo_rd_data;
wire                        fifo_empty;
wire                        fifo_almost_full;
reg     [1:0]               word_asm_cnt;
reg     [23:0]              word_asm_reg;
wire                        word_asm_en;
wire    [31:0]              word_asm_data;
reg                         tbd2wcdma_lst_d1;
reg                         fifo_wr_finish;
wire                        crc_en;
wire                        crc_start;
wire    [1:0]               crc_sel_2b;
wire                        fifo_rd_req;
wire                        crc_match_en;
wire    [31:0]              crc_match;
wire                        word_asm_in_en;
wire    [7:0]               word_asm_in_data;
reg                         word_asm_out_en;
reg     [9:0]               word_asm_out_addr;
reg     [31:0]              word_asm_out_data;
reg                         word_asm_in_en_d1;
reg                         dbits_wait_ack;
wire                        word_pad_en;
wire    [7:0]               word_pad_data;
wire                        fifo_hold_by_dbits;
reg                         crc_finish;
wire                        dbits_finish_non_last_cb;
wire                        dbits_finish_last_cb;
wire                        dbits_finish;
reg     [9:0]               ribram_base_reg;
reg                         header0_wr_flag;
reg                         header1_wr_flag;
reg                         header_wr;
reg     [9:0]               header_waddr;
reg     [9:0]               ribram_header_reg;
reg     [31:0]              header_wdata;
wire    [31:0]              header0_data;
wire    [31:0]              header1_data;
reg     [3:0]               in_codeblk_idx;
reg     [3:0]               out_codeblk_idx;
wire                        in_first_cb;
wire                        in_last_cb;
wire                        out_first_cb;
wire                        out_last_cb;

//---------------------------------------------------------------------------
// TOP DESIGN
// A ping-pang buffer is located in unified tdec, each time the tdec core
// process llrs of one ping-pang buffer, the other one can be used by outer
// master WCDMA or LTE. 
// The req/ack signals only indicate the ping-pang buffer status. When req is
// asserted, the ack will go high when there is a free buffer. To reduce
// decode delay, tdec_wrapper will separate the ping-pang buffer fullfill
// process and decode bits output process. The in_proc will request and
// fullfill ping-pang buffer when there are more CBs to be process. The
// out_proc will process output bits of each codeblock.
//
//                .--------------------------------. 
//               |          UNIFIED TDEC            \
//               |    ------------                  |
//               |   | PING-PANG0 |                 |
//               | /  ------------ \   -----------  |
//      in_proc -->                 ->| TDEC-CORE |--> out_proc
//               | \  ------------ /   -----------  |
//               |   | PING-PANG1 |                 |
//               |    ------------                  |
//               \__________________________________/
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// cb info
//---------------------------------------------------------------------------
assign num_codeblk      = num_codeblk_m1 + 1;
assign codeblk_size     = codeblk_size_m1 + 1;
assign ribram_req_size  = num_codeblk*codeblk_size;
assign is_hspdsch       = (chan_type == 1 || chan_type == 2) ? 1'b1 : 1'b0;
assign hspdsch_dec_done = is_hspdsch & done;
assign tdec_crc_match   = hspdsch_dec_done & crc_match[0];

//---------------------------------------------------------------------------
// Input Process
//---------------------------------------------------------------------------
// syn
always @(posedge clk or posedge rst) begin
    if (rst) begin
        in_cur_state <= TDEC_IN_IDLE;
    end
    else begin
        in_cur_state <= in_next_state;
    end
end
// comb
always @(*) begin
    if (rst) begin
        in_next_state = TDEC_IN_IDLE;
    end
    else begin
        case (in_cur_state)
            // wait start
            TDEC_IN_IDLE:
                if (start) begin
                    in_next_state = TDEC_IN_CMDRAM;
                end
                else begin
                    in_next_state = TDEC_IN_IDLE;
                end
            // parse cmdram
            TDEC_IN_CMDRAM:
                if (trch_index == 6'd27) begin
                    in_next_state = TDEC_IN_REQ;
                end
                else begin
                    if (cmdram_rd_end) begin
                        in_next_state = TDEC_IN_REQ;
                    end
                    else begin
                        in_next_state = TDEC_IN_CMDRAM;
                    end
                end
            // send request of unified tdec input ping-pang buffer
            TDEC_IN_REQ:
                if (tbd2wcdma_ack) begin
                    in_next_state = TDEC_IN_LLR;
                end
                else begin
                    in_next_state = TDEC_IN_REQ;
                end
            // write llr to unified tdec input ping-pang buffer
            TDEC_IN_LLR:
                if (in_finish) begin
                    if (in_last_cb) begin
                        in_next_state = TDEC_IN_IDLE;
                    end
                    else begin
                        in_next_state = TDEC_IN_REQ;
                    end
                end
                else begin
                    in_next_state = TDEC_IN_LLR;
                end
            default:
                in_next_state = TDEC_IN_IDLE;
        endcase
    end
end
// in_codeblk_idx
always @(posedge clk or posedge rst) begin
    if (rst) begin
        in_codeblk_idx <= 0;
    end
    else begin
        if (in_cur_state == TDEC_IN_IDLE && in_next_state == TDEC_IN_CMDRAM) begin
            in_codeblk_idx <= 0;
        end
        else if (in_cur_state == TDEC_IN_LLR && in_next_state == TDEC_IN_REQ) begin
            in_codeblk_idx <= in_codeblk_idx + 1;
        end
    end
end
assign in_first_cb      = (in_codeblk_idx == 0)              ? 1'b1 : 1'b0;
assign in_last_cb       = (in_codeblk_idx == num_codeblk_m1) ? 1'b1 : 1'b0;
//---------------------------------------------------------------------------
// CMDRAM Decode
//---------------------------------------------------------------------------
// read cnt
always @(posedge clk or posedge rst) begin
    if (rst) begin
        cmdram_rd_cnt <= 0;
    end
    else begin
        if (in_cur_state == TDEC_IN_IDLE && in_next_state == TDEC_IN_CMDRAM) begin
            cmdram_rd_cnt <= 0;
        end
        else if (in_cur_state == TDEC_IN_CMDRAM && cmdram_rd_ack == 1) begin
            cmdram_rd_cnt <= cmdram_rd_cnt + 1;
        end
    end
end
// ram read port : rd_req
always @(posedge clk or posedge rst) begin
    if (rst) begin
        cmdram_rd_req <= 0;
    end
    else begin
        if (trch_index != 6'd27 && in_cur_state == TDEC_IN_IDLE && in_next_state == TDEC_IN_CMDRAM) begin
            cmdram_rd_req <= 1;
        end
        else if (trch_index != 6'd27 && in_cur_state == TDEC_IN_CMDRAM && cmdram_rd_ack == 1) begin
            cmdram_rd_req <= 1;
        end
        else begin
            cmdram_rd_req <= 0;
        end
    end
end
// trch_index reg & read port : addr
always @(posedge clk or posedge rst) begin
    if (rst) begin
        trch_index_reg <= 0;
    end
    else begin
        if (in_cur_state == TDEC_IN_IDLE && in_next_state == TDEC_IN_CMDRAM) begin
            trch_index_reg <= trch_index;
        end
    end
end
assign cmdram_rd_addr = {trch_index_reg, cmdram_rd_cnt};
// read data
always @(posedge clk or posedge rst) begin
    if (rst) begin
        trch_cfg0 <= 0;
        trch_cfg1 <= 0;
        trch_cfg2 <= 0;
        trch_cfg3 <= 0;
        trch_cfg4 <= 0;
        trch_cfg5 <= 0;
        trch_cfg6 <= 0;
        trch_cfg7 <= 0;
    end
    else begin
        if (in_cur_state == TDEC_IN_CMDRAM) begin
            if (trch_index_reg != 6'd27) begin      // carrier 0
                if (cmdram_rd_ack == 1) begin
                    case (cmdram_rd_cnt)
                        4'h0 : trch_cfg0 <= cmdram_dout;
                        4'h1 : trch_cfg1 <= cmdram_dout;
                        4'h2 : trch_cfg2 <= cmdram_dout;
                        4'h3 : trch_cfg3 <= cmdram_dout;
                        4'h4 : trch_cfg4 <= cmdram_dout;
                        4'h5 : trch_cfg5 <= cmdram_dout;
                        4'h6 : trch_cfg6 <= cmdram_dout;
                        4'h7 : trch_cfg7 <= cmdram_dout;
                        default : ;
                    endcase
                end
            end
            else begin                              // carrier 1
                trch_cfg0 <= { 1'd0                 ,   // trch_cfg0[31:31] : btfd_sel
                               2'd0                 ,   // trch_cfg0[30:29] : task_action
                               2'd0                 ,   // trch_cfg0[28:27] : chan_code
                               ca1_chan_type        ,   // trch_cfg0[26:23] : chan_type
                               ca1_prefill_size     ,   // trch_cfg0[22:17] : prefill_size
                               ca1_num_codeblk_m1   ,   // trch_cfg0[16:13] : num_codeblk_m1
                               ca1_codeblk_size_m1  };  // trch_cfg0[12: 0] : codeblk_size_m1
                trch_cfg1 <= { 6'd0                 ,   // trch_cfg1[31:26] : max_crc_try_m1
                               ca1_crc_att_method   ,   // trch_cfg1[25:25] : crc_att_method
                               ca1_wcrc_sel         ,   // trch_cfg1[24:22] : wcrc_sel
                               ca1_num_trblk        ,   // trch_cfg1[21:16] : num_trblk
                               ca1_trblk_size       };  // trch_cfg1[15: 0] : trblk_size
                trch_cfg2 <= { ca1_src_type         ,   // trch_cfg2[31:30] : src_type
                               1'd0                 ,   // trch_cfg2[29:29] : list_vdec_sel
                               1'd0                 ,   // trch_cfg2[28:28] : report_state
                               ca1_task_tag[11:0]   ,   // trch_cfg2[27:16] : task_tag_lsb
                               ca1_app_scale        ,   // trch_cfg2[15:10] : app_scale
                               ca1_max_num_iter     ,   // trch_cfg2[ 9: 5] : max_num_iter
                               ca1_min_num_iter     };  // trch_cfg2[ 4: 0] : min_num_iter
                trch_cfg3 <= { ca1_diram_sel        ,   // trch_cfg3[31:31] : diram_sel
                               5'd0                 ,   // trch_cfg3[30:26] : default
                               ca1_task_tag[15:12]  ,   // trch_cfg3[25:22] : task_tag_msb
                               ca1_base_p1[17:16]   ,   // trch_cfg3[21:20] : base_p1_msb
                               ca1_base_p2[17:16]   ,   // trch_cfg3[19:18] : base_p2_msb
                               ca1_base_sys         };  // trch_cfg3[17: 0] : base_sys
                trch_cfg4 <= { ca1_base_p1[15:0]    ,   // trch_cfg4[31:16] : base_p1_lsb
                               ca1_base_p2[15:0]    };  // trch_cfg4[15: 0] : base_p2_lsb
                trch_cfg5 <= { 1'd0                 ,   // trch_cfg5[31:31] : default
                               ca1_harq_type        ,   // trch_cfg5[30:28] : harq_type
                               11'd0                ,   // trch_cfg5[27:17] : default
                               4'd0                 ,   // trch_cfg5[16:13] : hsscch_ccs_o
                               4'd0                 ,   // trch_cfg5[12: 9] : hsscch_ccs_p
                               2'd0                 ,   // trch_cfg5[ 8: 7] : mod_type
                               3'd0                 ,   // trch_cfg5[ 6: 4] : hsscch_hap
                               3'd0                 ,   // trch_cfg5[ 3: 1] : hsscch_rv
                               1'd0                 };  // trch_cfg5[ 0: 0] : hsscch_nd
                trch_cfg6 <= { 14'd0                ,   // trch_cfg6[31:18] : default
                               ca1_rm_deltaN_diff   ,   // trch_cfg6[17:17] : rm1_deltaN_diff
                               ca1_rm_repeat        ,   // trch_cfg6[16:16] : rm1_repeat
                               ca1_rm_p2_ei[15:0]   };  // trch_cfg6[15: 0] : rm1_p2_ei
                trch_cfg7 <= { ca1_rm_p2_em[15:0]   ,   // trch_cfg7[31:16] : rm1_p2_em
                               ca1_rm_p2_ep[15:0]   };  // trch_cfg7[15: 0] : rm1_p2_ep
            end
        end
    end
end
// read finish
assign cmdram_rd_end = (trch_index_reg != 6'd27 && in_cur_state == TDEC_IN_CMDRAM && cmdram_rd_cnt == 4'hF && cmdram_rd_ack == 1) ? 1'b1 : 1'b0;
// inst
cmdram_decode ucmdram_decode (
    .trch_cfg0                  ( trch_cfg0                 ),
    .trch_cfg1                  ( trch_cfg1                 ),
    .trch_cfg2                  ( trch_cfg2                 ),
    .trch_cfg3                  ( trch_cfg3                 ),
    .trch_cfg4                  ( trch_cfg4                 ),
    .trch_cfg5                  ( trch_cfg5                 ),
    .trch_cfg6                  ( trch_cfg6                 ),
    .trch_cfg7                  ( trch_cfg7                 ),
    .trch_cfg8                  ( 32'd0                     ),
    .trch_cfg9                  ( 32'd0                     ),
    .trch_cfgA                  ( 32'd0                     ),
    .trch_cfgB                  ( 32'd0                     ),
    .trch_cfgC                  ( 32'd0                     ),
    .trch_cfgD                  ( 32'd0                     ),
    .trch_cfgE                  ( 32'd0                     ),
    .trch_cfgF                  ( 32'd0                     ),
    .chan_type                  ( chan_type                 ),
    .prefill_size               ( prefill_size              ),
    .num_codeblk_m1             ( num_codeblk_m1            ),
    .codeblk_size_m1            ( codeblk_size_m1           ),
    .crc_att_method             ( crc_att_method            ),
    .wcrc_sel                   ( wcrc_sel                  ),
    .num_trblk                  ( num_trblk                 ),
    .trblk_size                 ( trblk_size                ),
    .src_type                   ( src_type                  ),
    .task_tag                   ( task_tag                  ),
    .app_scale                  ( app_scale                 ),
    .max_num_iter               ( max_num_iter              ),
    .min_num_iter               ( min_num_iter              ),
    .diram_sel                  ( diram_sel                 ),
    .base_sys                   ( base_sys                  ),
    .base_p1                    ( base_p1                   ),
    .base_p2                    ( base_p2                   ),
    .harq_type                  ( harq_type                 ),
    .rm1_repeat                 ( rm_repeat                 ),
    .rm1_p1_ei                  ( rm_p1_ei                  ),
    .rm1_p1_ep                  ( rm_p1_ep                  ),
    .rm1_p1_em                  ( rm_p1_em                  ),
    .rm1_p2_ei                  ( rm_p2_ei                  ),
    .rm1_p2_ep                  ( rm_p2_ep                  ),
    .rm1_p2_em                  ( rm_p2_em                  ) 
);
// unified tdec req
always @(posedge clk or posedge rst) begin
    if (rst) begin
        wcdma2tbd_req <= 0;
    end
    else begin
        if (in_cur_state == TDEC_IN_REQ && tbd2wcdma_ack == 0) begin
            wcdma2tbd_req <= 1;
        end
        else begin
            wcdma2tbd_req <= 0;
        end
    end
end
// llr input control
assign init_sys     = (in_cur_state == TDEC_IN_CMDRAM && in_next_state == TDEC_IN_REQ) ? 1'b1 : 1'b0;
assign init_p1      = init_sys;
assign init_p2      = init_sys;
assign start_sys    = (in_cur_state == TDEC_IN_REQ && in_next_state == TDEC_IN_LLR) ? 1'b1 : 1'b0;
assign start_p1     = start_sys;
assign start_p2     = start_sys;
assign base_sys_cur = base_sys;
assign base_p1_cur  = base_p1;
assign base_p2_cur  = base_p2;
// cbbuf/hbuf mux
assign cbbuf_rd_req     = harq_cb_comb_mode ? diram_rd_req              : 1'd0                  ;
assign cbbuf_rd_addr    = harq_cb_comb_mode ? diram_rd_addr[11:0]       : 12'd0                 ;
assign hbuf_rd_req      = harq_cb_comb_mode ? 1'd0                      : diram_rd_req          ;
assign hbuf_rd_addr     = harq_cb_comb_mode ? 16'd0                     : diram_rd_addr[15:0]   ;
assign diram_rd_req_ack = harq_cb_comb_mode ? cbbuf_rd_req_ack          : hbuf_rd_req_ack       ;
assign diram_rd_data    = harq_cb_comb_mode ? cbbuf_dout                : hbuf_dout             ;
// diram mux
// req
assign diram_rd_req = sys_rd_req | p1_rd_req | p2_rd_req;
// addr
always @(*) begin
    if (sys_rd_req) begin
        diram_rd_addr <= sys_rd_addr;
    end
    else if (p1_rd_req) begin
        diram_rd_addr <= p1_rd_addr;
    end
    else if (p2_rd_req) begin
        diram_rd_addr <= p2_rd_addr;
    end
    else begin
        diram_rd_addr <= 0;
    end
end
// ack
assign sys_rd_req_ack   = sys_rd_req ? diram_rd_req_ack : 1'b0;
assign p1_rd_req_ack    = ((~sys_rd_req) & p1_rd_req)  ? diram_rd_req_ack : 1'b0;
assign p2_rd_req_ack    = ((~sys_rd_req) & (~p1_rd_req) & p2_rd_req)  ? diram_rd_req_ack : 1'b0;
// dout
assign sys_rd_data      = diram_rd_data;
assign p1_rd_data       = diram_rd_data;
assign p2_rd_data       = diram_rd_data;
// sys
tdec_wrap_derm usys_derm (
    .clk                        ( clk                       ),
    .rst                        ( rst                       ),
    .init                       ( init_sys                  ),
    .start                      ( start_sys                 ),
    .done                       ( done_sys                  ),
    .harq_cb_comb_mode          ( harq_cb_comb_mode         ),
    .codeblk_size_m1            ( codeblk_size_m1           ),
    .base_addr                  ( base_sys_cur              ),
    .rm_repeat                  ( 1'b1                      ),
    .rm_ei                      ( 17'd0                     ),
    .rm_em                      ( 17'd0                     ),
    .rm_ep                      ( 17'd0                     ),
    .tail_0                     ( tail_0_sys                ),
    .tail_1                     ( tail_1_sys                ),
    .tail_2                     ( tail_2_sys                ),
    .tail_3                     ( tail_3_sys                ),
    .diram_rd_req               ( sys_rd_req                ),
    .diram_rd_req_ack           ( sys_rd_req_ack            ),
    .diram_rd_addr              ( sys_rd_addr               ),
    .diram_rd_data              ( sys_rd_data               ),
    .doram_wr_req               ( wcdma2tbd_we0             ),
    .doram_wr_addr              ( wcdma2tbd_wa0             ),
    .doram_wr_data              ( wcdma2tbd_wd0             )
);
// p1
tdec_wrap_derm up1_derm (
    .clk                        ( clk                       ),
    .rst                        ( rst                       ),
    .init                       ( init_p1                   ),
    .start                      ( start_p1                  ),
    .done                       ( done_p1                   ),
    .harq_cb_comb_mode          ( harq_cb_comb_mode         ),
    .codeblk_size_m1            ( codeblk_size_m1           ),
    .base_addr                  ( base_p1_cur               ),
    .rm_repeat                  ( rm_repeat                 ),
    .rm_ei                      ( rm_p1_ei                  ),
    .rm_em                      ( rm_p1_em                  ),
    .rm_ep                      ( rm_p1_ep                  ),
    .tail_0                     ( tail_0_p1                 ),
    .tail_1                     ( tail_1_p1                 ),
    .tail_2                     ( tail_2_p1                 ),
    .tail_3                     ( tail_3_p1                 ),
    .diram_rd_req               ( p1_rd_req                 ),
    .diram_rd_req_ack           ( p1_rd_req_ack             ),
    .diram_rd_addr              ( p1_rd_addr                ),
    .diram_rd_data              ( p1_rd_data                ),
    .doram_wr_req               ( wcdma2tbd_we1             ),
    .doram_wr_addr              ( wcdma2tbd_wa1             ),
    .doram_wr_data              ( wcdma2tbd_wd1             )
);
// p2
tdec_wrap_derm up2_derm (
    .clk                        ( clk                       ),
    .rst                        ( rst                       ),
    .init                       ( init_p2                   ),
    .start                      ( start_p2                  ),
    .done                       ( done_p2                   ),
    .harq_cb_comb_mode          ( harq_cb_comb_mode         ),
    .codeblk_size_m1            ( codeblk_size_m1           ),
    .base_addr                  ( base_p2_cur               ),
    .rm_repeat                  ( rm_repeat                 ),
    .rm_ei                      ( rm_p2_ei                  ),
    .rm_em                      ( rm_p2_em                  ),
    .rm_ep                      ( rm_p2_ep                  ),
    .tail_0                     ( tail_0_p2                 ),
    .tail_1                     ( tail_1_p2                 ),
    .tail_2                     ( tail_2_p2                 ),
    .tail_3                     ( tail_3_p2                 ),
    .diram_rd_req               ( p2_rd_req                 ),
    .diram_rd_req_ack           ( p2_rd_req_ack             ),
    .diram_rd_addr              ( p2_rd_addr                ),
    .diram_rd_data              ( p2_rd_data                ),
    .doram_wr_req               ( wcdma2tbd_we2             ),
    .doram_wr_addr              ( wcdma2tbd_wa2             ),
    .doram_wr_data              ( wcdma2tbd_wd2             )
);
// Cmd connection
assign cmd_crc_en       = tdec_et_en;
assign cmd_et_method    = (tdec_et_en == 1 && num_codeblk_m1 == 0 && num_trblk == 1 && wcrc_sel != 0) ? 1'b1 : 1'b0;
assign cmd_crc_thres    = tdec_et_thres;
assign cmd_force_hard   = 1'b1;
assign cmd_scramble_en  = cmd_et_method & is_hspdsch;
assign cmd_uemask_en    = cmd_et_method & is_hspdsch & crc_att_method;
assign cmd_crc_poly     = ~wcrc_sel[1:0];
assign cmd_ext_scal     = app_scale;
assign cmd_max_num      = max_num_iter;
assign cmd_min_num      = min_num_iter;
// CMD
assign wcdma2tbd_cmd = {codeblk_size,       // bit[55:43]: Block size in bits
                        cmd_max_num,        // bit[42:38]: maximum num of odd half iteration, 0~31
                        cmd_min_num,        // bit[37:33]: minimum num of odd half iteration, 0~31
                        cmd_ext_scal,       // bit[32:27]: scaling factor of extrinsic information, U(6,6)
                        cmd_crc_poly,       // bit[26:25]: CRC polynominal select
                                            //             2'b00-CRC24, 2'b01-CRC16
                                            //             2'b10-CRC12, 2'b11-CRC8
                        hspdsch_uemask,     // bit[24:9]: UE Identity
                        cmd_uemask_en,      // bit[8]: UE ID mask flag, 0-disable, 1-enable
                        cmd_scramble_en,    // bit[7]: bit scrambling flag, 0-disable, 1-enable
                        cmd_force_hard,     // bit[6]: 0-drop hard bits when TB CRC check failed
                                            //         1-still output hard bits when TB CRC check failed
                        cmd_crc_thres,      // bit[5:2]: crc_cnt threshold for two ET methods, value: 0~15
                        cmd_et_method,      // bit[1]: 0-CRC compare based ET
                                            //         1-TB CRC ET
                        cmd_crc_en};        // bit[0]: 0-disable CRC check
                                            //         1-enable CRC check
// TAIL
assign wcdma2tbd_dtail = {tail_0_sys, tail_1_sys, tail_2_sys, tail_3_sys,
                          tail_0_p1,  tail_1_p1,  tail_2_p1,  tail_3_p1,
                          tail_0_p2,  tail_1_p2,  tail_2_p2,  tail_3_p2};
// finish
always @(posedge clk or posedge rst) begin
    if (rst) begin
        sys_derm_finish <= 0;
        p1_derm_finish <= 0;
        p2_derm_finish <= 0;
    end
    else begin
        // sys
        if (in_cur_state == TDEC_IN_LLR) begin
            if (done_sys) begin
                sys_derm_finish <= 1;
            end
        end
        else begin
            sys_derm_finish <= 0;
        end
        // p1
        if (in_cur_state == TDEC_IN_LLR) begin
            if (done_p1) begin
                p1_derm_finish <= 1;
            end
        end
        else begin
            p1_derm_finish <= 0;
        end
        // p2
        if (in_cur_state == TDEC_IN_LLR) begin
            if (done_p2) begin
                p2_derm_finish <= 1;
            end
        end
        else begin
            p2_derm_finish <= 0;
        end
    end
end
// in_finish
assign in_finish = sys_derm_finish & p1_derm_finish & p2_derm_finish;
// wcdma2tbd_done
always @(posedge clk or posedge rst) begin
    if (rst) begin
        wcdma2tbd_done <= 0;
    end
    else begin
        if (in_cur_state == TDEC_IN_LLR && in_next_state != TDEC_IN_LLR) begin
            wcdma2tbd_done <= 1;
        end
        else begin
            wcdma2tbd_done <= 0;
        end
    end
end
// hspdsch_cb_done
assign hspdsch_cb_done = wcdma2tbd_done;

//---------------------------------------------------------------------------
// Output Process
//---------------------------------------------------------------------------
// syn
always @(posedge clk or posedge rst) begin
    if (rst) begin
        out_cur_state <= TDEC_OUT_IDLE;
    end
    else begin
        out_cur_state <= out_next_state;
    end
end
// comb
always @(*) begin
    if (rst) begin
        out_next_state = TDEC_OUT_IDLE;
    end
    else begin
        case (out_cur_state)
            // wait start
            TDEC_OUT_IDLE:
                if (start) begin
                    out_next_state = TDEC_OUT_REQ;
                end
                else begin
                    out_next_state = TDEC_OUT_IDLE;
                end
            // 1. if ribram, request base address of first cb
            // 2. if dibts_dump, check hold signal of each cb
            TDEC_OUT_REQ:
                if (dbits_dump_sel) begin
                    if (dbits_dump_hold) begin
                        out_next_state = TDEC_OUT_REQ;
                    end
                    else begin
                        out_next_state = TDEC_OUT_DATA;
                    end
                end
                else begin
                    if (out_first_cb) begin
                        if (ribram_base_ack) begin
                            out_next_state = TDEC_OUT_DATA;
                        end
                        else begin
                            out_next_state = TDEC_OUT_REQ;
                        end
                    end
                    else begin
                        out_next_state = TDEC_OUT_DATA;
                    end
                end
            // output all decode bits
            TDEC_OUT_DATA:
                if (dbits_finish) begin
                    if (out_last_cb) begin
                        out_next_state = TDEC_OUT_HDR;
                    end
                    else begin
                        out_next_state = TDEC_OUT_REQ;
                    end
                end
                else begin
                    out_next_state = TDEC_OUT_DATA;
                end
            // output header
            TDEC_OUT_HDR:
                if (header1_wr_flag && dbits_wr_ack) begin
                    out_next_state = TDEC_OUT_IDLE;
                end
                else begin
                    out_next_state = TDEC_OUT_HDR;
                end
            default:
                out_next_state = TDEC_OUT_IDLE;
        endcase
    end
end
// out_codeblk_idx
always @(posedge clk or posedge rst) begin
    if (rst) begin
        out_codeblk_idx <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_IDLE && out_next_state == TDEC_OUT_REQ) begin
            out_codeblk_idx <= 0;
        end
        else if (out_cur_state == TDEC_OUT_DATA && out_next_state == TDEC_OUT_REQ) begin
            out_codeblk_idx <= out_codeblk_idx + 1;
        end
    end
end
assign out_first_cb     = (out_codeblk_idx == 0)              ? 1'b1 : 1'b0;
assign out_last_cb      = (out_codeblk_idx == num_codeblk_m1) ? 1'b1 : 1'b0;

//---------------------------------------------------------------------------
// Prefill Remove
//---------------------------------------------------------------------------
// prefill_cnt
assign prefill_cnt_m8 = prefill_cnt - 8;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        prefill_cnt <= 0;
    end
    else begin
        if (in_cur_state == TDEC_IN_CMDRAM && in_next_state == TDEC_IN_REQ) begin
            prefill_cnt <= {1'b0, prefill_size};
        end
        else if (out_cur_state == TDEC_OUT_DATA && tbd2wcdma_vld) begin
            if (~prefill_cnt[6] && (|prefill_cnt[5:0])) begin // $signed(prefill_cnt)>0
                prefill_cnt <= prefill_cnt_m8;
            end
        end
    end
end
// info bits cache proc
// In the following cases, info_cache should be updated!
// 1. When the last prefilling bit removed, there may at most 7 bits remain
// 2. When the last word of CB is not 8 bits divisible, cache should be update
wire        [3:0]       last_word_plus_cache;       // codeblk_size_mod8 + info_cache_num
assign codeblk_size_mod8 = codeblk_size[2:0];       // valid bits num of last word!!
assign last_word_plus_cache = (codeblk_size_mod8 == 3'b000) ? {1'b1, info_cache_num} : ({1'b0, codeblk_size_mod8} + {1'b0, info_cache_num});
always @(posedge clk or posedge rst) begin
    if (rst) begin
        info_cache <= 0;
        info_cache_num <= 0;
    end
    else begin
        if (in_cur_state == TDEC_IN_CMDRAM && in_next_state == TDEC_IN_REQ) begin
            info_cache <= 0;
            info_cache_num <= 0;
        end
        else if (out_cur_state == TDEC_OUT_DATA && tbd2wcdma_vld) begin
            if ($signed(prefill_cnt) > 0 && $signed(prefill_cnt) < 8) begin
                case (prefill_cnt[2:0])
                    3'd1 : begin
                        info_cache <= {tbd2wcdma_dat[7:1]};
                        info_cache_num <= 3'd7;
                    end
                    3'd2 : begin
                        info_cache <= {1'd0, tbd2wcdma_dat[7:2]};
                        info_cache_num <= 3'd6;
                    end
                    3'd3 : begin
                        info_cache <= {2'd0, tbd2wcdma_dat[7:3]};
                        info_cache_num <= 3'd5;
                    end
                    3'd4 : begin
                        info_cache <= {3'd0, tbd2wcdma_dat[7:4]};
                        info_cache_num <= 3'd4;
                    end
                    3'd5 : begin
                        info_cache <= {4'd0, tbd2wcdma_dat[7:5]};
                        info_cache_num <= 3'd3;
                    end
                    3'd6 : begin
                        info_cache <= {5'd0, tbd2wcdma_dat[7:6]};
                        info_cache_num <= 3'd2;
                    end
                    3'd7 : begin
                        info_cache <= {6'd0, tbd2wcdma_dat[7:7]};
                        info_cache_num <= 3'd1;
                    end
                    default : begin
                        info_cache <= info_cache;
                        info_cache_num <= 3'd0;
                    end
                endcase
            end
            else if ($signed(prefill_cnt) <= 0) begin       // prefill end
                if (tbd2wcdma_lst) begin        // last word, process non-8b-alian case!!!
                    if (last_word_plus_cache[3]) begin      // >=8, overide old cache
                        info_cache_num <= last_word_plus_cache[2:0];
//                        case (last_word_plus_cache[2:0])  // error logic!!!!, 20170930!!
                        case (info_cache_num[2:0])
                            3'd1 : info_cache <= {6'd0, tbd2wcdma_dat[7:7]};
                            3'd2 : info_cache <= {5'd0, tbd2wcdma_dat[7:6]};
                            3'd3 : info_cache <= {4'd0, tbd2wcdma_dat[7:5]};
                            3'd4 : info_cache <= {3'd0, tbd2wcdma_dat[7:4]};
                            3'd5 : info_cache <= {2'd0, tbd2wcdma_dat[7:3]};
                            3'd6 : info_cache <= {1'd0, tbd2wcdma_dat[7:2]};
                            3'd7 : info_cache <= {      tbd2wcdma_dat[7:1]};
                            default : info_cache <= info_cache;
                        endcase
                    end
                    else begin      // <8, keep old cache
                        if (out_last_cb) begin
                            info_cache <= 7'd0;
                            info_cache_num <= 3'd0;
                        end
                        else begin
                            info_cache_num <= last_word_plus_cache[2:0];
                            case (info_cache_num[2:0])
                                3'd0 : info_cache <= {tbd2wcdma_dat[6:0]};
                                3'd1 : info_cache <= {tbd2wcdma_dat[5:0], info_cache[0:0]};
                                3'd2 : info_cache <= {tbd2wcdma_dat[4:0], info_cache[1:0]};
                                3'd3 : info_cache <= {tbd2wcdma_dat[3:0], info_cache[2:0]};
                                3'd4 : info_cache <= {tbd2wcdma_dat[2:0], info_cache[3:0]};
                                3'd5 : info_cache <= {tbd2wcdma_dat[1:0], info_cache[4:0]};
                                3'd6 : info_cache <= {tbd2wcdma_dat[0:0], info_cache[5:0]};
                                default : info_cache <= info_cache;
                            endcase
                        end
                    end
                end
                else begin
                    case (info_cache_num[2:0])
                        3'd1 : info_cache <= {6'd0, tbd2wcdma_dat[7:7]};
                        3'd2 : info_cache <= {5'd0, tbd2wcdma_dat[7:6]};
                        3'd3 : info_cache <= {4'd0, tbd2wcdma_dat[7:5]};
                        3'd4 : info_cache <= {3'd0, tbd2wcdma_dat[7:4]};
                        3'd5 : info_cache <= {2'd0, tbd2wcdma_dat[7:3]};
                        3'd6 : info_cache <= {1'd0, tbd2wcdma_dat[7:2]};
                        3'd7 : info_cache <= {      tbd2wcdma_dat[7:1]};
                        default : info_cache <= info_cache;
                    endcase
                end
            end
        end
        else if (out_last_cb == 1 && out_cur_state == TDEC_OUT_DATA && tbd2wcdma_lst_d1) begin
            info_cache <= 7'd0;
            info_cache_num <= 3'd0;
        end
    end
end
// tbd2wcdma last flag delay
always @(posedge clk or posedge rst) begin
    if (rst) begin
        tbd2wcdma_lst_d1 <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_DATA && tbd2wcdma_vld) begin       // remove tbd2wcdma_vld???
            tbd2wcdma_lst_d1 <= tbd2wcdma_lst;
        end
        else begin
            tbd2wcdma_lst_d1 <= 1'b0;
        end
    end
end

reg                 prefill_en;
reg     [7:0]       prefill_data;
reg     [7:0]       prefill_mask;
// prefill output
always @(posedge clk or posedge rst) begin
    if (rst) begin
        prefill_en <= 0;
        prefill_data <= 0;
        prefill_mask <= 8'hff;
    end
    else begin
        if (out_cur_state == TDEC_OUT_DATA && tbd2wcdma_vld) begin
            if ($signed(prefill_cnt) <= 0) begin    // prefill end
                if (tbd2wcdma_lst) begin
                    if (last_word_plus_cache[3]) begin      // >=8
                        prefill_en <= 1;
                        prefill_mask <= 8'hff;
                        case (info_cache_num[2:0])
                            3'd1 : prefill_data <= {tbd2wcdma_dat[6:0], info_cache[0:0]};
                            3'd2 : prefill_data <= {tbd2wcdma_dat[5:0], info_cache[1:0]};
                            3'd3 : prefill_data <= {tbd2wcdma_dat[4:0], info_cache[2:0]};
                            3'd4 : prefill_data <= {tbd2wcdma_dat[3:0], info_cache[3:0]};
                            3'd5 : prefill_data <= {tbd2wcdma_dat[2:0], info_cache[4:0]};
                            3'd6 : prefill_data <= {tbd2wcdma_dat[1:0], info_cache[5:0]};
                            3'd7 : prefill_data <= {tbd2wcdma_dat[0:0], info_cache[6:0]};
                            default : prefill_data <= tbd2wcdma_dat;
                        endcase
                    end
                    else begin      // <8
                        if (out_last_cb) begin  // output non-8b word
                            prefill_en <= 1;
                            case (info_cache_num[2:0])
                                3'd1 : prefill_data <= {tbd2wcdma_dat[6:0], info_cache[0:0]};
                                3'd2 : prefill_data <= {tbd2wcdma_dat[5:0], info_cache[1:0]};
                                3'd3 : prefill_data <= {tbd2wcdma_dat[4:0], info_cache[2:0]};
                                3'd4 : prefill_data <= {tbd2wcdma_dat[3:0], info_cache[3:0]};
                                3'd5 : prefill_data <= {tbd2wcdma_dat[2:0], info_cache[4:0]};
                                3'd6 : prefill_data <= {tbd2wcdma_dat[1:0], info_cache[5:0]};
                                3'd7 : prefill_data <= {tbd2wcdma_dat[0:0], info_cache[6:0]};
                                default : prefill_data <= tbd2wcdma_dat;
                            endcase
                            case (last_word_plus_cache[2:0])
                                3'd1 : prefill_mask <= 8'b00000001;
                                3'd2 : prefill_mask <= 8'b00000011;
                                3'd3 : prefill_mask <= 8'b00000111;
                                3'd4 : prefill_mask <= 8'b00001111;
                                3'd5 : prefill_mask <= 8'b00011111;
                                3'd6 : prefill_mask <= 8'b00111111;
                                3'd7 : prefill_mask <= 8'b01111111;
                                default : prefill_mask <= prefill_mask;
                            endcase
                        end
                        else begin  // cache non-8b word
                            prefill_en <= 0;
                            prefill_mask <= 8'hff;
                        end
                    end
                end
                else begin
                    prefill_en <= 1;
                    prefill_mask <= 8'hff;
                    case (info_cache_num[2:0])
                        3'd1 : prefill_data <= {tbd2wcdma_dat[6:0], info_cache[0:0]};
                        3'd2 : prefill_data <= {tbd2wcdma_dat[5:0], info_cache[1:0]};
                        3'd3 : prefill_data <= {tbd2wcdma_dat[4:0], info_cache[2:0]};
                        3'd4 : prefill_data <= {tbd2wcdma_dat[3:0], info_cache[3:0]};
                        3'd5 : prefill_data <= {tbd2wcdma_dat[2:0], info_cache[4:0]};
                        3'd6 : prefill_data <= {tbd2wcdma_dat[1:0], info_cache[5:0]};
                        3'd7 : prefill_data <= {tbd2wcdma_dat[0:0], info_cache[6:0]};
                        default : prefill_data <= tbd2wcdma_dat;
                    endcase
                end
            end
            else begin
                prefill_en <= 0;
                prefill_mask <= 8'hff;
            end
        end
        else if (out_last_cb == 1 && out_cur_state == TDEC_OUT_DATA && tbd2wcdma_lst_d1) begin
            if (|info_cache_num) begin      // last
                prefill_en <= 1;
                prefill_data <= {1'd0, info_cache[6:0]};
                case (info_cache_num)
                    3'd1 : prefill_mask <= 8'b00000001;
                    3'd2 : prefill_mask <= 8'b00000011;
                    3'd3 : prefill_mask <= 8'b00000111;
                    3'd4 : prefill_mask <= 8'b00001111;
                    3'd5 : prefill_mask <= 8'b00011111;
                    3'd6 : prefill_mask <= 8'b00111111;
                    3'd7 : prefill_mask <= 8'b01111111;
                    default : prefill_mask <= prefill_mask;
                endcase
            end
            else begin
                prefill_en <= 0;
            end
        end
        else begin
            prefill_en <= 0;
            prefill_mask <= 8'hff;
        end
    end
end
// wr finish
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fifo_wr_finish <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_REQ && out_next_state == TDEC_OUT_DATA) begin
            fifo_wr_finish <= 0;
        end
        else if (tbd2wcdma_lst_d1) begin
            fifo_wr_finish <= 1;
        end
    end
end
//---------------------------------------------------------------------------
// Descrambling
//---------------------------------------------------------------------------
// scram_y proc
always @(posedge clk or posedge rst) begin
    if (rst) begin
        scram_y <= 16'h0100;        // {y[7:0], y[-1:-8]}
    end
    else begin
        if (is_hspdsch) begin
            if (out_cur_state == TDEC_OUT_IDLE && out_next_state == TDEC_OUT_REQ) begin
                scram_y <= 16'h0100;
            end
            else if (out_cur_state == TDEC_OUT_DATA && prefill_en) begin
                scram_y <= {scram_next[7:0], scram_y[15:8]};
            end
        end
    end
end
// scram_next
assign scram_next[0]    = scram_y[ 5] ^ scram_y[ 3] ^ scram_y[ 2] ^ scram_y[ 0];
assign scram_next[1]    = scram_y[ 6] ^ scram_y[ 4] ^ scram_y[ 3] ^ scram_y[ 1];
assign scram_next[2]    = scram_y[ 7] ^ scram_y[ 5] ^ scram_y[ 4] ^ scram_y[ 2];
assign scram_next[3]    = scram_y[ 8] ^ scram_y[ 6] ^ scram_y[ 5] ^ scram_y[ 3];
assign scram_next[4]    = scram_y[ 9] ^ scram_y[ 7] ^ scram_y[ 6] ^ scram_y[ 4];
assign scram_next[5]    = scram_y[10] ^ scram_y[ 8] ^ scram_y[ 7] ^ scram_y[ 5];
assign scram_next[6]    = scram_y[11] ^ scram_y[ 9] ^ scram_y[ 8] ^ scram_y[ 6];
assign scram_next[7]    = scram_y[12] ^ scram_y[10] ^ scram_y[ 9] ^ scram_y[ 7];
//---------------------------------------------------------------------------
// Fifo
// CRC check may interrupt unified tdec data output, due to an uncertained
// control latency, there may more than one output after ready becomes low, 
// so a fifo is used to cache data. If there is no CRC, data output to ribram
// or dbits_dump may also be disturbed by ram acknowledgement signal, a cache
// is also needed.
// If crc_en is 1: fifo read is under crc_check's control
// If crc_en is 0: fifo read is under 32-bit-word assemble's control
//---------------------------------------------------------------------------
assign crc_en = (wcrc_sel == 0) ? 1'b0 : 1'b1;
// fifo wirte port
assign fifo_flush       = start;
assign fifo_wr_en       = prefill_en;
assign fifo_wr_data     = prefill_mask & (prefill_data ^ (scram_y[15:8] & {8{is_hspdsch}}));    // 20170930, last non-8b word should be masked!!!
assign wcdma2tbd_rdy    = ~fifo_almost_full;
// fifo read port
assign fifo_rd_en       = (~crc_en | (crc_en & fifo_rd_req)) & (~fifo_empty) & (~fifo_hold_by_dbits);
// fifo inst
tdec_wrap_fifo ufifo (
    .clk                        ( clk                       ),
    .rst                        ( rst                       ),
    .flush                      ( fifo_flush                ),
    .wr_en                      ( fifo_wr_en                ),
    .wr_data                    ( fifo_wr_data              ),
    .rd_en                      ( fifo_rd_en                ),
    .rd_data                    ( fifo_rd_data              ),
    .fifo_empty                 ( fifo_empty                ),
    .fifo_almost_full           ( fifo_almost_full          )
);
//---------------------------------------------------------------------------
// CRC check
//---------------------------------------------------------------------------
// misc
assign crc_sel_2b = wcrc_sel[1:0];
assign crc_start = crc_en & out_first_cb & tbd2wcdma_vld & tbd2wcdma_fst;
// inst
tdec_wrap_crc ucrc (
    .clk                        ( clk                       ),
    .rst                        ( rst                       ),
    .start                      ( crc_start                 ),
    .is_hspdsch                 ( is_hspdsch                ),
    .ue_id                      ( hspdsch_uemask            ),
    .num_trblk                  ( num_trblk                 ),
    .trblk_size                 ( trblk_size                ),
    .crc_sel                    ( crc_sel_2b                ),
    .crc_att_method             ( crc_att_method            ),
    .fifo_rd_req                ( fifo_rd_req               ),
    .fifo_data_vld              ( fifo_rd_en                ),
    .fifo_data                  ( fifo_rd_data              ),
    .crc_match_en               ( crc_match_en              ),
    .crc_match                  ( crc_match                 )
    );
// finish flag
always @(posedge clk or posedge rst) begin
    if (rst) begin
        crc_finish <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_IDLE && out_next_state == TDEC_OUT_REQ) begin
            crc_finish <= 0;
        end
        else if (crc_match_en) begin
            crc_finish <= 1;
        end
    end
end
//---------------------------------------------------------------------------
// ribram_base_req
//---------------------------------------------------------------------------
// base_req
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ribram_base_req <= 0;
    end
    else begin
        if (dbits_dump_sel == 0 && out_cur_state == TDEC_OUT_IDLE && out_next_state == TDEC_OUT_REQ) begin
            ribram_base_req <= 1;
        end
        else begin
            ribram_base_req <= 0;
        end
    end
end
// base_reg
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ribram_base_reg <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_REQ && ribram_base_ack == 1) begin
            ribram_base_reg <= ribram_base;
        end
    end
end
//---------------------------------------------------------------------------
// 32-bit word assemble
//---------------------------------------------------------------------------
// pad data of the last word
assign word_pad_en = out_last_cb & (out_cur_state == TDEC_OUT_DATA) & fifo_wr_finish & fifo_empty & (|word_asm_cnt) & (~fifo_hold_by_dbits);
assign word_pad_data = 8'd0;
// input select
assign word_asm_in_en = fifo_rd_en | word_pad_en;
assign word_asm_in_data = word_pad_en ? word_pad_data : fifo_rd_data;
// intro word cnt
always @(posedge clk or posedge rst) begin
    if (rst) begin
        word_asm_cnt <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_IDLE && out_next_state == TDEC_OUT_REQ) begin
            word_asm_cnt <= 0;
        end
        else if (out_cur_state == TDEC_OUT_DATA && word_asm_in_en == 1) begin
            word_asm_cnt <= word_asm_cnt + 1;
        end
    end
end
// cache
always @(posedge clk or posedge rst) begin
    if (rst) begin
        word_asm_reg <= 0;
    end
    else begin
        if (word_asm_in_en && word_asm_cnt == 0) begin
            word_asm_reg[7:0] <= word_asm_in_data;
        end
        if (word_asm_in_en && word_asm_cnt == 1) begin
            word_asm_reg[15:8] <= word_asm_in_data;
        end
        if (word_asm_in_en && word_asm_cnt == 2) begin
            word_asm_reg[23:16] <= word_asm_in_data;
        end
    end
end
// addr
always @(posedge clk or posedge rst) begin
    if (rst) begin
        word_asm_out_addr <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_IDLE && out_next_state == TDEC_OUT_REQ) begin
            word_asm_out_addr <= 0;
        end
        else if (out_cur_state == TDEC_OUT_REQ) begin
            if (dbits_dump_sel == 0) begin
                if (ribram_base_ack == 1) begin
                    word_asm_out_addr <= ribram_base;
                end
            end
            else begin
                word_asm_out_addr <= 0;
            end
        end
        else if (out_cur_state == TDEC_OUT_DATA && word_asm_out_en == 1) begin
            word_asm_out_addr <= word_asm_out_addr + 1;
        end
    end
end
// 32-bit word output
always @(posedge clk or posedge rst) begin
    if (rst) begin
        word_asm_out_en <= 0;
        word_asm_out_data <= 0;
    end
    else begin
        if (word_asm_in_en && word_asm_cnt == 3) begin
            word_asm_out_en <= 1;
            word_asm_out_data <= {word_asm_in_data, word_asm_reg[23:0]};
        end
        else begin
            word_asm_out_en <= 0;
        end
    end
end
// backword control of fifo read
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dbits_wait_ack <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_IDLE && out_next_state == TDEC_OUT_REQ) begin
            dbits_wait_ack <= 0;
        end
        else if (word_asm_out_en & (~dbits_wr_ack)) begin
            dbits_wait_ack <= 1;
        end
        else if (dbits_wr_ack) begin
            dbits_wait_ack <= 0;
        end
    end
end
assign fifo_hold_by_dbits = dbits_wait_ack & word_asm_cnt[1];       // when hold assert there is one cycle delay ???
// finish flag?
assign dbits_finish_non_last_cb = fifo_wr_finish & fifo_empty & (~dbits_wr) & (~fifo_hold_by_dbits);
assign dbits_finish_last_cb = fifo_wr_finish & fifo_empty & (~dbits_wr) & (~word_pad_en) & (~fifo_hold_by_dbits) & crc_finish;
assign dbits_finish = out_last_cb ? dbits_finish_last_cb : dbits_finish_non_last_cb;
// cb_wlast
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dbits_cb_wlast <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_DATA && out_next_state != TDEC_OUT_DATA) begin
            dbits_cb_wlast <= 1;
        end
        else begin
            dbits_cb_wlast <= 0;
        end
    end
end
// wlast
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dbits_wlast <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_DATA && out_next_state == TDEC_OUT_HDR) begin
            dbits_wlast <= 1;
        end
        else begin
            dbits_wlast <= 0;
        end
    end
end
//---------------------------------------------------------------------------
// Header output
//---------------------------------------------------------------------------
// request
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ribram_header_req <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_DATA && out_next_state == TDEC_OUT_HDR) begin
            ribram_header_req <= ~dbits_dump_sel;
        end
        else begin
            ribram_header_req <= 0;
        end
    end
end
// header_wr
always @(posedge clk or posedge rst) begin
    if (rst) begin
        header_wr <= 0;
    end
    else begin
        if ((dbits_dump_sel && out_cur_state == TDEC_OUT_DATA && out_next_state == TDEC_OUT_HDR) ||
            (~dbits_dump_sel && ribram_header_ack == 1) ||
            (header0_wr_flag && dbits_wr_ack == 1)) begin
            header_wr <= 1;
        end
        else begin
            header_wr <= 0;
        end
    end
end
// header_flag
always @(posedge clk or posedge rst) begin
    if (rst) begin
        header0_wr_flag <= 0;
        header1_wr_flag <= 0;
    end
    else begin
        // header0
        if ((dbits_dump_sel == 1 && out_cur_state == TDEC_OUT_DATA && out_next_state == TDEC_OUT_HDR) ||
            (dbits_dump_sel == 0 && ribram_header_ack == 1)) begin
            header0_wr_flag <= 1;
        end
        else if (header0_wr_flag & dbits_wr_ack) begin
            header0_wr_flag <= 0;
        end
        // header1
        if (header0_wr_flag && dbits_wr_ack == 1) begin
            header1_wr_flag <= 1;
        end
        else if (header1_wr_flag & dbits_wr_ack) begin
            header1_wr_flag <= 0;
        end
    end
end
// header_waddr
always @(posedge clk or posedge rst) begin
    if (rst) begin
        header_waddr <= 0;
    end
    else begin
        if (dbits_dump_sel == 1 && out_cur_state == TDEC_OUT_DATA && out_next_state == TDEC_OUT_HDR) begin
            header_waddr <= 10'h3C0;            // dbits_dump header 0 addr
        end
        else if (dbits_dump_sel == 0 && ribram_header_ack == 1) begin
            header_waddr <= ribram_header_ptr;  // ribram header 0 addr
        end
        else if (header0_wr_flag && dbits_wr_ack == 1) begin
            header_waddr <= header_waddr + 1;   // header 1 addr
        end
    end
end
// header_wdata
assign header0_data = {task_tag[15:0], 4'b0000, src_type, ribram_base_reg};
assign header1_data = crc_match;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        header_wdata <= 0;
    end
    else begin
        if ((dbits_dump_sel == 1 && out_cur_state == TDEC_OUT_DATA && out_next_state == TDEC_OUT_HDR) ||
            (dbits_dump_sel == 0 && ribram_header_ack == 1)) begin
            header_wdata <= header0_data;   // header0
        end
        else if (header0_wr_flag && dbits_wr_ack == 1) begin
            header_wdata <= header1_data;    // header1
        end
    end
end
// header_reg
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ribram_header_reg <= 0;
    end
    else begin
        if (dbits_dump_sel == 0 && out_cur_state == TDEC_OUT_HDR && ribram_header_ack == 1) begin
            ribram_header_reg <= ribram_header_ptr;
        end
    end
end
// tdec_last_ptr
always @(posedge clk or posedge rst) begin
    if (rst) begin
        tdec_last_ptr <= 0;
    end
    else begin
        if (dbits_dump_sel == 0 && out_cur_state == TDEC_OUT_HDR && header1_wr_flag == 1 && dbits_wr_ack == 1) begin
            tdec_last_ptr <= ribram_header_reg;
        end
    end
end
// dbits output
assign dbits_wr = word_asm_out_en | header_wr;
assign dbits_wdata = word_asm_out_en ? word_asm_out_data : header_wdata;
assign dbits_waddr = word_asm_out_en ? word_asm_out_addr : header_waddr;
// done
always @(posedge clk or posedge rst) begin
    if (rst) begin
        done <= 0;
    end
    else begin
        if (out_cur_state == TDEC_OUT_HDR && header1_wr_flag == 1 && dbits_wr_ack == 1) begin
            done <= 1;
        end
        else begin
            done <= 0;
        end
    end
end
// busy
always @(posedge clk or posedge rst) begin
    if (rst) begin
        busy <= 0;
    end
    else begin
        if (start) begin
            busy <= 1;
        end
        else if (done) begin
            busy <= 0;
        end
    end
end

//---------------------------------------------------------------------------
// ARM Interrupt : use "src_type" to distinguish two carriers
//---------------------------------------------------------------------------
assign ca0_tdec_int = (src_type == 2'b00) ? done : 1'b0;
assign ca1_tdec_int = (src_type == 2'b11) ? done : 1'b0;
//---------------------------------------------------------------------------
// XDSP Interrupt : use "trch_index" to distinguish two carriers
//---------------------------------------------------------------------------
assign ca0_tdec_int_dpa = (trch_index != 6'd27) ? hspdsch_dec_done : 1'b0;
assign ca1_tdec_int_dpa = (trch_index == 6'd27) ? hspdsch_dec_done : 1'b0;

endmodule

//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_wrap_crc                                     //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : Method 1 or method 2 CRC check                    //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170807    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
module tdec_wrap_crc (
    clk,
    rst,
    start,
    is_hspdsch,
    ue_id,
    num_trblk,
    trblk_size,
    crc_sel,
    crc_att_method,
    fifo_rd_req,
    fifo_data_vld,
    fifo_data,
    crc_match_en,
    crc_match
    );

// port declearation
input                       clk;
input                       rst;
input                       start;
input                       is_hspdsch;
input   [15:0]              ue_id;
input   [5:0]               num_trblk;
input   [15:0]              trblk_size;
input   [1:0]               crc_sel;        // 0:8b, 1:12b, 2:16b, 3:24b
input                       crc_att_method;
output                      fifo_rd_req;
input                       fifo_data_vld;
input   [7:0]               fifo_data;
output                      crc_match_en;
output  [31:0]              crc_match;

// internal wire/register
reg     [15:0]              t0;             // trblk_size
reg     [5:0]               t1;             // trblk_num
reg     [38:0]              data_cache;     // max: 32+7=39
reg     [6:0]               tail_cache;     // max: 7
reg     [23:0]              crc_cache;      // crc shift in and reversed
reg     [7:0]               crc_tail_num;   // non_8b_tail + reversed&unmasked crc
reg     [2:0]               rem_cnt;        // remant data counter, 0~7
reg     [3:0]               req_size;       // 0~7
reg     [6:0]               rem_data_parity;    // 
wire    [2:0]               tail_size;      // 0~7
reg     [4:0]               tail_crc_size;  // max: 24+7=31
reg     [1:0]               crc_x8_num_m1;  // num of 8 bits
wire    [2:0]               tail_crc_x8_num_m1;  // 0~3
reg     [23:0]              crc;
wire    [7:0]               crc8_next;
wire    [11:0]              crc12_next;
wire    [15:0]              crc16_next;
wire    [23:0]              crc24_next;
wire    [7:0]               crc_8b_in;
wire                        in_word;
reg     [31:0]              crc_match_shift;
reg                         crc_done;
reg     [2:0]               cur_state;
reg     [2:0]               next_state;
wire    [5:0]               num_trblk_m1;
wire                        fifo_plus_rem;
parameter                   CRC_IDLE        = 3'b000;
parameter                   CRC_DATA8_PROC  = 3'b001;
parameter                   CRC_TAIL_CACHE  = 3'b010;
parameter                   CRC_CRC_CACHE   = 3'b011;
parameter                   CRC_TAIL_PROC   = 3'b100;
parameter                   CRC_BLK_FINISH  = 3'b101;

// num_trblk_m1
assign num_trblk_m1 = num_trblk - 1;
// crc_x8_num
always @(*) begin
    case (crc_sel)
        2'b00:      crc_x8_num_m1 = 2'b00;
        2'b01:      crc_x8_num_m1 = 2'b01;
        2'b10:      crc_x8_num_m1 = 2'b01;
        default:    crc_x8_num_m1 = 2'b10;
    endcase
end
// tail_size
assign tail_size = trblk_size[2:0];
// size of tail plus crc
always @(*) begin
    case (crc_sel)
        2'b00:      tail_crc_size = {2'b01, tail_size};     // tail + 8
        2'b01:                                              // tail + 12
            if (tail_size[2]) begin
                tail_crc_size = {3'b100 , tail_size[1:0]};
            end
            else begin
                tail_crc_size = {3'b011 , tail_size[1:0]};
            end
        2'b10:      tail_crc_size = {2'b10, tail_size};     // tail + 16
        default:    tail_crc_size = {2'b11, tail_size};     // tail + 24
    endcase
end
// tail_plus_crc x8 size
assign tail_crc_x8_num_m1 = (|tail_crc_size[2:0]) ? {1'b0, tail_crc_size[4:3]} : 
                                                    {1'b0, tail_crc_size[4:3]} - 3'b001;

//----------------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------------
// syn
always @(posedge rst or posedge clk) begin
    if (rst) begin
        cur_state <= CRC_IDLE;
    end
    else begin
        cur_state <= next_state;
    end
end
// combine
always @(*) begin
    case (cur_state)
        CRC_IDLE:
            if (start) begin
                if (trblk_size == 0) begin
                    next_state = CRC_CRC_CACHE;
                end
                else if (trblk_size[15:3] > 0) begin
                    next_state = CRC_DATA8_PROC;
                end
                else begin
                    next_state = CRC_TAIL_CACHE;
                end
            end
            else begin
                next_state = CRC_IDLE;
            end
        CRC_DATA8_PROC:
            if (in_word) begin
                if (t0[12:0] == trblk_size[15:3]-1) begin
                    if (trblk_size[2:0] > 0) begin
                        next_state = CRC_TAIL_CACHE;
                    end
                    else begin
                        next_state = CRC_CRC_CACHE;
                    end
                end
                else begin
                    next_state = CRC_DATA8_PROC;
                end
            end
            else begin
                next_state = CRC_DATA8_PROC;
            end
        CRC_TAIL_CACHE:
            if (in_word) begin
                next_state = CRC_CRC_CACHE;
            end
            else begin
                next_state = CRC_TAIL_CACHE;
            end
        CRC_CRC_CACHE:
            if (in_word && t0[1:0] == crc_x8_num_m1) begin
                next_state = CRC_TAIL_PROC;
            end
            else begin
                next_state = CRC_CRC_CACHE;
            end
        CRC_TAIL_PROC:
            if (t0[2:0] == tail_crc_x8_num_m1) begin
                next_state = CRC_BLK_FINISH;
            end
            else begin
                next_state = CRC_TAIL_PROC;
            end
        CRC_BLK_FINISH:
            if (t1 == num_trblk_m1) begin
                next_state = CRC_IDLE;
            end
            else begin
                if (trblk_size == 0) begin
                    next_state = CRC_CRC_CACHE;
                end
                else if (trblk_size[15:3] > 0) begin
                    next_state = CRC_DATA8_PROC;
                end
                else begin
                    next_state = CRC_TAIL_CACHE;
                end
            end
        default:
            next_state = CRC_IDLE;
    endcase
end


// t0 ctrl
always @(posedge rst or posedge clk) begin
    if (rst) begin
        t0 <= 0;
    end
    else begin
        if ((cur_state == CRC_IDLE && start == 1) ||
            (cur_state == CRC_DATA8_PROC && next_state != CRC_DATA8_PROC) ||
            (cur_state == CRC_CRC_CACHE && next_state != CRC_CRC_CACHE) ||
            (cur_state == CRC_TAIL_PROC && next_state != CRC_TAIL_PROC)) begin
            t0 <= 0;
        end
        else if ((cur_state == CRC_DATA8_PROC && in_word == 1) ||
                 (cur_state == CRC_CRC_CACHE && in_word == 1) ||
                 (cur_state == CRC_TAIL_PROC )) begin
            t0 <= t0 + 1;
        end
    end
end
// t1 ctrl
always @(posedge rst or posedge clk) begin
    if (rst) begin
        t1 <= 0;
    end
    else begin
        if (cur_state == CRC_IDLE && start == 1) begin
            t1 <= 0;
        end
        else if (cur_state == CRC_BLK_FINISH) begin
            t1 <= t1 + 1;
        end
    end
end
// req_size
always @(*) begin
    case (cur_state)
        CRC_DATA8_PROC: req_size = 4'd8;
        CRC_TAIL_CACHE: req_size = {1'b0, tail_size};
        CRC_CRC_CACHE: 
            if (crc_sel == 1 && t0[1:0] == 1) begin
                req_size = 4'd4;
            end
            else begin
                req_size = 4'd8;
            end
        default: req_size = 0;
    endcase
end
assign fifo_plus_rem = (req_size > {1'b0, rem_cnt}) ? 1'b1 : 1'b0;
assign fifo_rd_req = fifo_plus_rem;
assign in_word = (req_size > {1'b0, rem_cnt}) ? fifo_data_vld : 1'b1;
wire    [3:0] rem_cnt_tmp0;
assign rem_cnt_tmp0 = 4'b1000 + {1'b0, rem_cnt} - req_size;
// remant counter
always @(posedge rst or posedge clk) begin
    if (rst) begin
        rem_cnt <= 0;
    end
    else begin
        if (cur_state == CRC_IDLE && start == 1) begin
            rem_cnt <= 0;
        end
        else if ((cur_state == CRC_DATA8_PROC) ||
                 (cur_state == CRC_TAIL_CACHE) ||
                 (cur_state == CRC_CRC_CACHE)) begin
            if (in_word) begin
                if (fifo_plus_rem) begin
                    rem_cnt <= rem_cnt_tmp0[2:0];
                end
                else begin
                    rem_cnt <= rem_cnt - req_size[2:0];
                end
            end
        end
    end
end
// input data cache
always @(posedge rst or posedge clk) begin
    if (rst) begin
        data_cache <= 0;
    end
    else begin
        if (cur_state == CRC_IDLE && start == 1) begin
            data_cache <= 0;
        end
        else if ((cur_state == CRC_DATA8_PROC) || 
                 (cur_state == CRC_TAIL_CACHE) || 
                 (cur_state == CRC_CRC_CACHE)) begin
            if (in_word) begin
                if (fifo_plus_rem) begin
                    case (rem_cnt_tmp0[2:0])
                        3'd0 : data_cache <= 7'd0;
                        3'd1 : data_cache <= {6'd0, fifo_data[7:7]};
                        3'd2 : data_cache <= {5'd0, fifo_data[7:6]};
                        3'd3 : data_cache <= {4'd0, fifo_data[7:5]};
                        3'd4 : data_cache <= {3'd0, fifo_data[7:4]};
                        3'd5 : data_cache <= {2'd0, fifo_data[7:3]};
                        3'd6 : data_cache <= {1'd0, fifo_data[7:2]};
                        3'd7 : data_cache <=  fifo_data[7:1];
                        default : data_cache <= data_cache;
                    endcase
                end
                else begin
                    case (req_size)
                        4'd0: data_cache <= data_cache;
                        4'd1: data_cache <= {1'd0, data_cache[6:1]};
                        4'd2: data_cache <= {2'd0, data_cache[6:2]};
                        4'd3: data_cache <= {3'd0, data_cache[6:3]};
                        4'd4: data_cache <= {4'd0, data_cache[6:4]};
                        4'd5: data_cache <= {5'd0, data_cache[6:5]};
                        4'd6: data_cache <= {6'd0, data_cache[6:6]};
                        4'd7: data_cache <=  7'd0                  ;
                        default : data_cache <= data_cache;
                    endcase
                end
            end
        end
    end
end

reg     [7:0]       data_8b_org;
reg     [7:0]       data_8b_req;
// 8b req data
always @(*) begin
    case (rem_cnt)
        3'd0 : data_8b_org =  fifo_data[7:0];
        3'd1 : data_8b_org = {fifo_data[6:0], data_cache[0:0]};
        3'd2 : data_8b_org = {fifo_data[5:0], data_cache[1:0]};
        3'd3 : data_8b_org = {fifo_data[4:0], data_cache[2:0]};
        3'd4 : data_8b_org = {fifo_data[3:0], data_cache[3:0]};
        3'd5 : data_8b_org = {fifo_data[2:0], data_cache[4:0]};
        3'd6 : data_8b_org = {fifo_data[1:0], data_cache[5:0]};
        3'd7 : data_8b_org = {fifo_data[0:0], data_cache[6:0]};
    endcase
end
// 8b req data
always @(*) begin
    case (req_size)
        4'd1 : data_8b_req = {7'd0, data_8b_org[0:0]};
        4'd2 : data_8b_req = {6'd0, data_8b_org[1:0]};
        4'd3 : data_8b_req = {5'd0, data_8b_org[2:0]};
        4'd4 : data_8b_req = {4'd0, data_8b_org[3:0]};
        4'd5 : data_8b_req = {3'd0, data_8b_org[4:0]};
        4'd6 : data_8b_req = {2'd0, data_8b_org[5:0]};
        4'd7 : data_8b_req = {1'd0, data_8b_org[6:0]};
        4'd8 : data_8b_req =        data_8b_org[7:0] ;
        default : data_8b_req = 0;
    endcase
end
// tail cache
always @(posedge rst or posedge clk) begin
    if (rst) begin
        tail_cache <= 0;
    end
    else begin
        if (cur_state == CRC_TAIL_CACHE && in_word == 1) begin
            tail_cache <= data_8b_req[6:0];
        end
    end
end
// crc cache
always @(posedge rst or posedge clk) begin
    if (rst) begin
        crc_cache <= 0;
    end
    else begin
        if (cur_state == CRC_IDLE && start == 1) begin
            crc_cache <= 0;
        end
        else if (cur_state == CRC_CRC_CACHE && in_word == 1) begin
            if (crc_sel == 1 && t0[0] == 1) begin
                crc_cache <= {data_8b_req[3:0], crc_cache[23:4]};
            end
            else begin
                if (is_hspdsch & crc_att_method) begin      // bit seq????
                    if (t0[1:0] == 2'd0) begin
                        crc_cache <= {data_8b_req, crc_cache[23:8]};
                    end
                    else if (t0[1:0] == 2'd1) begin
                        crc_cache <= {(data_8b_req^{ue_id[8], ue_id[9], ue_id[10], ue_id[11], ue_id[12], ue_id[13], ue_id[14], ue_id[15]}), crc_cache[23:8]};
                    end
                    else if (t0[1:0] == 2'd2) begin
                        crc_cache <= {(data_8b_req^{ue_id[0], ue_id[1], ue_id[2], ue_id[3], ue_id[4], ue_id[5], ue_id[6], ue_id[7]}), crc_cache[23:8]};
                    end
                end
                else begin
                    crc_cache <= {data_8b_req, crc_cache[23:8]};
                end
            end
        end
        else if (cur_state == CRC_TAIL_PROC) begin
            if (t0[1:0] == 0) begin
                case (tail_size)
                    3'd0 : crc_cache <= {crc_cache[15:0], 8'd0};
                    3'd1 : crc_cache <= {crc_cache[16:0], 7'd0};
                    3'd2 : crc_cache <= {crc_cache[17:0], 6'd0};
                    3'd3 : crc_cache <= {crc_cache[18:0], 5'd0};
                    3'd4 : crc_cache <= {crc_cache[19:0], 4'd0};
                    3'd5 : crc_cache <= {crc_cache[20:0], 3'd0};
                    3'd6 : crc_cache <= {crc_cache[21:0], 2'd0};
                    3'd7 : crc_cache <= {crc_cache[22:0], 1'd0};
                    default : crc_cache <= crc_cache;
                endcase
            end
            else begin
                crc_cache <= {crc_cache[15:0], 8'd0};
            end
        end
    end
end

reg     [7:0]       crc_tail_mux;
// crc_tail_mux proc
always @(*) begin
    if (cur_state == CRC_TAIL_PROC) begin
        if (t0[1:0] == 0) begin
            case (tail_size)
                3'd0 : crc_tail_mux = {crc_cache[16], crc_cache[17], crc_cache[18], crc_cache[19], crc_cache[20], crc_cache[21], crc_cache[22], crc_cache[23]                 };
                3'd1 : crc_tail_mux = {               crc_cache[17], crc_cache[18], crc_cache[19], crc_cache[20], crc_cache[21], crc_cache[22], crc_cache[23], tail_cache[0:0]};
                3'd2 : crc_tail_mux = {                              crc_cache[18], crc_cache[19], crc_cache[20], crc_cache[21], crc_cache[22], crc_cache[23], tail_cache[1:0]};
                3'd3 : crc_tail_mux = {                                             crc_cache[19], crc_cache[20], crc_cache[21], crc_cache[22], crc_cache[23], tail_cache[2:0]};
                3'd4 : crc_tail_mux = {                                                            crc_cache[20], crc_cache[21], crc_cache[22], crc_cache[23], tail_cache[3:0]};
                3'd5 : crc_tail_mux = {                                                                           crc_cache[21], crc_cache[22], crc_cache[23], tail_cache[4:0]};
                3'd6 : crc_tail_mux = {                                                                                          crc_cache[22], crc_cache[23], tail_cache[5:0]};
                3'd7 : crc_tail_mux = {                                                                                                         crc_cache[23], tail_cache[6:0]};
                default : crc_tail_mux = 0;
            endcase
        end
        else begin
            crc_tail_mux = {crc_cache[16], crc_cache[17], crc_cache[18], crc_cache[19], crc_cache[20], crc_cache[21], crc_cache[22], crc_cache[23]};
        end
    end
    else begin
        crc_tail_mux = 0;
    end
end
// input of crc
assign crc_8b_in = (cur_state == CRC_TAIL_PROC) ? crc_tail_mux : data_8b_req;
// crc8 inst
tdec_wrap_crc8_calc ucrc8_calc (
    .di         ( crc_8b_in         ),
    .ci         ( crc[7:0]          ),
    .co         ( crc8_next         )
);
// crc12 inst
tdec_wrap_crc12_calc ucrc12_calc (
    .di         ( crc_8b_in         ),
    .ci         ( crc[11:0]         ),
    .co         ( crc12_next        )
);
// crc16 inst
tdec_wrap_crc16_calc ucrc16_calc (
    .di         ( crc_8b_in         ),
    .ci         ( crc[15:0]         ),
    .co         ( crc16_next        )
);
// crc24 inst
tdec_wrap_crc24_calc ucrc24_calc (
    .di         ( crc_8b_in         ),
    .ci         ( crc[23:0]         ),
    .co         ( crc24_next        )
);

// crc_calc
always @(posedge rst or posedge clk) begin
    if (rst) begin
        crc <= 0;
    end
    else begin
        if (cur_state == CRC_IDLE || cur_state == CRC_BLK_FINISH) begin
            crc <= 0;
        end
        else if ((cur_state == CRC_DATA8_PROC && in_word == 1) ||
                 (cur_state == CRC_TAIL_PROC)) begin
            case (crc_sel)
                2'd0 : crc[7:0]  <= crc8_next;
                2'd1 : crc[11:0] <= crc12_next;
                2'd2 : crc[15:0] <= crc16_next;
                2'd3 : crc[23:0] <= crc24_next;
                default : crc <= crc;
            endcase
        end
    end
end
// crc_match
always @(posedge rst or posedge clk) begin
    if (rst) begin
        crc_match_shift <= 0;
    end
    else begin
        if (cur_state == CRC_BLK_FINISH) begin
            case (t1[4:0])
                5'd0  : crc_match_shift[ 0] <= ~(|crc);
                5'd1  : crc_match_shift[ 1] <= ~(|crc);
                5'd2  : crc_match_shift[ 2] <= ~(|crc);
                5'd3  : crc_match_shift[ 3] <= ~(|crc);
                5'd4  : crc_match_shift[ 4] <= ~(|crc);
                5'd5  : crc_match_shift[ 5] <= ~(|crc);
                5'd6  : crc_match_shift[ 6] <= ~(|crc);
                5'd7  : crc_match_shift[ 7] <= ~(|crc);
                5'd8  : crc_match_shift[ 8] <= ~(|crc);
                5'd9  : crc_match_shift[ 9] <= ~(|crc);
                5'd10 : crc_match_shift[10] <= ~(|crc);
                5'd11 : crc_match_shift[11] <= ~(|crc);
                5'd12 : crc_match_shift[12] <= ~(|crc);
                5'd13 : crc_match_shift[13] <= ~(|crc);
                5'd14 : crc_match_shift[14] <= ~(|crc);
                5'd15 : crc_match_shift[15] <= ~(|crc);
                5'd16 : crc_match_shift[16] <= ~(|crc);
                5'd17 : crc_match_shift[17] <= ~(|crc);
                5'd18 : crc_match_shift[18] <= ~(|crc);
                5'd19 : crc_match_shift[19] <= ~(|crc);
                5'd20 : crc_match_shift[20] <= ~(|crc);
                5'd21 : crc_match_shift[21] <= ~(|crc);
                5'd22 : crc_match_shift[22] <= ~(|crc);
                5'd23 : crc_match_shift[23] <= ~(|crc);
                5'd24 : crc_match_shift[24] <= ~(|crc);
                5'd25 : crc_match_shift[25] <= ~(|crc);
                5'd26 : crc_match_shift[26] <= ~(|crc);
                5'd27 : crc_match_shift[27] <= ~(|crc);
                5'd28 : crc_match_shift[28] <= ~(|crc);
                5'd29 : crc_match_shift[29] <= ~(|crc);
                5'd30 : crc_match_shift[30] <= ~(|crc);
                5'd31 : crc_match_shift[31] <= ~(|crc);
                default : crc_match_shift <= crc_match_shift;
            endcase
        end
    end
end
// done
always @(posedge rst or posedge clk) begin
    if (rst) begin
        crc_done <= 0;
    end
    else begin
        if (cur_state == CRC_BLK_FINISH && t1 == num_trblk_m1) begin
            crc_done <= 1;
        end
        else begin
            crc_done <= 0;
        end
    end
end
// output
assign crc_match_en = crc_done;
assign crc_match = crc_match_shift;
                
endmodule

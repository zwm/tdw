//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_crc24_calc                                   //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : 8-bit parallel CRC calc for crc-24                //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170807    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
module tdec_wrap_crc24_calc (
    di,
    ci,
    co,
    );

// port declearation
input       [7:0]           di;
input       [23:0]          ci;
output      [23:0]          co;

assign co[0]    = di[0]^di[1]^di[2]^di[3]^di[4]^di[5]^di[6]^di[7]^ci[16]^ci[17]^ci[18]^ci[19]^ci[20]^ci[21]^ci[22]^ci[23];
assign co[1]    = di[7]^ci[16];
assign co[2]    = di[6]^ci[17];
assign co[3]    = di[5]^ci[18];
assign co[4]    = di[4]^ci[19];
assign co[5]    = di[0]^di[1]^di[2]^di[4]^di[5]^di[6]^di[7]^ci[16]^ci[17]^ci[18]^ci[19]^ci[21]^ci[22]^ci[23];
assign co[6]    = di[2]^di[7]^ci[16]^ci[21];
assign co[7]    = di[1]^di[6]^ci[17]^ci[22];
assign co[8]    = di[0]^di[5]^ci[0]^ci[18]^ci[23];
assign co[9]    = di[4]^ci[1]^ci[19];
assign co[10]   = di[3]^ci[2]^ci[20];
assign co[11]   = di[2]^ci[3]^ci[21];
assign co[12]   = di[1]^ci[4]^ci[22];
assign co[13]   = di[0]^ci[5]^ci[23];
assign co[14]   = ci[6];
assign co[15]   = ci[7];
assign co[16]   = ci[8];
assign co[17]   = ci[9];
assign co[18]   = ci[10];
assign co[19]   = ci[11];
assign co[20]   = ci[12];
assign co[21]   = ci[13];
assign co[22]   = ci[14];
assign co[23]   = di[0]^di[1]^di[2]^di[3]^di[4]^di[5]^di[6]^di[7]^ci[15]^ci[16]^ci[17]^ci[18]^ci[19]^ci[20]^ci[21]^ci[22]^ci[23];

endmodule

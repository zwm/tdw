//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_crc16_calc                                   //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : 8-bit parallel CRC calc for crc-16                //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170807    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
module tdec_wrap_crc16_calc (
    di,
    ci,
    co,
    );

// port declearation
input       [7:0]           di;
input       [15:0]          ci;
output      [15:0]          co;

assign co[0]    = di[3]^di[7]^ci[8]^ci[12];
assign co[1]    = di[2]^di[6]^ci[9]^ci[13];
assign co[2]    = di[1]^di[5]^ci[10]^ci[14];
assign co[3]    = di[0]^di[4]^ci[11]^ci[15];
assign co[4]    = di[3]^ci[12];
assign co[5]    = di[2]^di[3]^di[7]^ci[8]^ci[12]^ci[13];
assign co[6]    = di[1]^di[2]^di[6]^ci[9]^ci[13]^ci[14];
assign co[7]    = di[0]^di[1]^di[5]^ci[10]^ci[14]^ci[15];
assign co[8]    = di[0]^di[4]^ci[0]^ci[11]^ci[15];
assign co[9]    = di[3]^ci[1]^ci[12];
assign co[10]   = di[2]^ci[2]^ci[13];
assign co[11]   = di[1]^ci[3]^ci[14];
assign co[12]   = di[0]^di[3]^di[7]^ci[4]^ci[8]^ci[12]^ci[15];
assign co[13]   = di[2]^di[6]^ci[5]^ci[9]^ci[13];
assign co[14]   = di[1]^di[5]^ci[6]^ci[10]^ci[14];
assign co[15]   = di[0]^di[4]^ci[7]^ci[11]^ci[15];

endmodule

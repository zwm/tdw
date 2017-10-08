//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_crc8_calc                                    //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : 8-bit parallel CRC calc for crc-8                 //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170807    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
module tdec_wrap_crc8_calc (
    di,
    ci,
    co,
    );

// port declearation
input       [7:0]           di;
input       [7:0]           ci;
output      [7:0]           co;

assign co[0]    = di[0]^di[4]^di[5]^di[6]^di[7]^ci[0]^ci[1]^ci[2]^ci[3]^ci[7];
assign co[1]    = di[0]^di[3]^di[7]^ci[0]^ci[4]^ci[7];
assign co[2]    = di[2]^di[6]^ci[1]^ci[5];
assign co[3]    = di[0]^di[1]^di[4]^di[6]^di[7]^ci[0]^ci[1]^ci[3]^ci[6]^ci[7];
assign co[4]    = di[3]^di[4]^di[7]^ci[0]^ci[3]^ci[4];
assign co[5]    = di[2]^di[3]^di[6]^ci[1]^ci[4]^ci[5];
assign co[6]    = di[1]^di[2]^di[5]^ci[2]^ci[5]^ci[6];
assign co[7]    = di[1]^di[5]^di[6]^di[7]^ci[0]^ci[1]^ci[2]^ci[6];

endmodule

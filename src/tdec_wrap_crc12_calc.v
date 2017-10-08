//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_crc12_calc                                   //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : 8-bit parallel CRC calc for crc-12                //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170807    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
module tdec_wrap_crc12_calc (
    di,
    ci,
    co,
    );

// port declearation
input       [7:0]           di;
input       [11:0]          ci;
output      [11:0]          co;

assign co[0]    = di[0]^di[1]^di[2]^di[3]^di[4]^di[5]^di[6]^di[7]^ci[4]^ci[5]^ci[6]^ci[7]^ci[8]^ci[9]^ci[10]^ci[11];
assign co[1]    = di[7]^ci[4];
assign co[2]    = di[0]^di[1]^di[2]^di[3]^di[4]^di[5]^di[7]^ci[4]^ci[6]^ci[7]^ci[8]^ci[9]^ci[10]^ci[11];
assign co[3]    = di[5]^di[7]^ci[4]^ci[6];
assign co[4]    = di[4]^di[6]^ci[5]^ci[7];
assign co[5]    = di[3]^di[5]^ci[6]^ci[8];
assign co[6]    = di[2]^di[4]^ci[7]^ci[9];
assign co[7]    = di[1]^di[3]^ci[8]^ci[10];
assign co[8]    = di[0]^di[2]^ci[0]^ci[9]^ci[11];
assign co[9]    = di[1]^ci[1]^ci[10];
assign co[10]   = di[0]^ci[2]^ci[11];
assign co[11]   = di[0]^di[1]^di[2]^di[3]^di[4]^di[5]^di[6]^di[7]^ci[3]^ci[4]^ci[5]^ci[6]^ci[7]^ci[8]^ci[9]^ci[10]^ci[11];

endmodule

//////////////////////////////////////////////////////////////////////////////
// Module Name          : tdec_wrap_define                                  //
//                                                                          //
// Type                 : Module                                            //
//                                                                          //
// Module Description   : Parameters of tdec_wrapper                        //
//                                                                          //
// Timing Constraints   : Module is designed to work with a clock frequency //
//                        of 307.2 MHz                                      //
//                                                                          //
// Revision History     : 20170807    V0.1    File created                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// fifo
`define TDEC_WRAP_FIFO_DEPTH        8
// `define TDEC_WRAP_FIFO_THRES        4
`define TDEC_WRAP_FIFO_THRES        2       // 20170930, modified from 4 to 2, for safity fifo control
`define TDEC_WRAP_FIFO_AWIDTH       3

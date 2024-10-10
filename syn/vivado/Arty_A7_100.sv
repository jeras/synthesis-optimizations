`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent inc.
// Engineer: Samuel Lowe
// Engineer Email: samuel.lowe@ni.com
// Create Date: 05/28/2015 03:26:51 PM
// Design Name: XADCdemo
// Module Name: XADCdemo: 
// Target Devices: ARTY
// Tool Versions: Vivado 15.1
// Description: A top level design for reading values off of the XADC Pmod port of the ARTY FPGA
// 
// Dependencies: 
// 
// Revision: 3/3/2015
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
 

module Arty_A7_100 (
    // clock
    input  wire        CLK100MHZ,
    input  wire  [8:0] ck_an_p,
    input  wire  [8:0] ck_an_n,
    input  wire        vp_in,
    input  wire        vn_in,
    // GPIO
    input  wire  [3:0] sw,
    input  wire  [3:0] btn,
    output wire  [7:4] led,
    // GPIO
    inout  wire [41:0] ck_io,
    // PMOD
    input  wire [10:1] ja,
    input  wire [10:1] jb,
    input  wire [10:1] jc,
    input  wire [10:1] jd
);

////////////////////////////////////////////////////////////////////////////////
// local signals
////////////////////////////////////////////////////////////////////////////////

    logic clk;
    logic rst;

    logic [41:0] ck_i;
    logic [41:0] ck_o;

////////////////////////////////////////////////////////////////////////////////
// xpm_cdc_async_rst: Asynchronous Reset Synchronizer
// Xilinx Parameterized Macro, version 2023.2
////////////////////////////////////////////////////////////////////////////////

    assign clk = CLK100MHZ;

    xpm_cdc_async_rst #(
       .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
       .INIT_SYNC_FF(1),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
    ) xpm_cdc_async_rst_inst (
       .dest_clk  (clk),     // Destination clock.
       .src_arst  (btn[0]),  // Source asynchronous reset signal.
       .dest_arst (rst)
    );

    assign ck_i = ck_io;
    assign ck_io = btn[1] ? ck_o : 'z;

////////////////////////////////////////////////////////////////////////////////
// RTL instances
////////////////////////////////////////////////////////////////////////////////

    localparam int unsigned NUMBER = 1;

    synthesis_optimization_top #(
        .NUM_I  (4),
        .NUM_O  (4),
        .NUM_IO (NUMBER)
    ) top (
        // system signals
        .clk (clk),
        .rst (rst),
        // GPIO
        .gpi (sw),
        .gpo (led),
        .p_i (ck_i[NUMBER-1:0]),
        .p_o (ck_o[NUMBER-1:0])
    );

endmodule: Arty_A7_100

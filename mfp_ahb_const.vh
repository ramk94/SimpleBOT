// 
// mfp_ahb_const.vh
//
// Verilog include file with AHB definitions
// 

//---------------------------------------------------
// Physical bit-width of memory-mapped I/O interfaces
//---------------------------------------------------
`define MFP_N_LED             16
`define MFP_N_SW              16
`define MFP_N_PB              6
`define MFP_N_SEVEN        	  32      //Number of LEDS on SEVEN SEG digits


//---------------------------------------------------
// Memory-mapped I/O addresses
//---------------------------------------------------
`define H_LED_ADDR    			(32'h1f800000)
`define H_SW_ADDR   			(32'h1f800004)
`define H_PB_ADDR   			(32'h1f800008)
`define H_7SEG_ENABLE_ADDR		(32'h1f700000)     //Physical address of Seven Segment Digit Enable Register
`define H_7SEG_UPPER_ADDR		(32'h1f700004)     //Physical address of Seven Segment LOWER Register
`define H_7SEG_LOWER_ADDR		(32'h1f700008)     //Physical address of Seven Segment UPPER Register
`define H_7SEG_DP_ADDR		    (32'h1f70000C)     //Physical address of Seven Segment DECIMAL Register


//For GPIOS
`define H_LED_IONUM   			(4'h0)            //Uses the 5:2 bits for mapping
`define H_SW_IONUM  			(4'h1)
`define H_PB_IONUM  			(4'h2)

//FOR SEVEN SEGMENT DISPLAY
`define H_7SEGEN_IONUM  		(4'h0)          //Using the same idea of GPIO's for MAPPING 5:2 bits
`define H_7SEGUPPER_IONUM  		(4'h1)   
`define H_7SEGLOWER_IONUM  	    (4'h2)   
`define H_7SEGEDECIMAL_IONUM  	(4'h3)   


//---------------------------------------------------
// RAM addresses
//---------------------------------------------------
`define H_RAM_RESET_ADDR 		(32'h1fc?????)
`define H_RAM_ADDR	 		    (32'h0???????)
`define H_RAM_RESET_ADDR_WIDTH  (8) 
`define H_RAM_ADDR_WIDTH		(16) 

`define H_RAM_RESET_ADDR_Match  (7'h7f)
`define H_RAM_ADDR_Match 		(1'b0)
`define H_LED_ADDR_Match		(7'h7e)
`define H_SEVEN_SEG_ADDR_Match	(7'h7d)				//Value obtained from taking bits 22-28 from Physical address of H_SEVEN_SEG_ADDR

//---------------------------------------------------
// AHB-Lite values used by MIPSfpga core
//---------------------------------------------------

`define HTRANS_IDLE    2'b00
`define HTRANS_NONSEQ  2'b10
`define HTRANS_SEQ     2'b11

`define HBURST_SINGLE  3'b000
`define HBURST_WRAP4   3'b010

`define HSIZE_1        3'b000
`define HSIZE_2        3'b001
`define HSIZE_4        3'b010

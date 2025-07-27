/*
 * Top-level module for RGB LCD display controller
 * Target: GW1NR-9 FPGA
 * Display: 480x272 RGB LCD
 */
module TOP
(
    // System Control Signals
    input           nRST,           // Active low reset signal
    input           XTAL_IN,        // 27MHz input crystal clock

    // LCD Interface Timing Signals
    output          LCD_CLK,        // Pixel clock output to LCD
    output          LCD_HYNC,       // Horizontal synchronization
    output          LCD_SYNC,       // Vertical synchronization
    output          LCD_DEN,        // Display Enable (active area)

    // LCD Color Data Bus
    output  [4:0]   LCD_R,         // Red color channel   (5-bit)
    output  [5:0]   LCD_G,         // Green color channel (6-bit)
    output  [4:0]   LCD_B          // Blue color channel  (5-bit)
);

    // Clock System
    wire        CLK_SYS;           // 200MHz system clock from PLL
    wire        CLK_PIX;           // 33MHz pixel clock from PLL divider

    // PLL Instance - Generates system and pixel clocks
    // Input: 27MHz crystal
    // Output: 200MHz system clock, 33MHz pixel clock
    Gowin_rPLL chip_pll(
        .clkout(CLK_SYS),          // 200MHz output
        .clkoutd(CLK_PIX),         // 33MHz output (divided)
        .clkin(XTAL_IN)            // 27MHz input
    );

    // VGA Controller Instance
    // Generates display timing and RGB color patterns
    VGAMod	VGAMod_inst
    (
        // Clock and Reset
        .CLK        (   CLK_SYS     ),  // System clock input
        .nRST       (   nRST        ),  // Reset input
        .PixelClk   (   CLK_PIX     ),  // Pixel clock input

        // LCD Interface
        .LCD_DE     (   LCD_DEN     ),  // Display Enable output
        .LCD_HSYNC  (   LCD_HYNC    ),  // Horizontal sync output
        .LCD_VSYNC  (   LCD_SYNC    ),  // Vertical sync output

        // Color Output
        .LCD_B      (   LCD_B       ),  // Blue channel
        .LCD_G      (   LCD_G       ),  // Green channel
        .LCD_R      (   LCD_R       )   // Red channel
    );

    // Connect pixel clock to LCD clock output
    assign      LCD_CLK     =   CLK_PIX;

endmodule

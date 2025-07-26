module TOP
(
    input           nRST,           // Active low reset
    input           XTAL_IN,        // Input clock

    // LCD Interface signals
    output          LCD_CLK,        // LCD clock
    output          LCD_HYNC,       // Horizontal sync
    output          LCD_SYNC,       // Vertical sync
    output          LCD_DEN,        // Data enable

    // LCD RGB color signals
    output  [4:0]   LCD_R,         // Red channel   (5 bits)
    output  [5:0]   LCD_G,         // Green channel (6 bits)
    output  [4:0]   LCD_B          // Blue channel  (5 bits)
);

    // Internal clock signals
    wire        CLK_SYS;           // System clock (200MHz)
    wire        CLK_PIX;           // Pixel clock (33MHz)

    // PLL instance for clock generation
    Gowin_rPLL chip_pll(
        .clkout(CLK_SYS),          // 200MHz system clock output
        .clkoutd(CLK_PIX),         // 33MHz pixel clock output
        .clkin(XTAL_IN)            // Input clock
    );

    // VGA controller instance
    VGAMod	VGAMod_inst
    (
        .CLK        (   CLK_SYS     ),
        .nRST       (   nRST        ),
        .PixelClk   (   CLK_PIX     ),
        .LCD_DE     (   LCD_DEN     ),
        .LCD_HSYNC  (   LCD_HYNC    ),
        .LCD_VSYNC  (   LCD_SYNC    ),
        .LCD_B      (   LCD_B       ),
        .LCD_G      (   LCD_G       ),
        .LCD_R      (   LCD_R       )
    );

    // Connect pixel clock to LCD clock
    assign      LCD_CLK     =   CLK_PIX;

endmodule

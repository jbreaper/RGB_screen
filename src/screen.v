/*
 * VGA Controller Module
 * Resolution: 480x272 pixels
 * Features: 
 * - Generates sync signals for LCD
 * - Creates 8-color test pattern
 * - Handles display timing
 */
module VGAMod
(
    // Clock and Control
    input                   CLK,        // System clock (200MHz)
    input                   nRST,       // Active low reset
    input                   PixelClk,   // Pixel clock (33MHz)

    // LCD Control Signals
    output                  LCD_DE,     // Display Enable
    output                  LCD_HSYNC,  // Horizontal sync
    output                  LCD_VSYNC,  // Vertical sync

    // LCD Color Output
    output          [4:0]   LCD_B,     // Blue channel  (5-bit)
    output          [5:0]   LCD_G,     // Green channel (6-bit)
    output          [4:0]   LCD_R      // Red channel   (5-bit)
);

    // Horizontal Timing Parameters (in pixels)
    parameter       H_Pixel_Valid    = 16'd480;    // Active display width
    parameter       H_FrontPorch     = 16'd50;     // Front porch
    parameter       H_BackPorch      = 16'd30;     // Back porch
    parameter       PixelForHS       = H_Pixel_Valid + H_FrontPorch + H_BackPorch;

    // Vertical Timing Parameters (in lines)
    parameter       V_Pixel_Valid    = 16'd272;    // Active display height
    parameter       V_FrontPorch     = 16'd20;     // Front porch
    parameter       V_BackPorch      = 16'd5;      // Back porch
    parameter       PixelForVS       = V_Pixel_Valid + V_FrontPorch + V_BackPorch;

    // Pixel Counters
    reg         [15:0]  H_PixelCount;    // Horizontal pixel position
    reg         [15:0]  V_PixelCount;    // Vertical line position

    // Pixel Counter Logic
    always @(posedge PixelClk or negedge nRST) begin
        if (!nRST) begin
            // Reset counters
            V_PixelCount      <=  16'b0;    
            H_PixelCount      <=  16'b0;
        end
        else if (H_PixelCount == PixelForHS) begin
            // End of line reached
            V_PixelCount      <=  V_PixelCount + 1'b1;
            H_PixelCount      <=  16'b0;
        end
        else if (V_PixelCount == PixelForVS) begin
            // End of frame reached
            V_PixelCount      <=  16'b0;
            H_PixelCount      <=  16'b0;
        end
        else begin
            // Normal pixel increment
            V_PixelCount      <=  V_PixelCount;
            H_PixelCount      <=  H_PixelCount + 1'b1;
        end
    end

    // Generate Sync Signals
    assign  LCD_HSYNC = H_PixelCount <= (PixelForHS-H_FrontPorch) ? 1'b0 : 1'b1;
    assign  LCD_VSYNC = V_PixelCount <= (PixelForVS-0) ? 1'b0 : 1'b1;

    // Generate Display Enable
    assign  LCD_DE = (H_PixelCount >= H_BackPorch) && 
                     (H_PixelCount <= H_Pixel_Valid + H_BackPorch) &&
                     (V_PixelCount >= V_BackPorch) && 
                     (V_PixelCount <= V_Pixel_Valid + V_BackPorch);

    // Color Bar Pattern Generation
    localparam    Colorbar_width = H_Pixel_Valid / 16;    // Width of each color bar
    wire          display_active = LCD_DE;                 // Active display area
    wire [15:0]   active_pixel = H_PixelCount - H_BackPorch;  // Current pixel position

    // Generate Color Pattern
    // Format: {5-bit Red, 6-bit Green, 5-bit Blue}
    assign {LCD_R, LCD_G, LCD_B} = (!display_active) ? 16'b0 :
        (active_pixel < Colorbar_width * 2)  ? {5'h1F, 6'h00, 5'h00} : // Red
        (active_pixel < Colorbar_width * 4)  ? {5'h00, 6'h3F, 5'h00} : // Green
        (active_pixel < Colorbar_width * 6)  ? {5'h00, 6'h00, 5'h1F} : // Blue
        (active_pixel < Colorbar_width * 8)  ? {5'h1F, 6'h3F, 5'h00} : // Yellow
        (active_pixel < Colorbar_width * 10) ? {5'h1F, 6'h00, 5'h1F} : // Magenta
        (active_pixel < Colorbar_width * 12) ? {5'h00, 6'h3F, 5'h1F} : // Cyan
        (active_pixel < Colorbar_width * 14) ? {5'h1F, 6'h3F, 5'h1F} : // White
                                              {5'h10, 6'h20, 5'h10};    // Gray

endmodule

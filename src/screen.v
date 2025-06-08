module VGAMod
(
    input                   CLK,
    input                   nRST,

    input                   PixelClk,

    output                  LCD_DE,
    output                  LCD_HSYNC,
    output                  LCD_VSYNC,

    output          [4:0]   LCD_B,
    output          [5:0]   LCD_G,
    output          [4:0]   LCD_R
);


    localparam      H_BackPorch = 16'd43;
    localparam      H_Pluse     = 16'd1; 
    localparam      WidthPixel  = 16'd480;
    localparam      H_FrontPorch= 16'd4;

    localparam      V_BackPorch = 16'd12; //0 or 45
    localparam      V_Pluse     = 16'd5; 
    localparam      HightPixel  = 16'd272;
    localparam      V_FrontPorch= 16'd4; //45 or 0

    localparam      PixelForHS  =   WidthPixel + H_BackPorch + H_FrontPorch;
    localparam      LineForVS   =   HightPixel + V_BackPorch + V_FrontPorch;


    reg [15:0] LineCount;
    reg [15:0] PixelCount;

    reg [9:0]  Data_R;
    reg [9:0]  Data_G;
    reg [9:0]  Data_B;

    always @(  posedge PixelClk or negedge nRST  )begin
        if( !nRST ) begin
            LineCount       <=  16'b0;    
            PixelCount      <=  16'b0;
            end
        else if(  PixelCount  ==  PixelForHS ) begin
            PixelCount      <=  16'b0;
            LineCount       <=  LineCount + 1'b1;
            end
        else if(  LineCount  == LineForVS  ) begin
            LineCount       <=  16'b0;
            PixelCount      <=  16'b0;
            end
        else
            PixelCount      <=  PixelCount + 1'b1;
    end

    always @(  posedge PixelClk or negedge nRST  )begin
        if( !nRST ) begin
            Data_R <= 9'b0;
            Data_G <= 9'b0;
            Data_B <= 9'b0;
            end
        else begin
            end
    end

//Here note the negative polarity of HSYNC and VSYNC
assign  LCD_HSYNC = (( PixelCount >= H_Pluse)&&( PixelCount <= (PixelForHS-H_FrontPorch))) ? 1'b0 : 1'b1;
assign  LCD_VSYNC = ((( LineCount  >= V_Pluse)&&( LineCount  <= (LineForVS-0) )) ) ? 1'b0 : 1'b1;

assign  LCD_DE = (  ( PixelCount >= H_BackPorch )&&
                    ( PixelCount <= PixelForHS-H_FrontPorch ) &&
                    ( LineCount >= V_BackPorch ) &&
                    ( LineCount <= LineForVS-V_FrontPorch-1 ))  ? 1'b1 : 1'b0;
                    //It will shake if there not minus one

localparam          Colorbar_width   =   WidthPixel / 16;

assign  LCD_R     = ( PixelCount < ( H_BackPorch +  Colorbar_width * 0  )) ? 5'b00000 :
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 1  )) ? 5'b00001 : 
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 2  )) ? 5'b00010 :    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 3  )) ? 5'b00100 :    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 4  )) ? 5'b01000 :    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 5  )) ? 5'b10000 :  5'b00000;

assign  LCD_G    =  ( PixelCount < ( H_BackPorch +  Colorbar_width * 6  )) ? 6'b000001: 
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 7  )) ? 6'b000010:    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 8  )) ? 6'b000100:    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 9  )) ? 6'b001000:    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 10 )) ? 6'b010000:    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 11 )) ? 6'b100000:  6'b000000;

assign  LCD_B    =  ( PixelCount < ( H_BackPorch +  Colorbar_width * 12 )) ? 5'b00001 : 
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 13 )) ? 5'b00010 :    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 14 )) ? 5'b00100 :    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 15 )) ? 5'b01000 :    
                    ( PixelCount < ( H_BackPorch +  Colorbar_width * 16 )) ? 5'b10000 :  5'b00000;

endmodule

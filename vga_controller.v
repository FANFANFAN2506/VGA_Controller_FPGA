module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,left,right,up,down);

	
input iRST_n;
input iVGA_CLK;
input left,right,up,down;

output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [7:0] index_chosen;
wire index_signal;
wire [23:0] bgr_data_raw;
wire [24:0] sqr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
reg [9:0] x, y,addr_x,addr_y;

reg count; 
///
//
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
  begin
     ADDR<=19'd0;
	  addr_x<=10'b0;
	  addr_y<=10'b0;
  end
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     begin
		  ADDR<=ADDR+1;
		  addr_x=ADDR%640;
		  addr_y=ADDR/640;	  
	  end
end


////////
///register update
always@(posedge iVGA_CLK,negedge iRST_n)
begin
	if(!iRST_n)
		begin
			x<=10'b0;
			y<=10'b0;
			count <=0;
		end
	else
		begin
		if (count ==1000)begin
			count<= 0;
			//move right
			if(right) x<=x+1;
			//left
			else if(left)	x<=x-1;
			//move up
			else if(up)	y<=y-1;
			//move down
			else if(down) y<=y+1;
			else 
				begin
					x<=x;
					y<=y;
				end
		end
		else begin
		count<=count+1;
		x<=x;
		y<=y;
		end
	end
end
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
//////Add switch-input logic here

assign index_signal = (addr_x>x&&addr_x<x+20&&addr_y>y&&addr_y<y+20)?1:0;
assign index_chosen = index_signal?8'b00000010:index;//signal 0: background, signal 1: square
	
//////
img_index	img_index_inst (
	.address ( index_chosen ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////
	
//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////

//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule
 	
















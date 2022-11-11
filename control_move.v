module control_move(ps2,left,right,up,down);
	input [7:0] ps2;
	output reg left,right,up,down;
	
	always @(ps2)
	begin
	if(ps2==8'h6B) begin///left
		left <= 1'b1;
		right <= 1'b0;
		up <= 1'b0;
		down <= 1'b0;
	end
	else if(ps2==8'h74) begin//right
		left <= 1'b0;
		right <= 1'b1;
		up <= 1'b0;
		down <= 1'b0;
	end
	else if(ps2==8'h75) begin//up
		left <= 1'b0;
		right <= 1'b0;
		up <= 1'b1;
		down <= 1'b0;
	end
	else if(ps2==8'h72) begin//down
		left <= 1'b0;
		right <= 1'b0;
		up <= 1'b0;
		down <= 1'b1;
	end
	else begin //
		left <= 1'b0;
		right <= 1'b0;
		up <= 1'b0;
		down <= 1'b0;
	end
	end

endmodule

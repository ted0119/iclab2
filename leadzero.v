module leadzero #(parameter [8:0]WIDTH = 9'd8, parameter [8:0]WORD = 9'd4) (
	input wire CLK,
	input wire ivalid,
	input wire rst_n,
	input wire mode,
	input wire [WIDTH-1 :0]data,
	output reg ovalid,
	output reg [8:0]zero
);

parameter [1:0] IDLE=2'b00;
parameter [1:0] CALC=2'b01;
parameter [1:0] FINISH=2'b10;

reg [1:0] state,state_next;
reg [WIDTH+1:0] count,result,next_count,next_countword;
reg isturbo,next_stop,stop;
reg [WORD:0]countword;
reg [WORD:0]val8,val4,val16;
reg out;

reg hi;

always @(posedge CLK or negedge rst_n)
begin
	if(!rst_n) begin
		zero<=0;
		ovalid<=0;
		state <=IDLE;
		//next_count<=0;
		count<=0;
		countword<=0;
		result<=0;
		isturbo<=0;
		stop<=0;
		result<=0;
		
	end else begin
		state <=state_next;
		count<=next_count;
		countword<=next_countword;
		if(ivalid==0)begin
			isturbo<=0;
		end else begin
			isturbo<=mode;
end
		//stop<=next_stop;
		if(out==1)begin
			ovalid<=1;
			zero<=count;
		end else begin
			ovalid<=0;
			zero<=0;
		end
		stop<=next_stop;
	end
end

always @(*)
begin
	result=0;
	val8=0;
	val4=0;
	//if(next_stop==0)begin
		if(data==0)begin
			result=WIDTH;
			//next_stop=stop;
		end else begin
			if(WIDTH==4)begin
	    		result[1] = (data[3:2] == 2'b0);
	        	result[0] = result[1] ? ~data[1] : ~data[3];
	   		end else if (WIDTH==16)begin
    	    	result[3] = (data[15:8] == 8'b0);
	    		val8      = result[3] ? data[7:0] : data[15:8];
        		result[2] = (val8[7:4] == 4'b0);
        		val4      = result[2] ? val8[3:0] : val8[7:4];
        		result[1] = (val4[3:2] == 2'b0);
        		result[0] = result[1] ? ~val4[1] : ~val4[3];
    		end else begin
        		result[2] = (data[7:4] == 4'b0);
        		val4      = result[2] ? data[3:0] : data[7:4];
        		result[1] = (val4[3:2] == 2'b0);
        		result[0] = result[1] ? ~val4[1] : ~val4[3];
    		end
		end
		//next_stop=1;
	//end
	//next_count=count+result;
end

always @(*) begin
	case (state)
		IDLE: begin
			if((isturbo==1&&stop==1) || (countword==WORD))begin
				if(ivalid==1)begin
					next_countword=1;
					if(data==0)begin
						next_stop=0;
					end else begin
						next_stop=1;
					end          
					next_count=result;	
               	end else begin
					next_countword=0;
					next_stop=0;
					next_count=0;
               	end
				//next_count=count+result;
				out=1;
				//zero=count;	
			end else begin
				//zero=0;
				out=0;
				if(ivalid==1)begin
					next_countword=countword+1;
					if(data!=0)begin
						next_stop=1;
					end else begin
						next_stop=stop;
					end
					if(stop!=1)begin
						next_count=count+result;
					end else begin
						next_count=count;
					end
						
				end else begin
					next_countword=countword;
					next_stop=stop;
					next_count=count;
				end
				
			end

		
			state_next=IDLE;
		end
		
		default:begin
			
			state_next=IDLE;
		end
	endcase
end
endmodule

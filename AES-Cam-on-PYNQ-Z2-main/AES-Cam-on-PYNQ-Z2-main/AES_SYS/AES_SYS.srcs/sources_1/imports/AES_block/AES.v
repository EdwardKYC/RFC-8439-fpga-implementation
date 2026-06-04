`include "AddRoundKey.v"
`include "SubBytes.v"
`include "ShiftRows.v"
`include "MixColumns.v"
`include "InvSubBytes.v"
`include "InvShiftRows.v"
`include "InvMixColumns.v"
`include "KeyExpansion.v"

module AES(clk,nrst,start,enc_dec,data_in,key_in,key_gen_start, key_gen_Done ,data_out,addr, write_en, done);
input clk,nrst;
input start;
input key_gen_start;
input enc_dec;
input [31:0] data_in;
input [127:0] key_in;
output [31:0] addr;
output reg key_gen_Done;
output reg [31:0] data_out;
output reg [3:0] write_en;
output reg done;

reg [127:0] data_out_reg;

//state change
reg [2:0] state;
reg [2:0] next_state;

//state control
parameter 
IDLE=3'd0,
INPUT=3'd1,
KEY_GENERATION=3'd2,
WAIT_KEY_GEN_LOW = 3'd7,
ENCRYPTION=3'd3,
DECRYPTION=3'd4,
OUTPUT=3'd5,
DONE = 3'd6;

//key expansion counter
reg [3:0] key_expansion_counter;

//key expansion
reg [127:0] round_key_sel;
reg [31:0] round_constant;
wire [127:0] KeyExpansion_out;

//key reg
reg [127:0] key_reg [0:10];

//round counter
reg [3:0] round_counter;

/******encryption path******/

//AddRoundKey
reg [127:0] ENC_AddRoundKey_in;
reg [127:0] ENC_round_key;
wire [127:0] ENC_AddRoundKey_out;

//SubBytes
reg [127:0] ENC_SubBytes_in;
wire [127:0] ENC_SubBytes_out;

//ShiftRows
reg [127:0] ENC_ShiftRows_in;
wire [127:0] ENC_ShiftRows_out;

//MixColumns
reg [127:0] ENC_MixColumns_in;
wire [127:0] ENC_MixColumns_out;

/******decryption path******/

//AddRoundKey
reg [127:0] DEC_AddRoundKey_in;
reg [127:0] DEC_round_key;
wire [127:0] DEC_AddRoundKey_out;

//InvSubBytes
reg [127:0] DEC_InvSubBytes_in;
wire [127:0] DEC_InvSubBytes_out;

//InvShiftRows
reg [127:0] DEC_InvShiftRows_in;
wire [127:0] DEC_InvShiftRows_out;

//InvMixColumns
reg [127:0] DEC_InvMixColumns_in;
wire [127:0] DEC_InvMixColumns_out;

//data reg
reg [127:0] data_reg;

//cnt
reg [2:0] cnt;

reg [31:0] addr_in;
reg [31:0] addr_out;

//state change
always@(posedge clk or negedge nrst)
begin
	if(!nrst)
	begin
		state<=IDLE;
	end
	else
	begin
		state<=next_state;
	end
end

//state control
always@(*)
begin
	case(state)
	IDLE:
	begin
		if(key_gen_start == 1'd1) next_state = KEY_GENERATION;
		else if(start == 1'd1) next_state = INPUT;
		else next_state = IDLE;
	end
	INPUT:begin
		if(cnt == 3'd4 && enc_dec == 1'd0) next_state = ENCRYPTION; //ENCRYPTION
		else if(cnt == 3'd4 && enc_dec == 1'd1) next_state = DECRYPTION;
		else next_state = INPUT;
	end
	KEY_GENERATION:
	begin
		if(key_expansion_counter == 4'd9)
		begin
			next_state = WAIT_KEY_GEN_LOW;
		end
		else
		begin
			next_state=KEY_GENERATION;
		end
	end
	WAIT_KEY_GEN_LOW:begin
		if(key_gen_start == 1'd0) next_state = IDLE;
		else next_state = WAIT_KEY_GEN_LOW;
	end
	ENCRYPTION:
	begin
		if(round_counter==4'd10)
		begin
			next_state=OUTPUT;
		end
		else
		begin
			next_state=ENCRYPTION;
		end
	end
	DECRYPTION:
	begin
		if(round_counter==4'd10)
		begin
			next_state=OUTPUT;
		end
		else
		begin
			next_state=DECRYPTION;
		end
	end
	OUTPUT:begin
		if(cnt == 3'd3 && addr_out == 76799) next_state = DONE;
		else if(cnt == 3'd3) next_state = INPUT;
		else next_state = OUTPUT;
	end
	DONE:begin
		if(start) next_state = DONE;
		else next_state = IDLE;
	end
	endcase
end

always @(posedge clk or negedge nrst) begin //cnt
	if(!nrst) cnt <= 3'd0;
	else if (state == INPUT) begin
		if (cnt == 3'd4) cnt <= 3'd0;
		else cnt <= cnt + 3'd1;
	end else if(state == OUTPUT)begin
		if(cnt == 3'd3) cnt <= 3'd0;
		else cnt <= cnt + 3'd1;
	end 
end

assign addr = (state == INPUT) ? {addr_in,2'b0} : {addr_out, 2'b0};

always @(posedge clk or negedge nrst) begin //addr_in
	if(!nrst) addr_in <= 32'd0;
	else if(state == INPUT && cnt <= 3)begin
		addr_in <= addr_in + 32'd1;
	end else if(state == DONE)begin
		addr_in <= 32'd0;
	end
end

always @(posedge clk or negedge nrst) begin //addr_out
	if(!nrst) addr_out <= 32'd0;
	else if(state == OUTPUT)begin
		addr_out <= addr_out + 32'd1;
	end else if(state == DONE)begin
		addr_out <= 32'd0;
	end
end

always @(posedge clk or negedge nrst) begin //done
	if(!nrst) done <= 1'b0;
	else if(state == DONE)begin
		done <= 1'b1;
	end else begin
		done <= 1'b0;
	end
end

always @(posedge clk or negedge nrst) begin //key_gen_Done
	if(!nrst) key_gen_Done <= 1'b0;
	else if (state == KEY_GENERATION && key_expansion_counter == 4'd9) begin
		key_gen_Done <= 1'b1;
	end
end

always @(*) begin //write_en
	if(!nrst) begin
		write_en = 4'b0000;
	end else if(state == OUTPUT) begin
		write_en = 4'b1111;
	end else begin
		write_en = 4'b0000;
	end
end

always @(*)begin //data_out
	if(!nrst) data_out = 32'd0;
	else if(state == OUTPUT)begin
		case(cnt)
			3'd0: data_out = data_out_reg[31:0]; // Example data, replace with actual data
			3'd1: data_out = data_out_reg[63:32];
			3'd2: data_out = data_out_reg[95:64];
			3'd3: data_out = data_out_reg[127:96];
			default: data_out = 32'd0;
		endcase
	end else begin
		data_out = 32'd0;
	end
end

//key expansion counter
always@(posedge clk or negedge nrst)
begin
	if(!nrst)
	begin
		key_expansion_counter<=4'd0;
	end
	else
	begin
		case(state)
		KEY_GENERATION:
		begin
			if(key_expansion_counter==4'd9)
			begin
				key_expansion_counter<=4'd0;
			end
			else
			begin
				key_expansion_counter<=key_expansion_counter+4'd1;
			end
		end
		endcase
	end
end

//key expansion
KeyExpansion u_key_expansion(.key_in(round_key_sel),.round_constant(round_constant),.key_out(KeyExpansion_out));

always@(*)
begin
	case(key_expansion_counter)
	4'd0:
	begin
		round_key_sel=key_reg[0];
		round_constant={8'h01,8'h00,8'h00,8'h00};
	end
	4'd1:
	begin
		round_key_sel=key_reg[1];
		round_constant={8'h02,8'h00,8'h00,8'h00};
	end
	4'd2:
	begin
		round_key_sel=key_reg[2];
		round_constant={8'h04,8'h00,8'h00,8'h00};
	end
	4'd3:
	begin
		round_key_sel=key_reg[3];
		round_constant={8'h08,8'h00,8'h00,8'h00};
	end
	4'd4:
	begin
		round_key_sel=key_reg[4];
		round_constant={8'h10,8'h00,8'h00,8'h00};
	end
	4'd5:
	begin
		round_key_sel=key_reg[5];
		round_constant={8'h20,8'h00,8'h00,8'h00};
	end
	4'd6:
	begin
		round_key_sel=key_reg[6];
		round_constant={8'h40,8'h00,8'h00,8'h00};
	end
	4'd7:
	begin
		round_key_sel=key_reg[7];
		round_constant={8'h80,8'h00,8'h00,8'h00};
	end
	4'd8:
	begin
		round_key_sel=key_reg[8];
		round_constant={8'h1b,8'h00,8'h00,8'h00};
	end
	4'd9:
	begin
		round_key_sel=key_reg[9];
		round_constant={8'h36,8'h00,8'h00,8'h00};
	end
	default:
	begin
		round_key_sel=128'd0;
		round_constant={8'h00,8'h00,8'h00,8'h00};
	end
	endcase
end

//key reg
always@(posedge clk or negedge nrst)
begin
	if(!nrst)
	begin
		key_reg[0]<=128'd0;
		key_reg[1]<=128'd0;
		key_reg[2]<=128'd0;
		key_reg[3]<=128'd0;
		key_reg[4]<=128'd0;
		key_reg[5]<=128'd0;
		key_reg[6]<=128'd0;
		key_reg[7]<=128'd0;
		key_reg[8]<=128'd0;
		key_reg[9]<=128'd0;
	end
	else
	begin
		case(state)
		IDLE:
		begin
			key_reg[0]<=key_in;	
		end
		KEY_GENERATION:
		begin
			case(key_expansion_counter)
			4'd0:
			begin
				key_reg[1]<=KeyExpansion_out;
			end
			4'd1:
			begin
				key_reg[2]<=KeyExpansion_out;
			end
			4'd2:
			begin
				key_reg[3]<=KeyExpansion_out;
			end
			4'd3:
			begin
				key_reg[4]<=KeyExpansion_out;
			end
			4'd4:
			begin
				key_reg[5]<=KeyExpansion_out;
			end
			4'd5:
			begin
				key_reg[6]<=KeyExpansion_out;
			end
			4'd6:
			begin
				key_reg[7]<=KeyExpansion_out;
			end
			4'd7:
			begin
				key_reg[8]<=KeyExpansion_out;
			end
			4'd8:
			begin
				key_reg[9]<=KeyExpansion_out;
			end
			4'd9:
			begin
				key_reg[10]<=KeyExpansion_out;
			end
			endcase
		end
		endcase
	end
end

//round counter
always@(posedge clk or negedge nrst)
begin
	if(!nrst)
	begin
		round_counter<=4'd0;
	end
	else
	begin
		case(state)
		ENCRYPTION:
		begin
			if(round_counter==4'd10)
			begin
				round_counter<=4'd0;
			end
			else
			begin
				round_counter<=round_counter+4'd1;
			end
		end
		DECRYPTION:
		begin
			if(round_counter==4'd10)
			begin
				round_counter<=4'd0;
			end
			else
			begin
				round_counter<=round_counter+4'd1;
			end
		end
		endcase
	end
end

/******encryption path******/
AddRoundKey u_enc_AddRoundKey(.data_in(ENC_AddRoundKey_in),.key(ENC_round_key),.data_out(ENC_AddRoundKey_out));
SubBytes u_enc_SubBytes(.data_in(ENC_SubBytes_in),.data_out(ENC_SubBytes_out));
ShiftRows u_enc_ShiftRows(.data_in(ENC_ShiftRows_in),.data_out(ENC_ShiftRows_out));
MixColumns u_enc_MixColumns(.data_in(ENC_MixColumns_in),.data_out(ENC_MixColumns_out));

always@(*)
begin
	if(enc_dec==1'd0)
	begin
		case(round_counter)
		4'd0:
		begin
			ENC_AddRoundKey_in=data_reg;
			ENC_round_key=key_reg[0];
			ENC_SubBytes_in=128'd0;
			ENC_ShiftRows_in=128'd0;
			ENC_MixColumns_in=128'd0;
		end
		4'd10:
		begin
			ENC_SubBytes_in=data_reg;
			ENC_ShiftRows_in=ENC_SubBytes_out;
			ENC_MixColumns_in=128'd0;
			ENC_AddRoundKey_in=ENC_ShiftRows_out;
			ENC_round_key=key_reg[10];
		end
		default:
		begin
			ENC_SubBytes_in=data_reg;
			ENC_ShiftRows_in=ENC_SubBytes_out;
			ENC_MixColumns_in=ENC_ShiftRows_out;
			ENC_AddRoundKey_in=ENC_MixColumns_out;
			ENC_round_key=key_reg[round_counter];
		end
		endcase
	end
	else
	begin
		ENC_AddRoundKey_in=128'd0;
		ENC_round_key=128'd0;
		ENC_SubBytes_in=128'd0;
		ENC_ShiftRows_in=128'd0;
		ENC_MixColumns_in=128'd0;
	end
end

/******decryption path******/
AddRoundKey u_dec_AddRoundKey(.data_in(DEC_AddRoundKey_in),.key(DEC_round_key),.data_out(DEC_AddRoundKey_out));
InvSubBytes u_dec_InvSubBytes(.data_in(DEC_InvSubBytes_in),.data_out(DEC_InvSubBytes_out));
InvShiftRows u_dec_InvShiftRows(.data_in(DEC_InvShiftRows_in),.data_out(DEC_InvShiftRows_out));
InvMixColumns u_dec_InvMixColumns(.data_in(DEC_InvMixColumns_in),.data_out(DEC_InvMixColumns_out));

always@(*)
begin
	if(enc_dec==1'd1)
	begin
		case(round_counter)
		4'd0:
		begin
			DEC_AddRoundKey_in=data_reg;
			DEC_round_key=key_reg[10];
			DEC_InvSubBytes_in=128'd0;
			DEC_InvShiftRows_in=128'd0;
			DEC_InvMixColumns_in=128'd0;
		end
		4'd10:
		begin
			DEC_InvShiftRows_in=data_reg;
			DEC_InvSubBytes_in=DEC_InvShiftRows_out;
			DEC_AddRoundKey_in=DEC_InvSubBytes_out;
			DEC_round_key=key_reg[0];
			DEC_InvMixColumns_in=128'd0;
		end
		default:
		begin
			DEC_InvShiftRows_in=data_reg;
			DEC_InvSubBytes_in=DEC_InvShiftRows_out;
			DEC_AddRoundKey_in=DEC_InvSubBytes_out;
			DEC_round_key=key_reg[10-round_counter];
			DEC_InvMixColumns_in=DEC_AddRoundKey_out;
		end
		endcase
	end
	else
	begin
		DEC_AddRoundKey_in=128'd0;
		DEC_round_key=128'd0;
		DEC_InvSubBytes_in=128'd0;
		DEC_InvShiftRows_in=128'd0;
		DEC_InvMixColumns_in=128'd0;
	end
end

//data reg
always@(posedge clk or negedge nrst)
begin
	if(!nrst)
	begin
		data_reg<=128'd0;
	end
	else
	begin
		case(state)
		INPUT:
		begin
			case(cnt)
				3'd1: data_reg[31:0] <= data_in;
				3'd2: data_reg[63:32] <= data_in;
				3'd3: data_reg[95:64] <= data_in;
				3'd4: data_reg[127:96] <= data_in;
			endcase	
		end
		ENCRYPTION:
		begin
			data_reg<=ENC_AddRoundKey_out;
		end
		DECRYPTION:
		begin
			if(round_counter>=4'd1 && round_counter<=4'd9)
			begin
				data_reg<=DEC_InvMixColumns_out;
			end
			else
			begin
				data_reg<=DEC_AddRoundKey_out;
			end
		end
		endcase
	end
end

//data out
always@(posedge clk or negedge nrst)
begin
	if(!nrst)
	begin
		data_out_reg<=128'd0;
	end
	else
	begin
		if(round_counter==4'd10)
		begin
			if(enc_dec==1'd0)
			begin
				data_out_reg<=ENC_AddRoundKey_out;
			end
			else
			begin
				data_out_reg<=DEC_AddRoundKey_out;
			end
		end
	end
end

endmodule

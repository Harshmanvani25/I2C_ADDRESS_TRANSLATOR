module i2c_addr_translator (
  input clk,
  input reset,
  input scl,
  inout sda,
  output scl_s1,
  inout sda_s1,
  output scl_s2,
  inout sda_s2
);

localparam IDLE      = 3'b000;
localparam ADDR      = 3'b001;
localparam TRANS     = 3'b010;
localparam ACK       = 3'b011;
localparam WAIT      = 3'b100;
localparam DATA      = 3'b101;
localparam DATA_DONE = 3'b110;
localparam STOP      = 3'b111;

reg [2:0] state = IDLE, next_state = IDLE;
reg [7:0] addr_byte = 0;
reg [3:0] counter = 0;
reg slave_select;
reg rw_bit;

reg sda_out_en = 0;
reg sda_out_val = 1;


reg scl_prev = 1;
reg sda_prev = 1;
wire scl_rise = (scl & ~scl_prev);
wire scl_fall = (~scl & scl_prev);
wire start    = (scl & sda_prev & ~sda);
wire stop     = (scl & ~sda_prev & sda);

assign sda = sda_out_en ? sda_out_val : 1'bz;

assign scl_s1 = scl;
assign scl_s2 = scl;
assign sda_s1 = (rw_bit == 0 && slave_select == 0 && state == DATA) ? sda : 1'bz;
assign sda_s2 = (rw_bit == 0 && slave_select == 1 && state == DATA) ? sda : 1'bz;

always @(posedge clk or negedge reset) begin
  if (!reset) begin
    state <= IDLE;
    counter <= 0;
    slave_select <= 1'bz;
    rw_bit <= 0;
    scl_prev <= 1;
    sda_prev <= 1;
  end else begin
    scl_prev <= scl;
    sda_prev <= sda;
    state <= next_state;

    if ((state == ADDR || state == DATA) && scl_rise)
      counter <= counter + 1;
    else if (state != ADDR && state != DATA)
      counter <= 0;

    if (state == ADDR && counter < 8 && scl_rise)
      addr_byte <= {addr_byte[6:0], sda};

    if (state == ACK)
      rw_bit <= addr_byte[0];
  end
end

always @(*) begin
  sda_out_en = 0;
  sda_out_val = 1;
  next_state = state;

  case (state)
    IDLE: begin
      if (start) next_state = ADDR;
    end

    ADDR: begin
      if (scl_rise && counter == 7)
        next_state = TRANS;
    end

    TRANS: begin
      case (addr_byte[7:1])
        7'h48: slave_select = 0;
        7'h49: slave_select = 1;
        default: slave_select = 1'bz;
      endcase
      next_state = ACK;
    end

    ACK: begin
      sda_out_en = 1;
      sda_out_val = 0; // ACK after address
      if (scl_rise) next_state = WAIT;
    end

    WAIT: begin
      if (scl_fall) next_state = DATA;
    end

    DATA: begin
      if (counter == 8 && scl_fall)
        next_state = DATA_DONE;
    end

    DATA_DONE: begin

      if (stop) next_state = STOP;
    end

    STOP: begin
      next_state = IDLE;
    end
  endcase
end

endmodule

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
entity rs232_top is
    port ( reset     : in  std_logic;   -- low_level-active asynchronous reset
           clk       : in  std_logic;   -- system clock (20mhz), rising edge used
           data_in   : in  std_logic_vector(7 downto 0);  -- data to be sent
           valid_d   : in  std_logic;   -- handshake signal
                                         -- from guest system, low when data is valid
           ack_in    : out std_logic;   -- ack for data received, low once data
                                         -- has been stored
           tx_rdy    : out std_logic;   -- system ready to transmit
           td        : out std_logic;   -- rs232 transmission line
           rd        : in  std_logic;   -- rs232 reception line
           data_out  : out std_logic_vector(7 downto 0);  -- received data
           data_read : in  std_logic;   -- data read for guest system
           full      : out std_logic;   -- full internal memory
           empty     : out std_logic);  -- empty internal memory
end rs232_top;

architecture rtl of rs232_top is
 
  ------------------------------------------------------------------------
  -- components for transmitter block
  ------------------------------------------------------------------------

  component rs232_tx
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      start : in  std_logic;
      data  : in  std_logic_vector(7 downto 0);
      eot   : out std_logic;
      tx    : out std_logic);
  end component;

  ------------------------------------------------------------------------
  -- components for receiver block
  ------------------------------------------------------------------------

  component shiftregister
    port (
      reset  : in  std_logic;
      clk    : in  std_logic;
      enable : in  std_logic;
      d      : in  std_logic;
      q      : out std_logic_vector(7 downto 0));
  end component;

  component rs232_rx
    port (
      clk       : in  std_logic;
      reset     : in  std_logic;
      linerd_in : in  std_logic;
      valid_out : out std_logic;
      code_out  : out std_logic;
      store_out : out std_logic);
  end component;

  component fifo_generator_0
    port (
      clk   : in std_logic;
      srst  : in std_logic;
      din   : in std_logic_vector(7 downto 0);
      wr_en : in std_logic;
      rd_en : in std_logic;
      dout  : out std_logic_vector(7 downto 0);
      full  : out std_logic;
      empty : out std_logic);
  end component;

  ------------------------------------------------------------------------
  -- internal signals
  ------------------------------------------------------------------------

  signal data_ff    : std_logic_vector(7 downto 0);
  signal starttx    : std_logic;  -- start signal for transmitter
  signal linerd_in  : std_logic;  -- internal rx line
  signal valid_out  : std_logic;  -- valid bit @ receiver
  signal code_out   : std_logic;  -- bit @ receiver output
  signal sinit      : std_logic;  -- fifo reset
  signal fifo_in    : std_logic_vector(7 downto 0);
  signal fifo_write : std_logic;
  signal tx_rdy_i   : std_logic;
  -- signal clk        : std_logic;

begin  -- rtl

  transmitter: rs232_tx
    port map (
      clk   => clk,
      reset => reset,
      start => starttx,
      data  => data_ff,
      eot   => tx_rdy_i,
      tx    => td);

  receiver: rs232_rx
    port map (
      clk       => clk,
      reset     => reset,
      linerd_in => linerd_in,
      valid_out => valid_out,
      code_out  => code_out,
      store_out => fifo_write);

  shift: shiftregister
    port map (
      reset  => reset,
      clk    => clk,
      enable => valid_out,
      d      => code_out,
      q      => fifo_in);

  sinit <= not reset;
  
  internal_memory: fifo_generator_0
    port map (
      clk => clk,
      srst => sinit,
      din => fifo_in,
      wr_en => fifo_write,
      rd_en => data_read,
      dout => data_out,
      full => full,
      empty => empty
    );


  -- purpose: clocking process for input protocol
  clocking : process (clk, reset)
  begin
    if (reset = '0') then  -- asynchronous reset (active low)
      data_ff   <= (others => '0');
      linerd_in <= '1';
      ack_in    <= '1';
    elsif (clk'event and clk = '1') then  -- rising edge clock
      linerd_in <= rd;
      if (valid_d = '0' and tx_rdy_i = '1') then
        data_ff <= data_in;
        ack_in  <= '0';
        starttx <= '1';
      else
        ack_in  <= '1';
        starttx <= '0';
      end if;
    end if;
  end process;

  tx_rdy <= tx_rdy_i;

end rtl;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;


entity rs232_dma_ram is
  port ( 
    reset     : in  std_logic; -- asynchronous, active low
    clk       : in  std_logic; -- system clock, 20 mhz, rising_edge
    rs232_rx  : in  std_logic; -- rs232 rx line
    rs232_tx  : out std_logic; -- rs232 tx line
    dma_rq    : out std_logic; -- solicitud de los buses para recibir
    dma_ack   : in  std_logic; -- aceptaci�n para el dma_rq
    send_comm : in  std_logic; -- orden de env�o
    ready     : out std_logic; -- disponibilidad del dma para enviar
    switches  : out std_logic_vector(7 downto 0);
    temp_l    : out std_logic_vector(6 downto 0);
    temp_h    : out std_logic_vector(6 downto 0));
end rs232_dma_ram;

architecture behavioral of rs232_dma_ram is

-- components

  component dma is
    port ( 
        reset : in std_logic;
        clk : in std_logic;
        rcvd_data : in std_logic_vector (7 downto 0);
        rx_full : in std_logic;
        rx_empty : in std_logic;
        data_read : out std_logic;
        ack_out : in std_logic;
        tx_rdy : in std_logic;
        valid_d : out std_logic;
        tx_data : out std_logic_vector (7 downto 0);
        address : out std_logic_vector (7 downto 0);
        databus : inout std_logic_vector (7 downto 0);
        write_en : out std_logic;
        oe : out std_logic;
        dma_rq : out std_logic;
        dma_ack : in std_logic;
        send_comm : in std_logic;
        ready : out std_logic);
  end component;

  component ram is
    port ( 
        clk      : in    std_logic;
        reset    : in    std_logic;
        write_en : in    std_logic;
        oe       : in    std_logic;
        address  : in    std_logic_vector(7 downto 0);
        databus  : inout std_logic_vector(7 downto 0);
        switches : out   std_logic_vector(7 downto 0);
        temp_l   : out   std_logic_vector(6 downto 0);
        temp_h   : out   std_logic_vector(6 downto 0));
  end component;
    
  component rs232top is
    port (
        reset     : in  std_logic;   -- low_level-active asynchronous reset
        clk       : in  std_logic;   -- system clock (20mhz), rising edge used
        data_in   : in  std_logic_vector(7 downto 0);  -- data to be sent
        valid_d   : in  std_logic;   -- handshake signal from guest system, low when data is valid
        ack_in    : out std_logic;   -- ack for data received, low once data has been stored
        tx_rdy    : out std_logic;   -- system ready to transmit
        td        : out std_logic;   -- rs232 transmission line
        rd        : in  std_logic;   -- rs232 reception line
        data_out  : out std_logic_vector(7 downto 0);  -- received data
        data_read : in  std_logic;   -- data read for guest system
        full      : out std_logic;   -- full internal memory
        empty     : out std_logic);  -- empty internal memory
  end component;

-- signals

  signal rx_full, rx_empty, ack_out, tx_rdy : std_logic; -- in
  signal data_read, valid_d, write_en, oe : std_logic; -- out
  signal rcvd_data, databus, tx_data, address : std_logic_vector(7 downto 0);
  
  signal ack_in : std_logic;
  signal td, rd, full, empty : std_logic;
  signal data_out, data_in : std_logic_vector(7 downto 0);

begin -- rtl

  rs232_phy: rs232top
    port map (
      reset     => reset,
      clk       => clk,
      data_in   => tx_data,
      valid_d   => valid_d,
      ack_in    => ack_out,
      tx_rdy    => tx_rdy,
      td        => rs232_tx,
      rd        => rs232_rx,
      data_out  => rcvd_data,
      data_read => data_read,
      full      => rx_full,
      empty     => rx_empty);
      
  ram_inst : ram
    port map (
      clk      => clk,
      reset    => reset,
      write_en => write_en,
      oe       => oe,
      address  => address,
      databus  => databus,
      switches => switches,
      temp_l   => temp_l,
      temp_h   => temp_h);

  dma_inst : dma
    port map (
      reset     => reset,
      clk       => clk, 
      rcvd_data => rcvd_data,
      rx_full   => rx_full,
      rx_empty  => rx_empty,
      ack_out   => ack_out,
      tx_rdy    => tx_rdy,
      dma_ack   => dma_ack,
      send_comm => send_comm,
      data_read => data_read,
      valid_d   => valid_d,
      tx_data   => tx_data,
      address   => address,
      databus   => databus,
      write_en  => write_en,
      oe        => oe,
      dma_rq    => dma_rq,
      ready     => ready);


end behavioral;
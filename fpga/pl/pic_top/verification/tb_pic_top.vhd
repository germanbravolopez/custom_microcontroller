library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;
use work.rs232_test.all;

entity tb_pic_top is
end tb_pic_top;

architecture testbench of tb_pic_top is

  component pic_top
    port (
      reset     : in  std_logic;
      clk100mhz : in  std_logic;
      rs232_rx  : in  std_logic;
      rs232_tx  : out std_logic;
      switches  : out std_logic_vector(7 downto 0);
      temp      : out std_logic_vector(7 downto 0);
      disp      : out std_logic_vector(7 downto 0)
      );
  end component;

-----------------------------------------------------------------------------
-- internal signals
-----------------------------------------------------------------------------

  signal reset     : std_logic;
  signal clk100mhz : std_logic;
  signal rs232_rx  : std_logic;
  signal rs232_tx  : std_logic;
  signal switches  : std_logic_vector(7 downto 0);
  signal temp      : std_logic_vector(7 downto 0);
  signal disp      : std_logic_vector(7 downto 0);

begin  -- testbench

  uut: pic_top
    port map (
        reset     => reset,
        clk100mhz => clk100mhz,
        rs232_rx  => rs232_rx,
        rs232_tx  => rs232_tx,
        switches  => switches,
        temp      => temp,
        disp      => disp);

-----------------------------------------------------------------------------
-- reset & clock generator
-----------------------------------------------------------------------------

  reset <= '0', '1' after 75 ns;

  p_clk : process
  begin
     clk100mhz <= '1', '0' after 5 ns;
     wait for 10 ns;
  end process;

-------------------------------------------------------------------------------
-- sending some stuff through rs232 port
-------------------------------------------------------------------------------

  send_stuff : process
  begin
     rs232_rx <= '1';
     wait for 40 us;
--     transmit(rs232_rx, x"49"); -- poner un led encendido
--     transmit(rs232_rx, x"41"); -- activar un actuador
     transmit(rs232_rx, x"54"); -- cambiar temperatura
--     transmit(rs232_rx, x"53"); -- solicitar info

     wait for 40 us;
--     transmit(rs232_rx, x"34");
--     transmit(rs232_rx, x"35");
     transmit(rs232_rx, x"31");
--     transmit(rs232_rx, x"54");

     wait for 40 us;
--     transmit(rs232_rx, x"31");
--     transmit(rs232_rx, x"36");
     transmit(rs232_rx, x"38");
--     transmit(rs232_rx, x"37");

     wait;
  end process send_stuff;

end testbench;
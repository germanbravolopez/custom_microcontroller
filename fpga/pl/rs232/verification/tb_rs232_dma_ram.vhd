library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;
use work.tb_rs232_pkg.all;


entity tb_rs232_dma_ram is
end tb_rs232_dma_ram;

architecture testbench of tb_rs232_dma_ram is

  component rs232_dma_ram
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
  end component;

-----------------------------------------------------------------------------
-- internal signals
-----------------------------------------------------------------------------

  signal reset     : std_logic; 
  signal clk       : std_logic; 
  signal rs232_rx  : std_logic; 
  signal rs232_tx  : std_logic; 
  signal dma_rq    : std_logic; 
  signal dma_ack   : std_logic; 
  signal send_comm : std_logic; 
  signal ready     : std_logic; 
  signal switches  : std_logic_vector(7 downto 0);                        
  signal temp_l    : std_logic_vector(6 downto 0);                        
  signal temp_h    : std_logic_vector(6 downto 0);                       
  
begin -- testbench

  uut: rs232_dma_ram
    port map (
        reset     => reset,     
        clk       => clk,       
        rs232_rx  => rs232_rx,  
        rs232_tx  => rs232_tx, 
        dma_rq    => dma_rq,    
        dma_ack   => dma_ack,   
        send_comm => send_comm, 
        ready     => ready,     
        switches  => switches,  
        temp_l    => temp_l,    
        temp_h    => temp_h);    

-----------------------------------------------------------------------------
-- reset & clock generator
-----------------------------------------------------------------------------

reset <= '1', '0'after 75 ns, '1' after 1000 ns;

p_clk : process
  begin
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  end process;

test_main : process
    begin
        send_comm <= '0', '1' after 520us, '0' after 520.5us;
        dma_ack <= '0', '1' after 124.0us, '0' after 124.050us, 
                        '1' after 250.5us, '0' after 250.550us,
                        '1' after 377.5us, '0' after 377.550us;
        wait;
    end process;
    
test_rx : process
    begin
        rs232_rx <= '1';
        wait for 40 us;
        transmit(rs232_rx, x"49"); 
        wait for 40 us;
        transmit(rs232_rx, x"34");
        wait for 40 us;
        transmit(rs232_rx, x"31");
--        wait for 40 us;
--        transmit(rs232_rx, x"25");
        wait;
    end process;
        
end testbench;
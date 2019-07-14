library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

use work.PIC_pkg.all;
use work.RS232_test.all;


entity tb_RS232_DMA_RAM is
end tb_RS232_DMA_RAM;

architecture Testbench of tb_RS232_DMA_RAM is

  component RS232_DMA_RAM
    Port ( 
      Reset     : in  std_logic; -- Asynchronous, active low
      Clk       : in  std_logic; -- System clock, 20 MHz, rising_edge
      RS232_RX  : in  std_logic; -- RS232 RX line
      RS232_TX  : out std_logic; -- RS232 TX line
      DMA_RQ    : out STD_LOGIC; -- Solicitud de los buses para recibir
      DMA_ACK   : in  STD_LOGIC; -- Aceptación para el DMA_RQ
      Send_comm : in  STD_LOGIC; -- Orden de envío
      READY     : out STD_LOGIC; -- Disponibilidad del DMA para enviar
      Switches  : out std_logic_vector(7 downto 0);
      Temp_L    : out std_logic_vector(6 downto 0);
      Temp_H    : out std_logic_vector(6 downto 0));
  end component;

-----------------------------------------------------------------------------
-- Internal signals
-----------------------------------------------------------------------------

  signal Reset     : std_logic; 
  signal Clk       : std_logic; 
  signal RS232_RX  : std_logic; 
  signal RS232_TX  : std_logic; 
  signal DMA_RQ    : STD_LOGIC; 
  signal DMA_ACK   : STD_LOGIC; 
  signal Send_comm : STD_LOGIC; 
  signal READY     : STD_LOGIC; 
  signal Switches  : std_logic_vector(7 downto 0);                        
  signal Temp_L    : std_logic_vector(6 downto 0);                        
  signal Temp_H    : std_logic_vector(6 downto 0);                       
  
begin -- Testbench

  UUT: RS232_DMA_RAM
    port map (
        Reset     => Reset,     
        Clk       => Clk,       
        RS232_RX  => RS232_RX,  
        RS232_TX  => RS232_TX, 
        DMA_RQ    => DMA_RQ,    
        DMA_ACK   => DMA_ACK,   
        Send_comm => Send_comm, 
        READY     => READY,     
        Switches  => Switches,  
        Temp_L    => Temp_L,    
        Temp_H    => Temp_H);    

-----------------------------------------------------------------------------
-- Reset & clock generator
-----------------------------------------------------------------------------

Reset <= '1', '0'after 75 ns, '1' after 1000 ns;

p_clk : process
  begin
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  end process;

test_main : process
    begin
        Send_comm <= '0', '1' after 520us, '0' after 520.5us;
        DMA_ACK <= '0', '1' after 124.0us, '0' after 124.050us, 
                        '1' after 250.5us, '0' after 250.550us,
                        '1' after 377.5us, '0' after 377.550us;
        wait;
    end process;
    
test_rx : process
    begin
        RS232_RX <= '1';
        wait for 40 us;
        Transmit(RS232_RX, X"49"); 
        wait for 40 us;
        Transmit(RS232_RX, X"34");
        wait for 40 us;
        Transmit(RS232_RX, X"31");
--        wait for 40 us;
--        Transmit(RS232_RX, X"25");
        wait;
    end process;
        
end Testbench;
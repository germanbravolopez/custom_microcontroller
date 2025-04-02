library ieee;
use ieee.std_logic_1164.all;

package tb_rs232_pkg is

-------------------------------------------------------------------------------
-- procedure for sending one byte over the rs232 serial input
-------------------------------------------------------------------------------
      procedure transmit (
        signal   tx   : out std_logic;      -- serial line
        constant data : in  std_logic_vector(7 downto 0)); -- byte to be sent

end tb_rs232_pkg;

package body tb_rs232_pkg is

-----------------------------------------------------------------------------
-- procedure for sending one byte over the rs232 serial input
-----------------------------------------------------------------------------
           procedure transmit (
             signal   tx   : out std_logic;  -- serial output
             constant data : in  std_logic_vector(7 downto 0)) is
           begin

             tx <= '0';
             wait for 8680.6 ns;  -- about to send byte

             for i in 0 to 7 loop
               tx <= data(i);
               wait for 8680.6 ns;
             end loop;  -- i

             tx <= '1';
             wait for 8680.6 ns;

             tx <= '1';

           end transmit;

end tb_rs232_pkg;


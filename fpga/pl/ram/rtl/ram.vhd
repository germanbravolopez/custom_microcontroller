library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;

entity ram is
    port ( clk      : in    std_logic;
           reset    : in    std_logic;
           we_cpu   : in    std_logic;
           we_dma   : in    std_logic;
           oe_cpu   : in    std_logic;
           oe_dma   : in    std_logic;
           ram_specific_sal: out array8_ram(0 to 63);
           ram_generic_sal : out array8_ram(64 to 255);
           address  : in    std_logic_vector(7 downto 0);
           databus  : inout std_logic_vector(7 downto 0);
           switches : out   std_logic_vector(7 downto 0);
           temp_l   : out   std_logic_vector(6 downto 0);
           temp_h   : out   std_logic_vector(6 downto 0));
end ram;

architecture behavior of ram is

    signal ram_specific : array8_ram(0 to 63);
    signal ram_generic : array8_ram(64 to 255);
    signal chipset : std_logic;
  
begin

ram_generic_sal <= ram_generic;
ram_specific_sal <= ram_specific;

-- chipset = 1 para la segunda memoria.

p_chipset: process (reset, address)
    begin
        if (reset = '0') then
            chipset <= '0';
        elsif (address > "00111111") then
            chipset <= '1'; -- address mayor que 00111111 3f 63dec.
        else 
            chipset <= '0';
        end if;
    end process;

p_escritura: process (clk, reset, chipset, databus, we_cpu, we_dma) 
    begin
        if (reset = '0') then
            for i in 0 to 63 loop
                ram_specific(i) <= (others => '0');
            end loop;
            ram_specific(49) <= "00100000"; -- la posicion 49 decimal es la x"31" (en hex). 20 grados
        elsif (clk'event and clk = '1') then
            if (we_cpu = '1' or we_dma = '1') then
                if (chipset = '0') then
                    ram_specific(to_integer(unsigned(address))) <= databus;
                elsif (chipset = '1') then     
                    ram_generic(to_integer(unsigned(address))) <= databus;
                end if;
            end if;
        end if;
    end process;

p_lectura: process (clk, reset, address, chipset, oe_cpu, oe_dma) -- la memoria tiene que ser s�ncrona 
    begin                                    -- para que xilinx lo sintetice en los bloques reservados
        if (reset = '0') then
            databus <= (others => 'z');
        elsif (clk'event and clk = '1') then
            if (oe_cpu = '0' or oe_dma = '0') then
                if (chipset = '0') then
                    databus <= ram_specific(to_integer(unsigned(address)));
                elsif (chipset = '1') then
                    databus <= ram_generic(to_integer(unsigned(address)));
                end if;
            else
                databus <= (others => 'z');
            end if;
        end if;
    end process;

-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- decodificador de bcd a 7 segmentos
-------------------------------------------------------------------------
with ram_specific(49)(7 downto 4) select
temp_h <=
    "1000000" when "0000",  -- 0
    "1111001" when "0001",  -- 1
    "0100100" when "0010",  -- 2
    "0110000" when "0011",  -- 3
    "0011001" when "0100",  -- 4
    "0010010" when "0101",  -- 5
    "0000010" when "0110",  -- 6
    "1111000" when "0111",  -- 7
    "0000000" when "1000",  -- 8
    "0010000" when "1001",  -- 9
    "0000110" when others;  -- e de que hay error  

    
with ram_specific(49)(3 downto 0) select
    temp_l <=
        "1000000" when "0000",  -- 0
        "1111001" when "0001",  -- 1
        "0100100" when "0010",  -- 2
        "0110000" when "0011",  -- 3
        "0011001" when "0100",  -- 4
        "0010010" when "0101",  -- 5
        "0000010" when "0110",  -- 6
        "1111000" when "0111",  -- 7
        "0000000" when "1000",  -- 8
        "0010000" when "1001",  -- 9
        "0000110" when others;  -- e


-----------------------------------------------------------------------

-------------------------------------------------------------------------
-- salidas de los switches
-------------------------------------------------------------------------
-- seleccionamos el lsb de cada byte de la direccion correspondiente a los switches.

switches <= ram_specific(23)(0 downto 0) &
            ram_specific(22)(0 downto 0) &
            ram_specific(21)(0 downto 0) &
            ram_specific(20)(0 downto 0) &
            ram_specific(19)(0 downto 0) &
            ram_specific(18)(0 downto 0) &
            ram_specific(17)(0 downto 0) &
            ram_specific(16)(0 downto 0);

end behavior;


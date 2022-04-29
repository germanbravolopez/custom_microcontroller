library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register is
    port ( reset  : in std_logic;
           clk    : in std_logic;
           enable : in std_logic;
           d      : in std_logic;
           q      : out std_logic_vector (7 downto 0));
end shift_register;

architecture behavioral of shift_register is

begin

reg_proc: process (reset, clk)
    variable q_int  : unsigned(7 downto 0); -- las variables se actualizan inmediatamente
    
    begin
        if (reset = '0') then
            q_int := (others => '0');
        elsif (clk'event and clk = '1') then
            if (enable = '1') then
                q_int := shift_right((q_int),1);
                q_int := d & q_int(6 downto 0);
            end if;
        end if;
        q <= std_logic_vector(q_int);
    end process;

end behavioral;
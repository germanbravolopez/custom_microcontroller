----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.09.2018 17:47:36
-- Design Name: 
-- Module Name: ShiftRegister - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity ShiftRegister is
    Port ( Reset  : in STD_LOGIC;
           Clk    : in STD_LOGIC;
           Enable : in STD_LOGIC;
           D      : in STD_LOGIC;
           Q      : out STD_LOGIC_VECTOR (7 downto 0));
end ShiftRegister;

architecture Behavioral of ShiftRegister is

begin

reg_proc: process (Reset, Clk)
    variable q_int  : unsigned(7 downto 0); -- Las variables se actualizan inmediatamente
    
    begin
        if (Reset = '0') then
            q_int := (others => '0');
        elsif (Clk'event and Clk = '1') then
            if (Enable = '1') then
                q_int := shift_right((q_int),1);
                q_int := D & q_int(6 downto 0);
            end if;
        end if;
        Q <= std_logic_vector(q_int);
    end process;

end Behavioral;
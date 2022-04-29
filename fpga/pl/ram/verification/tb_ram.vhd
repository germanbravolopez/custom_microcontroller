library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;

entity tb_ram is
--  port ( );
end tb_ram;

architecture testbench of tb_ram is
    component ram
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
    
    signal clk, reset, write_en, oe : std_logic;
    signal address : std_logic_vector(7 downto 0);
    signal databus, switches : std_logic_vector(7 downto 0);
    signal temp_l, temp_h : std_logic_vector(6 downto 0); 
    
begin

    uut: ram
        port map(
        clk       =>  clk,        
        reset     =>  reset,   
        write_en  =>  write_en,
        oe        =>  oe,      
        address   =>  address, 
        databus   =>  databus, 
        switches  =>  switches,
        temp_l    =>  temp_l,  
        temp_h    =>  temp_h);

    p_clk: process
        begin
            clk <= '1', '0' after 25 ns;
            wait for 50 ns;
        end process;
    
    test: process
        begin
            reset <= '0'; wait for 200 ns;
            reset <= '1'; oe <= '1';
            address <= switch_base;
            databus <= "00000001";
            write_en <= '1'; wait for 50 ns;
            
            address <= std_logic_vector(unsigned(switch_base) + to_unsigned(7, 8));
            databus <= "00000001";
            write_en <= '1'; wait for 50 ns;
            
            address <= t_stat;
            databus <= "00100011";
            write_en <= '1'; wait for 50 ns;
            
            write_en <= '0';
            databus <= (others => 'z'); wait for 50 ns; -- hay que escribir zz en el bus durante un clock cycle para que sepa
                                                        -- que hay cambio escr -> lect
            
            address <= t_stat;            
            oe <= '0';
     
            wait;
            
        end process;

end testbench;

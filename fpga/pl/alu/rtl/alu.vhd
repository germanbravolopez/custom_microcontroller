library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pic_pkg.all;

entity alu is
    port ( reset       : in std_logic; -- asynnchronous, active low
           clk         : in std_logic; -- sys clock, 20mhz, rising_edge
           command_alu : in alu_op; -- command instruction from cpu
           flagz       : out std_logic; -- zero flag
           flagc       : out std_logic; -- carry flag
           flagn       : out std_logic; -- nibble carry bit
           flage       : out std_logic; -- error flag
           index_reg   : out std_logic_vector(7 downto 0);   -- index register
           databus     : inout std_logic_vector(7 downto 0)); -- system data bus
end alu;

architecture behavioral of alu is
    
    signal a, b, acc, index : unsigned(7 downto 0);  
      
begin

index_reg <= std_logic_vector(index);

alu_process: process(clk, reset, command_alu, databus, a, acc) 

    variable acc_internal : unsigned (8 downto 0);
    
    begin
        if(reset = '0') then
            flagz <= '0';
            flagc <= '0';
            flagn <= '0';
            flage <= '0';
            databus <= (others => 'z');
            a <= (others => '0');
            b <= (others => '0');
            acc <= (others => '0');
            index <= (others => '0');
            
        elsif (clk'event and clk = '1') then
            case (command_alu) is
                when nop =>      
                    flagc <= '0';
                    flagn <= '0';
                    flage <= '0';
                    databus <= (others => 'z');
                when op_lda =>   
                    a <= unsigned(databus);
                when op_ldb =>   
                    b <= unsigned(databus);    
                when op_ldacc => 
                    acc <= unsigned(databus);
                when op_ldid =>  
                    index <= unsigned(databus);
                when op_mvacc2id =>
                    index <= acc;
                when op_mvacc2a =>
                    a <= acc;
                when op_mvacc2b =>
                    b <= acc;
                when op_add =>
                    acc_internal := ('0' & a) + ('0' & b);
                    acc <= acc_internal(7 downto 0);
                    
                    if (acc_internal = "000000000") then
                        flagz <= '1';
                    else
                        flagz <= '0';
                    end if;
                    
                    flagc <= acc_internal(8);
                    
                    if (acc_internal > "000001111") then -- acc >= 16 : acarreo entre nibbles
                        flagn <= '1';
                    else 
                        flagn <= '0';
                    end if;
                    
                when op_sub =>
                    acc_internal := ('0' & a) - ('0' & b);
                    acc <= acc_internal(7 downto 0);
                    
                    if (acc_internal = "000000000") then
                        flagz <= '1';
                    else
                        flagz <= '0';
                    end if;
                    
                    flagc <= acc_internal(8);
                    
                    if (acc_internal > "000001111") then   
                        flagn <= '1';                      
                    else                                   
                        flagn <= '0';                      
                    end if;   
                    
                when op_shiftl =>
                    acc <= acc(6 downto 0) & '0';
                when op_shiftr =>
                    acc <= '0' & acc(7 downto 1);
                when op_and =>
                    acc_internal := ('0' & a) and ('0' & b);
                    acc <= acc_internal(7 downto 0);
                    if (acc_internal = "000000000") then
                        flagz <= '1';
                    else
                        flagz <= '0';
                    end if;
                    
                when op_or =>
                    acc_internal := ('0' & a) or ('0' & b);
                    acc <= acc_internal(7 downto 0);
                    if (acc_internal = "000000000") then
                        flagz <= '1';
                    else
                        flagz <= '0';
                    end if;
                    
                when op_xor =>
                    acc_internal := ('0' & a) xor ('0' & b);
                    acc <= acc_internal(7 downto 0);
                    if (acc_internal = "000000000") then
                        flagz <= '1';
                    else
                        flagz <= '0';
                    end if;
                    
                when op_cmpe =>            
                    if (a = b) then
                        flagz <= '1';
                    else       
                        flagz <= '0';
                    end if;
                    
                when op_cmpg =>                  
                    if (a > b) then  
                        flagz <= '1';
                    else             
                        flagz <= '0';
                    end if;  
                    
                when op_cmpl =>                  
                    if (a < b) then  
                        flagz <= '1';
                    else             
                        flagz <= '0';
                    end if;  
                    
                when op_ascii2bin =>
                    acc <= a - to_unsigned(48, 8); -- se resta un 48 decimal que es un 30 en hexadecimal
                    flage <= '0';
                    
                when op_bin2ascii =>
                    acc <= a + to_unsigned(48, 8);                             
                    flage <= '0';                                            
                    
                when op_oeacc =>
                    databus <= std_logic_vector(acc);
            end case;
        end if;
    end process;
      
end behavioral;

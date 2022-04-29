library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rs232_rx is
    port ( reset     : in std_logic;
           clk       : in std_logic;
           linerd_in : in std_logic;
           valid_out : out std_logic;
           code_out  : out std_logic;
           store_out : out std_logic);
end rs232_rx;

architecture behavioral of rs232_rx is

    type state is (idle, startbit, rcvdata, stopbit);
    
    signal currentstate, nextstate                  : state;
    signal flagdatacount, flagbitwidth, flaghalfbit : std_logic;
    signal bitwidth                                 : unsigned (7 downto 0);
    signal halfbitwidth                             : unsigned (6 downto 0);
    signal datacount                                : unsigned(2 downto 0);
    constant pulseendofcount                        : integer := 174;

begin

next_process: process (currentstate, linerd_in, flagbitwidth, flagdatacount)
    begin
        case currentstate is
            when idle =>
                if (linerd_in = '0') then
                    nextstate <= startbit;
                else
                    nextstate <= idle;
                end if;
            when startbit =>
                if (flagbitwidth = '1') then
                    nextstate <= rcvdata;
                else
                    nextstate <= startbit;
                end if;
            when rcvdata =>
                if (flagdatacount = '1') then
                    nextstate <= stopbit;
                else
                    nextstate <= rcvdata;
                end if;
             when stopbit =>
                if (flagbitwidth = '1') then
                    nextstate <= idle;
                else
                    nextstate <= stopbit;
                end if;
        end case;
    end process;

ffs: process (reset, clk) 
    begin
        if (reset = '0') then
            currentstate <= idle;
        elsif (clk'event and clk = '1') then
            currentstate <= nextstate;
        end if;
    end process;
   
outputs: process (currentstate, datacount, flaghalfbit, linerd_in) 
    begin
        case currentstate is
            when idle =>
                valid_out <= '0';
                code_out  <= '0';
                store_out <= '0';
            when startbit =>
                valid_out <= '0';
                code_out  <= '0';
                store_out <= '0';
            when rcvdata =>
                if (flaghalfbit = '1') then
                    valid_out <= '1';
                    code_out <= linerd_in;
                else
                    valid_out <= '0';
                    code_out  <= '0';
                end if;
                store_out <= '0';
            when stopbit =>
                valid_out <= '0';
                code_out  <= '0';
                if (flaghalfbit = '1' and linerd_in = '1') then 
                    store_out <= '1';
                else
                    store_out <= '0';
                end if;
         end case;
    end process;

bitwidth_halfwidth_counter: process (clk, reset, currentstate, linerd_in)
    begin
        if (reset = '0' or currentstate = idle) then
            bitwidth <= (others => '0');
            halfbitwidth <= (others => '0');
            flagbitwidth <= '0';
            flaghalfbit <= '0';
        elsif (clk'event and clk = '1') then
            bitwidth <= bitwidth + to_unsigned(1,8);
            halfbitwidth <= halfbitwidth + to_unsigned(1,7);
            if (bitwidth = pulseendofcount) then 
                bitwidth <= (others => '0');
                halfbitwidth <= (others => '0');
                flagbitwidth <= '1';
                flaghalfbit <= '0';
            else 
                flagbitwidth <= '0';
            end if;
            if (halfbitwidth = 87) then
                flaghalfbit <= '1';
            else
                flaghalfbit <= '0';
            end if;
        end if;
    end process;
 
datacounter: process (clk, reset, currentstate, flagbitwidth)
    begin
        if (reset = '0' or currentstate = startbit) then
            datacount <= (others => '0');
            flagdatacount <= '0';
        elsif (clk'event and clk='1') then
            if (currentstate = rcvdata and (flagbitwidth = '1')) then  
                datacount <= datacount + to_unsigned(1,3);
                if (datacount = 7) then
                    datacount <= (others => '0');
                    flagdatacount <= '1';
                else
                    flagdatacount <= '0';
                end if;
            end if;
        end if;
    end process;
    
end behavioral;
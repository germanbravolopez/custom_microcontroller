library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rs232_tx is
    port ( reset : in std_logic;
           clk   : in std_logic;
           start : in std_logic;
           data  : in std_logic_vector (7 downto 0);
           eot   : out std_logic;
           tx    : out std_logic);
end rs232_tx;

architecture behavioral of rs232_tx is

    type state is (idle, startbit, senddata, stopbit);

    signal currentstate, nextstate     : state;
    signal flagbitwidth, flagdatacount : std_logic;
    signal bitwidth                    : unsigned (7 downto 0);
    signal datacount                   : unsigned(2 downto 0);
    constant pulseendofcount           : integer := 174;  -- 173,611 ciclos por bit

begin

next_process: process (currentstate, start, flagbitwidth, flagdatacount, data)
    begin
        case currentstate is
            when idle =>
                if (start = '1') then
                    nextstate <= startbit;
                else
                    nextstate <= idle;
                end if;
            when startbit =>
                if (flagbitwidth = '1') then
                    nextstate <= senddata;
                else
                    nextstate <= startbit;
                end if;
            when senddata =>
                if (flagdatacount = '1') then
                    nextstate <= stopbit;
                else
                    nextstate <= senddata;
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

outputs: process (currentstate, datacount, data, flagdatacount)
    begin
        case currentstate is
            when idle =>
                eot <= '1';
                tx  <= '1';
            when startbit =>
                eot <= '0';
                tx  <= '0';
            when senddata =>
                eot <= '0';
                tx  <= data(to_integer(datacount));
                if (flagdatacount = '1') then
                    tx <= data(7);
                end if;
            when stopbit =>
                eot <= '0';
                tx  <= '1';
        end case;
    end process;

bitwidth_counter: process (clk, reset, currentstate)
    begin
        if (reset = '0' or currentstate = idle) then
            bitwidth <= (others => '0');
            flagbitwidth <= '0';
        elsif (clk'event and clk='1') then
            bitwidth <= bitwidth + to_unsigned(1, 8);
            if (bitwidth = pulseendofcount) then
                bitwidth <= (others => '0');
                flagbitwidth <= '1';
            else
                flagbitwidth <= '0';
            end if;
        end if;
    end process;

datacounter: process (clk, reset, currentstate, flagbitwidth)
    begin
        if (reset = '0' or currentstate = startbit) then
            datacount <= (others => '0');
            flagdatacount <= '0';
        elsif (clk'event and clk = '1') then
            if (currentstate = senddata and flagbitwidth = '1') then
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
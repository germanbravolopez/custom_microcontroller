library ieee;
use ieee.std_logic_1164.all;

entity tb_dma is
end tb_dma;

architecture testbench of tb_dma is

component dma is
    port ( 
        reset : in std_logic;
        clk : in std_logic;
        rcvd_data : in std_logic_vector (7 downto 0);
        rx_full : in std_logic;
        rx_empty : in std_logic;
        data_read : out std_logic;
        ack_out : in std_logic;
        tx_rdy : in std_logic;
        valid_d : out std_logic;
        tx_data : out std_logic_vector (7 downto 0);
        address : out std_logic_vector (7 downto 0);
        databus : inout std_logic_vector (7 downto 0);
        write_en : out std_logic;
        oe : out std_logic;
        dma_rq : out std_logic;
        dma_ack : in std_logic;
        send_comm : in std_logic;
        ready : out std_logic);
    end component;
    
  signal clk, reset : std_logic := '0';
  constant half_period100 : time := 5 ns;
  
  signal rx_full, rx_empty, ack_out, tx_rdy, dma_ack, send_comm: std_logic; -- in
  signal data_read, valid_d, write_en, oe, dma_rq, ready: std_logic; -- out
  signal rcvd_data, databus, tx_data, address : std_logic_vector(7 downto 0);

begin
    
    clk <= not clk after half_period100;
    reset <= '1' after 0.1 ns;
    
      uut: dma
        port map (
            reset => reset,
            clk => clk,
            rcvd_data => rcvd_data,
            rx_full => rx_full,
            rx_empty => rx_empty,
            data_read => data_read,
            ack_out => ack_out,
            tx_rdy => tx_rdy,
            valid_d => valid_d,
            tx_data => tx_data,
            address => address,
            databus => databus,
            write_en => write_en,
            oe => oe,
            dma_rq => dma_rq,
            dma_ack => dma_ack,
            send_comm => send_comm,
            ready => ready);
    
    process
    begin 
        dma_ack <= '0';
        address <= (others=>'z');
        databus <= (others=>'z');
        rx_empty <= '1';
        rcvd_data <= (others => '0');
        
        rx_empty <= '0' after 2us, '1' after 2.005us, '0' after 3.995us, '1' after 4.005us, '0' after 5.995us, '1' after 6.005us;
        dma_ack <= '1' after 2.015us, '0' after 2.050us, '1' after 4.010us, '0' after 4.050us, '1' after 6.010us, '0' after 6.050us;
        rcvd_data <= "00110000" after 2.005us, "01000000" after 4.005us, "01010000" after 6.005us;

        ack_out <= '0';
        send_comm <= '0'; 
        tx_rdy <= '1', '0' after 11.035us, '1' after 11.045us, '0' after 11.055us, '1' after 11.085us, '0' after 11.095us;
        send_comm <= '1' after 10.995us, '0' after 11.105us;
        databus <= "00100010" after 11.015us, (others=>'z') after 11.035us, "01100110" after 11.055us, (others=>'z') after 11.075us;
        ack_out <= '1', '0' after 11.025us, '1' after 11.035us, '0' after 11.085us, '1' after 11.095us;
        wait;
    end process;

end testbench;

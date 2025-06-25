library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_tb is
end MIPS_tb;

architecture test of MIPS_tb is

    -- Component declaration of the DUT
    component MIPSPipeline
        Port (
            led  : out STD_LOGIC_VECTOR(15 downto 0);
            sw   : in  STD_LOGIC_VECTOR(15 downto 0);
            an   : out STD_LOGIC_VECTOR(7 downto 0);
            cat  : out STD_LOGIC_VECTOR(6 downto 0);
            btn  : in  STD_LOGIC_VECTOR(3 downto 0);
            clk  : in  STD_LOGIC
        );
    end component;

    -- Signals
    signal clk_tb  : STD_LOGIC := '0';
    signal btn_tb  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal sw_tb   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal led_tb  : STD_LOGIC_VECTOR(15 downto 0);
    signal an_tb   : STD_LOGIC_VECTOR(7 downto 0);
    signal cat_tb  : STD_LOGIC_VECTOR(6 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- DUT instance
    DUT: MIPSPipeline
        port map (
            clk => clk_tb,
            btn => btn_tb,
            sw  => sw_tb,
            led => led_tb,
            an  => an_tb,
            cat => cat_tb
        );

    -- Clock generation
    rst_process : process
    begin
        btn_tb(1) <= '1';
        wait for 1000 ns;
        btn_tb(1) <= '0';
        wait;
    end process;
    clk_process : process
    begin
        while now < 2 ms loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    en_process: process
    begin
        btn_tb(0) <= '0';
        wait for clk_period;
        btn_tb(0) <= '1';
        wait for clk_period;
    end process;    
end test;

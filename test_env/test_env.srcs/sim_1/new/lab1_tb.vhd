----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2025 11:29:35 AM
-- Design Name: 
-- Module Name: lab1_tb - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab1_tb is
--  Port ( );
end lab1_tb;

architecture Behavioral of lab1_tb is
component Lab1 is
  Port ( led : out STD_LOGIC_VECTOR(15 downto 0);
         sw : in STD_LOGIC_VECTOR(15 downto 0);
         an : out STD_LOGIC_VECTOR(7 downto 0);
         cat : out STD_LOGIC_VECTOR(6 downto 0);
         btn : in STD_LOGIC_VECTOR(3 downto 0);
         clk : in STD_LOGIC
    );
end component;
signal clk_tb : STD_LOGIC := '0';
signal led_tb : STD_LOGIC_VECTOR(15 downto 0);
signal sw_tb : STD_LOGIC_VECTOR(15 downto 0);
signal an_tb : STD_LOGIC_VECTOR(7 downto 0);
signal cat_tb : STD_LOGIC_VECTOR(6 downto 0);
signal btn_tb : STD_LOGIC_VECTOR(3 downto 0);

begin

simulare_clock: process
begin
    clk_tb <= not clk_tb;
    wait for 10 ns;
end process;

simulare_lab1 : process
begin
    sw_tb(0) <= '1';
    btn_tb(0) <= '1';
    wait for 1000 us;
    btn_tb(0) <= '0';
    wait for 10000 us;
    btn_tb(0) <= '1';
    wait for 1000 us;
    btn_tb(0) <= '0';
    wait;

end process;

portmap: Lab1 port map(led_tb, sw_tb, an_tb, cat_tb, btn_tb, clk_tb);

end Behavioral;

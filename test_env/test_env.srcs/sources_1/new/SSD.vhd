
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
  Port ( 
    clk : in STD_LOGIC;
    digits : in STD_LOGIC_VECTOR(31 downto 0);
    an : out STD_LOGIC_VECTOR(7 downto 0);
    cat : out STD_LOGIC_VECTOR(6 downto 0)
  );
end SSD;

architecture Behavioral of SSD is
signal cnt_out : STD_LOGIC_VECTOR(16 downto 0) := (others => '0');
signal hex_mux_out : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal an_aux : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin

an <= an_aux;

counter_process: process(clk)
begin
    if rising_edge(clk) then
        cnt_out <= cnt_out + 1;
    end if;
end process;

hex_mux: process(clk)
begin
    if rising_edge(clk) then
        case cnt_out(16 downto 14) is
            when "000" 
            => hex_mux_out <= digits(3 downto 0);
            when "001" => hex_mux_out <= digits(7 downto 4);
            when "010" => hex_mux_out <= digits(11 downto 8);
            when "011" => hex_mux_out <= digits(15 downto 12);
            when "100" => hex_mux_out <= digits(19 downto 16);
            when "101" => hex_mux_out <= digits(23 downto 20);
            when "110" => hex_mux_out <= digits(27 downto 24);
            when "111" => hex_mux_out <= digits(31 downto 28);
            when others => hex_mux_out <= "0000";
        end case;
    end if;
end process;

anode_mux : process(clk)
begin
    if rising_edge(clk) then
        case cnt_out(16 downto 14) is 
            when "000" => an_aux <= "11111110";
            when "001" => an_aux <= "11111101";
            when "010" => an_aux <= "11111011";
            when "011" => an_aux <= "11110111";
            when "100" => an_aux <= "11101111";
            when "101" => an_aux <= "11011111";
            when "110" => an_aux <= "10111111";
            when "111" => an_aux <= "01111111";
            when others => an_aux <= "11111111";
        end case;
    end if;

end process;

catode_assignation: with hex_mux_out SELect
   cat<= "1111001" when "0001",   --1
         "0100100" when "0010",   --2
         "0110000" when "0011",   --3
         "0011001" when "0100",   --4
         "0010010" when "0101",   --5
         "0000010" when "0110",   --6
         "1111000" when "0111",   --7
         "0000000" when "1000",   --8
         "0010000" when "1001",   --9
         "0001000" when "1010",   --A
         "0000011" when "1011",   --b
         "1000110" when "1100",   --C
         "0100001" when "1101",   --d
         "0000110" when "1110",   --E
         "0001110" when "1111",   --F
         "1000000" when others;   --0

end Behavioral;

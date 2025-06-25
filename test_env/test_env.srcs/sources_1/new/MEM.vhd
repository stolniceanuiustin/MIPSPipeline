

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
entity MEM is
    Port (MemWrite : in std_logic;
          ALUResIn : in std_logic_vector(31 downto 0);
          RD2 : in std_logic_vector(31 downto 0);
          CLK : in std_logic;
          EN : in std_logic;
          AluResOut : out std_logic_vector(31 downto 0);
          MemData : out std_logic_vector(31 downto 0));
end MEM;

architecture Behavioral of MEM is

signal address : std_logic_vector(5 downto 0);

type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
signal MEM : ram_type := (
X"0000_0010",--X = 16. cautam toate lemenetele mai mici decat 16
X"0000_000C",--A = 3 dar defapt trb pus C(12). incepe la adresa 3
X"0000_0000", --AICI SCRIEM REZULTATUL --addr 12
X"0000_0001",
X"0000_0111", 
X"0000_0003",
X"0000_0004",
others => X"00000000");

signal AluRes : std_logic_vector(31 downto 0);
begin
address <= ALUResIn(7 downto 2);
process(clk)
begin 
    if rising_edge(clk) then
        if en='1' and MemWrite = '1' then 
            MEM(conv_integer(address)) <= RD2;
        end if;
        if en='1' and MemWrite ='0' then 
            MemData <= MEM(conv_integer(Address));
        end if;
    end if;
end process;

AluRes <= AluResIn;
AluResOut <= AluResIn;
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity ID is 
port ( 
    clk : in std_logic; 
    en : in std_logic;
    RegWrite : in std_logic;
    WA : in std_logic_vector(4 downto 0);
    Instr : in std_logic_vector(25 downto 0);
    ExtOp : in std_logic;
    wd : in std_logic_vector(31 downto 0); 
    rd1 : out std_logic_vector(31 downto 0); 
    rd2 : out std_logic_vector(31 downto 0);
    Ext_Imm : out std_logic_vector(31 downto 0);
    func : out std_logic_vector(5 downto 0);
    sa : out std_logic_vector(4 downto 0);
    rt : out std_logic_vector(4 downto 0);
    rd : out std_logic_vector(4 downto 0)); 
end ID; 
 
architecture Behavioral of ID is 
 
type reg_array is array(0 to 31) of std_logic_vector(31 downto 0); 
signal reg_file : reg_array:= ( 
 others => X"00000000"); 
    signal ra1 : std_logic_vector(4 downto 0); 
    signal ra2 : std_logic_vector(4 downto 0); 
begin 
    --initial parsing
    ra1 <= Instr(25 downto 21);
    ra2 <= Instr(20 downto 16);

    --extension unit
    Ext_Imm(15 downto 0) <= Instr(15 downto 0);
    Ext_Imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else (others => '0');

    func <= Instr(5 downto 0);
    sa <= Instr(10 downto 6);
    
    
    process(clk) 
    begin 
    if falling_edge(clk) then 
        if RegWrite = '1' and en = '1' then 
            reg_file(conv_integer(wa)) <= wd; 
        end if; 
        reg_file(0) <= X"00000000";
    end if; 
    if rising_edge(clk) then 
        rd1 <= reg_file(conv_integer(ra1)); 
        rd2 <= reg_file(conv_integer(ra2)); 
    end if;
    end process; 
 
    
    rt <= Instr(20 downto 16);
    rd <= Instr(15 downto 11);
end Behavioral; 
 
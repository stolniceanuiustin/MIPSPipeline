library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity UC is
 Port ( opcode : in std_logic_vector(5 downto 0);
        RegDst : out std_logic;
        ExtOp  : out std_logic;
        ALUSrc : out std_logic;
        Branch : out std_logic;
        Jump   : out std_logic;
        ALUOp  : out std_logic_vector(1 downto 0);
        MemWrite : out std_logic;
        MemtoReg : out std_logic;
        JumpR    : out std_logic;
        Br_GTZ   : out std_logic;
        RegWrite : out std_logic);
end UC;

architecture Behavioral of UC is
constant R     : std_logic_vector(1 downto 0) := "00";
constant Plus  : std_logic_vector(1 downto 0) := "01";
constant Minus : std_logic_vector(1 downto 0) := "10";
constant CAnd   : std_logic_vector(1 downto 0) := "11";
begin
process(opcode)
begin
    RegDst <= '0';
    ExtOp <= '0';
    ALUSrc <= '0';
    Branch <= '0';
    Jump <= '0';
    ALUOp <= "00";
    MemWrite <= '0';
    MemtoReg <= '0';
    JumpR <= '0';
    Br_GTZ <= '0';
    RegWrite <= '0';
    case opcode is
    when "000000" => --R type instructions 
        RegDst <= '1';
        RegWrite <= '1';
        ALUOp <= R;
    when "001000" => --ADDI
        ExtOp <= '1';
        ALUSrc <= '1';
        RegWrite <= '1';
        ALUOp <= Plus;
    when "001100" => --ANDI
        ExtOp <= '0';
        ALUSrc <= '1';
        RegWrite <= '1';
        ALUOp <= CAnd;
    when "100011" => --LW 
        RegDst <= '0';
        ExtOp <= '1';
        ALUSrc <= '1';
        MemtoReg <= '1';
        RegWrite <= '1';
        ALUOp <= Plus;
    when "101011" => --SW
        ExtOp <= '1';
        ALUSrc <= '1';
        MemWrite <= '1';
        ALUOp <= Plus;
    when "000100" => --BEQ
        ExtOp <= '1';
        Branch <= '1';
        ALUOp <= Minus;
    when "000111" => --BGTZ
        ExtOp <= '1';
        Br_GTZ <= '1';
        ALUOp <= Minus;
    when "000010" => --Jump
        Jump <= '1';
    when "000011" => --JumpRegister
        JumpR <= '1';
    when others => 
         RegDst <= '0'; -- do nothing basically
    end case;
end process;

end Behavioral;

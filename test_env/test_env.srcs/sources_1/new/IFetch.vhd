library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
  Port (JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
        BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
        Jump : in STD_LOGIC;
        PCSrc : in STD_LOGIC;
        JumpR : in STD_LOGIC;
        JRAddress : in STD_LOGIC_VECTOR(31 downto 0);
        PC4: out STD_LOGIC_VECTOR(31 downto 0);
        Instruction: out STD_LOGIC_VECTOR(31 downto 0);
        EN : in STD_LOGIC;
        RST: in STD_LOGIC;
        CLK: in STD_LOGIC);
end IFetch;

architecture Behavioral of IFetch is
--S? se parcurg? memoria de la adresa A (A?12) pân? se întâlne?te o valoare
--nul? ?i s? se determine câte valori întâlnite sunt mai mici ca X. X ?i A se citesc din
--memorie de la adresele 0, respectiv 4, iar rezultatul se va scrie la adresa 8.
  type rom_array is array(0 to 31) of std_logic_vector(31 downto 0);
  signal rom : rom_array := (
B"000000_00000_00000_00001_00000_100000", --X"0000 0820" --00:add $1, $0, $0   | $1 = i = 0
B"100011_00000_00010_0000000000000000",   --X"8C02 0000" --01: lw $2, 0(0)     | $2 = X = mem[0]
B"100011_00000_00011_0000000000000100",   --X"8C03 0004: --02: lw $3, 4(0)     | $3 = A = mem[4] 
B"000000_00000_00000_00100_00000_100000", --X"0000 2020" --03: add $4, $0, $0   | $4 = cnt = 0
B"000000_00000_00000_00101_00000_100000", --X"0000 2820" --04: add $5, $0, $0   | $5 = temp = 0
B"000000_00011_00001_00110_00000_100000", --X"0061 3020" --begin_loop: --05: add $6, $1, $3 | $6 = A + i(addresa efectiva)
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --06: NOOP
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --07: NOOP
B"100011_00110_00101_0000000000000000",   --X"8CC5 0000" --08: lw $5, 0($6)  |$5 = temp = mem[A+i]
B"001000_00001_00001_0000000000000100",   --X"2021 0004" --09: addi $1, $1, 4 | i = i + 4
B"000000_00101_00010_00111_00000_100010", --X"00A2 3822" --10: sub $7, $5, $2  | $7 = X - 
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --11: NOOP
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --12: NOOP
B"000111_00111_00000_0000000000000100",   --X"1CE0 0001" --13: BGTZ $7, skipincrement(+4)
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --14: NOOP
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --15: NOOP
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --16: NOOP
B"001000_00100_00100_0000000000000001",   --X"2083 0001" --17: addi $4, $4, 1
B"000100_00101_00000_0000000000000101",    --X"10A0 0005" --18: skip_increment: BEQ $5, $0, end_loop(+5)
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --19: NOOP
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --20: NOOP
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --21: NOOP
B"000010_00000000000000000000000101",     --X"0800 0018" --22: j begin_loop(addr 05)
B"000000_00000_00000_00000_00000_100000", --X"0000 0020" --23: NOOP
B"101011_00000_00100_0000000000001000",   --X"AC04 0008" --24: end_loop: sw $4, result_address(8)
others => X"00000000"); --mem intrusctiubn
  
  signal instruction_out : STD_LOGIC_VECTOR(31 downto 0);
  signal New_PC : STD_LOGIC_VECTOR(31 downto 0);
  signal BOrJumpOrPC4 : STD_LOGIC_VECTOR(31 downto 0); --branch or jump or pc+4
  signal BOrPC4 : STD_LOGIC_VECTOR(31 downto 0);
  signal PC4_aux : STD_LOGIC_VECTOR(31 downto 0);
  signal PC : STD_LOGIC_VECTOR(31 downto 0);
begin
  --adder_with_4: process(clk)
  --begin
    --if rising_edge(clk) then 
   --   PC4_aux <= PC + 4;
    --end if;
  --end process;
  
  pc_register: process(clk,rst)
  begin 
    if rst = '1' then 
      PC <= (others => '0');
    elsif rising_edge(clk) then 
      if en = '1' then 
        PC <= New_PC;
      end if;
    end if;
  end process;

  
  BOrPC4 <= BranchAddress when PCSrc = '1' else PC4_aux;
        BOrJumpOrPC4 <= JumpAddress when Jump = '1' else BOrPC4;
        New_PC <= JRAddress when JumpR = '1' else BOrJumpOrPC4;
  instruction_out <= rom(conv_integer(PC(6 downto 2)));
  PC4_aux <= PC+4;
  PC4 <= PC4_aux;
  Instruction <= instruction_out;
end Behavioral;

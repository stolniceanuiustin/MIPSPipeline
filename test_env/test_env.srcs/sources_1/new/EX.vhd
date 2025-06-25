library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
entity EX is
    Port (RD1: in STD_LOGIC_VECTOR(31 downto 0);
          ALUSrc : in STD_LOGIC;
          RD2 : in STD_LOGIC_VECTOR(31 downto 0);
          Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);  
          sa : in STD_LOGIC_VECTOR(4 downto 0);
          func : in STD_LOGIC_VECTOR(5 downto 0);
          ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
          PC4 : in STD_LOGIC_VECTOR(31 downto 0);
          rt : in STD_LOGIC_VECTOR(4 downto 0);
          rd : in STD_LOGIC_VECTOR(4 downto 0);
          RegDst : in STD_LOGIC;
          GTZ : out STD_LOGIC;
          Zero : out STD_LOGIC;
          ALURes : out STD_LOGIC_VECTOR(31 downto 0);
          BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
          rWA : out STD_LOGIC_VECTOR(4 downto 0));
end EX;

architecture Behavioral of EX is
    --codurile de la instructiune 
    constant R     : std_logic_vector(1 downto 0) := "00";
    constant Plus  : std_logic_vector(1 downto 0) := "01";
    constant Minus : std_logic_vector(1 downto 0) := "10";
    constant CAnd   : std_logic_vector(1 downto 0) := "11";
    --codurile lui aluctrl
    constant CodPlus : std_logic_vector(2 downto 0) := "000";
    constant CodMinus : std_logic_vector(2 downto 0) := "001";
    constant CodSll :std_logic_vector(2 downto 0) := "010"; 
    constant CodSrl : std_logic_vector(2 downto 0) := "011";
    constant CodAnd : std_logic_vector(2 downto 0) := "100";
    constant CodOr : std_logic_vector(2 downto 0) := "101";
    constant CodXor : std_logic_vector(2 downto 0) := "110";
    --codurile pentru functii de tip R(func)
    constant fadd : std_logic_vector(5 downto 0) := "100000";
    constant fsub : std_logic_vector(5 downto 0) := "100010";
    constant fsll : std_logic_vector(5 downto 0) := "000000";
    constant fsrl : std_logic_vector(5 downto 0) := "000010";
    constant fand : std_logic_vector(5 downto 0) := "100100";
    constant f_or : std_logic_vector(5 downto 0) := "100101";
    constant fxor : std_logic_vector(5 downto 0) := "100110";
    
    signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
    signal A : std_logic_vector(31 downto 0);
    signal B : std_logic_vector(31 downto 0);
    signal C : std_logic_vector(31 downto 0);
    signal GTZ_Aux : std_logic;
    signal Zero_aux : std_logic;
begin
ALUControl : process(ALUOp, func)
    begin 
        case AluOp is
        when R =>
            case func is 
                when fadd => ALUCtrl <= CodPlus;
                when fsub => ALUCtrl <= CodMinus;
                when fsll => ALUCtrl <= CodSll;
                when fsrl => ALUCtrl <= CodSrl;
                when fand => ALUCtrl <= CodAnd;
                when f_or => ALUCtrl <= CodOr;
                when fxor => ALUCtrl <= CodXor;
                when others => ALUCtrl <= "000";
            end case;
        when Plus => ALUctrl <= CodPlus;
        when Minus => ALUctrl <= CodMinus;
        when CAnd => ALUctrl <= CodAnd;
        when others => ALUctrl <= CodPlus;
        end case;
    end process;

A <= RD1;
B <= Ext_Imm when ALUSrc ='1' else RD2;

ALU : process(A, B, sa, ALUCtrl)
begin
case ALUCtrl is
    when CodPlus => C <= A + B;
    when CodMinus => C <= A - B;
    when CodSll => C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa));
    When CodSrl => C <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa));
    when CodAnd => C <= A and B;
    when CodOr => C <= A or B; 
    when CodXor => C <= A xor B;
    when others => C <= (others => 'X');
end case;
end process;

--TODO: check this, highest chance of failure in all my code!
Zero_aux <= '1' when C = X"0000_0000" else '0';
GTZ_aux <= not Zero_aux and not C(31);
Zero <= Zero_aux;
GTZ <= GTZ_aux;
BranchAddress <= (Ext_Imm(29 downto 0) & "00") + PC4;
ALURes <= C;
rWA <= rd when RegDst = '1' else rt;
end Behavioral;

------------------------------------------------------------------------------------
--PROGRAM DE TEST
--S? se parcurg? memoria de la adresa A (A?12) pân? se întâlne?te o valoare
--nul? ?i s? se determine câte valori întâlnite sunt mai mici ca X. X ?i A se citesc din
--memorie de la adresele 0, respectiv 4, iar rezultatul se va scrie la adresa 8.


--B"000000_00000_00000_00001_00000_100000", X"0000 0820" --00:add $1, $0, $0   | $1 = i = 0
--B"100011_00000_00010_0000000000000000",   X"8C02 0000" --01: lw $2, 0(0)     | $2 = X = mem[0]
--B"100011_00000_00011_0000000000000100",   X"8C03 0004: --02: lw $3, 4(0)     | $3 = A = mem[4] 
--B"000000_00000_00000_00100_00000_100000", X"0000 2020" --03: add $4, $0, $0   | $4 = cnt = 0
--B"000000_00000_00000_00101_00000_100000", X"0000 2820" --04: add $5, $0, $0   | $5 = temp = 0
--B"000000_00011_00001_00110_00000_100000", X"0061 3020" --begin_loop: --05: add $6, $1, $3 | $6 = A + i(addresa efectiva)
--B"100011_00110_00101_0000000000000000",   X"8CC5 0000" --06: lw $5, 0($6)  |$5 = temp = mem[A+i]
--B"001000_00001_00001_0000100000000001",   X"2021 0801" --07: addi $1, $1, 4 | i = i + 4
--B"000000_00010_00101_00111_00000_100010", X"0045 3822" --08: sub $7, $5, $2  | $7 = X - temp
--B"000111_00111_00000_00000000000000001"   X"1CE0 0001" --09: BGTZ $7, skipincrement(+1)
--B"001000_00100_00011_0000000000000001",   X"2083 0001" --10: add $4, $4, $1
--B"000100_00101_00000_000000000000001",    X"10A0 0001" --11: skip_increment. BEQ $5, $0, end_loop(+1)
--B"000010_00000000000000000000000110",     X"0800 0006" --j begin_loop(addr 06)
--B"101011_00000_00100_0000000000001000",   X"AC04 0008" --end_loop: sw $4, result_address(8)

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

entity MIPSPipeline is
  Port ( led : out STD_LOGIC_VECTOR(15 downto 0);
         sw : in STD_LOGIC_VECTOR(15 downto 0);
         an : out STD_LOGIC_VECTOR(7 downto 0);
         cat : out STD_LOGIC_VECTOR(6 downto 0);
         btn : in STD_LOGIC_VECTOR(3 downto 0);
         clk : in STD_LOGIC
    );
end MIPSPipeline;

architecture Behavioral of MIPSPipeline is
component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD is
  Port ( 
    clk : in STD_LOGIC;
    digits : in STD_LOGIC_VECTOR(31 downto 0);
    an : out STD_LOGIC_VECTOR(7 downto 0);
    cat : out STD_LOGIC_VECTOR(6 downto 0)
  );
end component;

component IFetch is
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
end component;

component ID is 
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
end component; 
component UC is
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
end component;

component EX is
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
end component;

component MEM is
  Port (MemWrite : in std_logic;
        ALUResIn : in std_logic_vector(31 downto 0);
        RD2 : in std_logic_vector(31 downto 0);
        CLK : in std_logic;
        EN : in std_logic;
        AluResOut : out std_logic_vector(31 downto 0);
        MemData : out std_logic_vector(31 downto 0));
end component;

--UC aux signals
--signal RegDst :  std_logic;
signal ExtOp  :  std_logic;
--signal ALUSrc :  std_logic;
-- Branch :  std_logic;
signal Jump   :  std_logic;
--signal ALUOp  :  std_logic_vector(1 downto 0);
--signal MemWrite :  std_logic;
--signal MemtoReg :  std_logic;
signal JumpR   :  std_logic;
--signal Br_GTZ   :  std_logic;
--signal RegWrite :  std_logic;

signal en : STD_LOGIC;
signal data_out : STD_LOGIC_VECTOR(31 downto 0);
signal GTZ_flag_ex : std_logic;
signal Zero_flag_ex : std_logic;

signal JumpAddress : std_logic_vector(31 downto 0);
signal pc_src : std_logic;


signal wd_aux : std_logic_vector(31 downto 0);

--if output

signal PCp4_if : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_if : STD_LOGIC_VECTOR(31 downto 0);
--id output

signal Mem_to_reg_ID : std_logic;
signal Reg_Write_ID : std_logic;
signal Mem_Write_ID : std_logic;
signal Branch_ID : std_logic;
signal Br_GTZ_ID : std_logic;
signal ALUOp_ID : std_logic_vector(1 downto 0);
signal ALUSrc_ID : std_logic;
signal RegDst_id : std_logic;
signal RD1_ID : std_logic_vector(31 downto 0);
signal RD2_ID : std_logic_vector(31 downto 0);
signal Ext_Imm : std_logic_vector(31 downto 0);
signal Instruciton_id : std_logic_vector(31 downto 0);
signal func_id : std_logic_vector(5 downto 0);
signal sa_id : std_logic_vector(4 downto 0);
signal rd_id : std_logic_vector(4 downto 0);
signal rt_id : std_logic_vector(4 downto 0);
signal PCp4_id : std_logic_vector(31 downto 0);
signal Ext_imm_id : std_logic_vector(31 downto 0);
--INTERMEDIARY PIPELINE REGISTERS
--IF/ID
signal Instruction_IF_ID : std_logic_vector(31 downto 0);
signal PCp4_IF_ID : std_logic_vector(31 downto 0);



--ID/EX
--WB
signal Mem_to_reg_ID_EX : std_logic;
signal Reg_Write_ID_EX : std_logic;
--MEM
signal Mem_Write_ID_EX : std_logic;
signal Branch_ID_EX : std_logic;
signal Br_GTZ_ID_EX : std_logic;
--EX(nu se mai propaga)
signal ALUOp_ID_EX : std_logic_vector(1 downto 0);
signal ALUSrc_ID_EX : std_logic;
signal RegDst_id_ex : std_logic;
--the big registers
signal RD1_ID_EX : std_logic_vector(31 downto 0);
signal RD2_ID_EX : std_logic_vector(31 downto 0);
signal Ext_Imm_id_ex : std_logic_vector(31 downto 0);
signal Instruciton_id_ex : std_logic_vector(31 downto 0);
signal func_id_ex : std_logic_vector(5 downto 0);
signal sa_id_ex : std_logic_vector(4 downto 0);
signal rd_id_ex : std_logic_vector(4 downto 0);
signal rt_id_ex : std_logic_vector(4 downto 0);
signal PCp4_id_ex : std_logic_vector(31 downto 0);

--ex
signal alu_res_ex : std_logic_vector(31 downto 0);
signal branch_address_ex : std_logic_vector(31 downto 0);
signal wa_ex : std_logic_vector(4 downto 0);
--EX/MEM
--wb - se mai propaga o data
signal Mem_to_reg_ex_mem : std_logic;
signal Reg_write_ex_mem : std_logic;
--mem - astea nu se mai propaga
signal mem_write_ex_mem : std_logic;
signal branch_ex_mem : std_logic;
signal br_gtz_ex_mem : std_logic;
signal zero_flag_ex_mem : std_logic;
signal GTZ_flag_ex_mem : std_logic;
--registri mari 
signal Branch_address_ex_mem : std_logic_vector(31 downto 0);
signal alu_res_ex_mem : std_logic_vector(31 downto 0);
signal wa_ex_mem : std_logic_vector(4 downto 0);
signal rd2_ex_mem : std_logic_vector(31 downto 0);


--mem
signal alu_res_mem : std_logic_vector(31 downto 0);
signal mem_data_mem : std_logic_vector(31 downto 0);

--MEM/WB
signal WA_mem_wb : std_logic_vector(4 downto 0); 
signal Reg_Write_mem_wb : std_logic;
signal mem_to_reg_mem_wb : std_logic;
signal alu_res_mem_wb : std_logic_vector(31 downto 0);
signal mem_data_mem_wb : std_logic_vector(31 downto 0);
begin

--PROCESS for filling in all the pipeline registers!
register_filL: process(clk)
begin 
if rising_edge(clk) and en = '1' then
--IF/ID
    Instruction_IF_ID <= Instruction_if;
    PCp4_IF_ID <= PCp4_if;
--ID/EX
    RegDst_id_ex <= RegDst_ID;
    ALUSrc_id_ex   <= ALUSrc_ID;
    Branch_id_ex   <= Branch_ID;
    ALUOp_id_ex    <= ALUOp_ID;
    Mem_Write_id_ex <= Mem_Write_ID;
    Mem_to_Reg_id_ex <= Mem_to_Reg_ID;
    Br_GTZ_id_ex   <= Br_GTZ_ID;
    Reg_Write_id_ex <= Reg_Write_ID;
    rd1_id_ex <= rd1_id;
    rd2_id_ex    <= rd2_id;
    Ext_Imm_id_ex <= Ext_Imm_id;
    func_id_ex   <= func_id;
    sa_id_ex     <= sa_id;
    rt_id_ex     <= rt_id;
    rd_id_ex     <= rd_id;
    PCp4_id_ex <= PCp4_if_id;
    
 --id/ex to ex/mem
 alu_res_ex_mem <= alu_res_ex;
 branch_address_ex_mem <= branch_address_ex;
 rd2_ex_mem <= rd2_id_ex;
 mem_to_reg_ex_mem <= mem_to_reg_id_ex;
 reg_write_ex_mem <= reg_write_id_ex;
 mem_write_ex_mem <= mem_write_id_ex;
 branch_ex_mem    <= branch_id_ex;
 br_gtz_ex_mem    <= br_gtz_id_ex;
 wa_ex_mem <= wa_ex;
 
 --ex-mem
 GTZ_flag_ex_mem <= GTZ_flag_ex;
 zero_flag_ex_mem <= zero_flag_ex;
 alu_res_mem_wb <= alu_res_mem;
 mem_data_mem_wb <= mem_data_mem;
 wa_mem_wb <= wa_ex_mem;
 mem_to_reg_mem_wb <= mem_to_reg_ex_mem;
 reg_write_mem_wb <= reg_write_ex_mem;
end if;


end process;

--TODO: MODIFY THIS BEFORE PUTTING ON PLACUTA! VERY IMPORTANT
MPG_portmap: MPG port map(enable => en, btn => btn(0), clk => clk);
--en <= btn(0);
IFetch_portmap: IFetch port map(EN => en, 
                                RST => btn(1), 
                                clk => clk,
                                JumpAddress => JumpAddress,
                                BranchAddress => branch_address_ex_mem,
                                PCSrc => pc_src,
                                Jump => Jump,
                                Instruction => Instruction_if,
                                PC4 => PCp4_if,
                                JRAddress => rd1_id_ex,
                                JumpR => JumpR);

UC_portmap: UC port map(opcode => Instruction_IF_ID(31 downto 26),
                        RegDst => RegDst_ID,
                        ExtOp => ExtOp,
                        ALUSrc => ALUSrc_ID,
                        Branch => Branch_ID,
                        Jump => Jump, 
                        ALUOp => ALUOp_ID,
                        MemWrite => Mem_Write_ID,
                        MemtoReg => Mem_to_Reg_ID,
                        JumpR => JumpR,
                        Br_GTZ => Br_GTZ_ID,
                        RegWrite => Reg_Write_ID);

ID_portmap: ID port map(clk => clk, 
                        en => en,
                        RegWrite => Reg_write_mem_wb,
                        wa => wa_mem_wb,
                        Instr => Instruction_IF_ID(25 downto 0),
                        ExtOp => ExtOp,
                        wd => wd_aux,
                        rd1 => rd1_id,
                        rd2 => rd2_id,
                        Ext_Imm => Ext_Imm_id,
                        func => func_id,
                        sa => sa_id,
                        rt => rt_id,
                        rd => rd_id);
EX_portmap: EX port map(rd1 => rd1_id_ex,
          ALUSrc  => ALUSrc_id_ex,
          RD2 => rd2_id_ex,
          Ext_Imm => ext_imm_id_ex,  
          sa => sa_id_ex,
          func => func_id_ex,
          ALUOp => ALUOp_id_ex,
          PC4 => PCp4_id_ex,
          rt => rt_id_ex,
          rd => rd_id_ex,
          RegDst => regdst_id_ex,
          GTZ => GTZ_flag_ex,
          Zero => Zero_flag_ex,
          ALURes => alu_res_ex,
          BranchAddress => branch_address_ex,
          rWA => wa_ex);
MEM_portmap: MEM port map(MemWrite => Mem_write_ex_mem,
                          ALUResIn => alu_res_ex_mem,
                          RD2 => RD2_ex_mem,
                          clk => clk,
                          EN => EN,
                          AluResOut => alu_res_mem,
                          MemData => Mem_data_mem);
JumpAddress <= PCp4_IF_ID(31 downto 28) & (Instruction_IF_ID(25 downto 0) & "00");
pc_src <= (Branch_ex_mem AND Zero_flag_ex_mem) OR (Br_GTZ_ex_mem AND GTZ_flag_ex_mem);
wd_aux <= mem_data_mem_wb when mem_to_reg_mem_wb = '1' else alu_res_mem_wb;
process(sw(7 downto 5))
begin 
  case sw(7 downto 5) is
    when "000" => data_out <= Instruction_if_id;
    when "001" => data_out <= PCp4_if_id;
    when "010" => data_out <= RD1_id_ex;
    when "011" => data_out <= RD2_id_ex;
    when "100" => data_out <= ext_imm_id_ex;
    when "101" => data_out <= alu_res_ex_mem;
    when "110" => data_out <= mem_data_mem_wb;
    when "111" => data_out <= wd_aux;
    when others => data_out <= Instruction_if_id;
  end case;
end process;
SSD_portmap: SSD port map(clk => clk, digits => data_out, an => an, cat => cat);
led(11 downto 0) <= ALUOp_id_ex & Regdst_id_ex & ExtOp & ALUSrc_id_ex & Branch_id_ex & Br_GTZ_id_ex & Jump & JumpR & Mem_Write_id_ex & Mem_to_Reg_id_ex & Reg_Write_id_ex;
end Behavioral;

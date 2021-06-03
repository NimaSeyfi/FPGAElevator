library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity control_tb is
	-- Generic declarations of the tested unit
		generic(
		MEM_DATA_WIDTH : INTEGER := 8;
		MEM_ADDR_WIDTH : INTEGER := 4 );
end control_tb;

architecture TB_ARCHITECTURE of control_tb is
	-- Component declaration of the tested unit
	component control
		generic(
		MEM_DATA_WIDTH : INTEGER := 8;
		MEM_ADDR_WIDTH : INTEGER := 4 );
	port(
		clock : in STD_LOGIC;
		reset : in STD_LOGIC;
		start : in STD_LOGIC;
		ManualDataIn : in STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
		ManualEn : in STD_LOGIC;
		Timer : out STD_LOGIC_VECTOR(3 downto 0);
		Floor : out STD_LOGIC_VECTOR(3 downto 0);
		LiftDir : out STD_LOGIC_VECTOR(1 downto 0);
		LiftDoor : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clock : STD_LOGIC;
	signal reset : STD_LOGIC;
	signal start : STD_LOGIC;
	signal ManualDataIn : STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
	signal ManualEn : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Timer : STD_LOGIC_VECTOR(3 downto 0);
	signal Floor : STD_LOGIC_VECTOR(3 downto 0);
	signal LiftDir : STD_LOGIC_VECTOR(1 downto 0);
	signal LiftDoor : STD_LOGIC;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : control
		generic map (
			MEM_DATA_WIDTH => MEM_DATA_WIDTH,
			MEM_ADDR_WIDTH => MEM_ADDR_WIDTH
		)

		port map (
			clock => clock,
			reset => reset,
			start => start,
			ManualDataIn => ManualDataIn,
			ManualEn => ManualEn,
			Timer => Timer,
			Floor => Floor,
			LiftDir => LiftDir,
			LiftDoor => LiftDoor
		);

	-- Add your stimulus here ...
clk_process :process
	   begin
	        clock <= '0';
	        wait for 20ns;
	        clock <= '1';
	        wait for 20ns;
	   end process;							
start <='0','1' after 30ns,'0' after 70ns; 
ManualEn <= '0','1' after 3600ns , '0' after 3700ns,'1' after 14000ns , '0' after 14050ns;
ManualDataIn <="00000000", "00110100" after 3590ns, "01111101" after 13990ns;
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_control of control_tb is
	for TB_ARCHITECTURE
		for UUT : control
			use entity work.control(behaviour);
		end for;
	end for;
end TESTBENCH_FOR_control;


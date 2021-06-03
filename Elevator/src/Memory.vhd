library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Memory is
	generic (
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 4
	);
	port (
	CLK : in std_logic;	
	WE : in std_logic;						   				   
	Addr : in std_logic_vector (ADDR_WIDTH-1 downto 0);
	DataOut : out std_logic_vector (DATA_WIDTH-1 downto 0);
	DataIn : in std_logic_vector (DATA_WIDTH-1 downto 0)
	); 
	
end Memory;

architecture behaviour of Memory is															  
    Type MyMem is array (2** ADDR_WIDTH-1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
	signal Mem  :  MyMem;	
	
	--test : random signal
	signal psuedo_rand : std_logic_vector(31 downto 0) := x"00000001";
begin  	



   process (CLK)   begin
	if CLK'event and CLK = '1' then
		if WE = '1' then	    
			--Mem(to_integer(unsigned(Addr))) <= DataIn;
		end if;
    end if;
   end process;

	DataOut <= Mem(to_integer(unsigned(Addr))) when (WE = '0') 
		else (others => 'Z');
		  
			
			
    --test
	process(CLK,psuedo_rand)
	variable i : integer range 0 to 10 := 0;
	--maximal length 32-bit xnor LFSR		 
		function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
			begin
				return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
		end function; 
		
	begin 
		if i < 10 then
			psuedo_rand <= lfsr32(psuedo_rand);	 
			Mem(i) <=psuedo_rand(7 downto 0);
			i := i+1;
		end if;
	end process;
	
	--Mem(0) <= "00000010";
	--Mem(1) <= "01010011";
	--Mem(2) <= "01100010";
	--Mem(3) <= "10000101";
	--Mem(4) <= "11100010";
	--Mem(5) <= "00110011";
	--Mem(6) <= "01010000";
	--Mem(7) <= "01110110";
	--Mem(8) <= "10110001";
	--Mem(9) <= "11100111"; 
	
end behaviour;
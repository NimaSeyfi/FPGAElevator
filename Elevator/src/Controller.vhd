library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Control is
	generic (			   		   
		MEM_DATA_WIDTH : integer := 8;
		MEM_ADDR_WIDTH : integer := 4;
		FLOORS_COUNT : integer := 10
	);
	port (
	clock,reset : in std_logic;	
	start : in std_logic;										 
	ManualDataIn : in std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
	ManualEn : in std_logic := '0';
	Timer, Floor : out std_logic_vector(3 downto 0);
	LiftDir : out std_logic_vector(1 downto 0);
	LiftDoor : out std_logic
	); 
	
end Control;

architecture behaviour of Control is		

	TYPE states IS (RESETCONTROL, GETFLOOR, GOUP, GODOWN, TIMERWAIT, MANUAL);
	SIGNAL pr_state, nx_state: states; 	
	signal i : integer range 0 to 20;
	signal FloorsCount : integer range 0 to 15 := FLOORS_COUNT;
	signal MemRead : std_logic := '0';
	signal ManualON : std_logic := '0';
	signal goToReset : std_logic := '0';
	signal ResetON : std_logic := '0';
	signal arrived : std_logic;		   
	signal Floor_temp : std_logic_vector(3 downto 0);
	signal Timer_temp : std_logic_vector(3 downto 0); 
	signal actual_floor : std_logic_vector(3 downto 0) := (others=>'0');		
	signal MemDataAddr : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
	signal MemData : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
	signal MemDataIN : std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
	
	alias floor_mem: std_logic_vector(3 downto 0) is MemData(3 downto 0);
	alias timer_mem : std_logic_vector(7 downto 4) is MemData(7 downto 4);
	alias floor_man: std_logic_vector(3 downto 0) is ManualDataIn(3 downto 0);
	--alias timer_man : std_logic_vector(7 downto 4) is ManualDataIn(7 downto 4);
	
	component Memory is
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
		
	end component;
begin  
	
MEMUNIT : Memory 						 	
	generic map (DATA_WIDTH => MEM_DATA_WIDTH , ADDR_WIDTH => MEM_ADDR_WIDTH)
	port map(CLK => clock , WE => MemRead , Addr => MemDataAddr, DataOut => MemData , DataIn => MemDataIN);

MemDataAddr <= std_logic_vector(to_unsigned(i, MemDataAddr'length));	
	-----------------------------------------------------------------------------------------------------------------
	----control (sequential part)
	PROCESS (clock)
   
		BEGIN
      
			IF (reset='1') THEN
         
				pr_state <= RESETCONTROL;
      
			ELSIF (clock'EVENT AND clock='1') THEN
  
				pr_state <= nx_state;
      
			END IF;
   
		END PROCESS;
	
   	----control (combinatial part)
PROCESS (pr_state,start,floor_mem,Floor_temp,Timer_temp,floor_man,timer_mem,arrived,actual_floor,ManualEn)
  
BEGIN									 
      		nx_state <= pr_state;
			CASE pr_state IS 
	
         		WHEN RESETCONTROL =>
				
				if ManualEn='0' then 
					if start='1' then
						nx_state <= GETFLOOR;
					else
						if actual_floor > "0000" then	  
							nx_state <= GODOWN;
						else
							nx_state <= RESETCONTROL;
						end if;
					end if;	
					
				else
					nx_state <= MANUAL;
				end if;
				
				
				Floor_temp <= "0000";
				Timer <= "0000";
				LiftDir <= "11";
				LiftDoor <= '1';  
					
         		WHEN GETFLOOR =>  

				Floor_temp <= floor_mem;
				if ManualEn='0' then
					if actual_floor <= Floor_temp then	  
						nx_state <= GOUP;
					else   
						nx_state <= GODOWN;
					end if;
				else
					nx_state <= MANUAL;
				end if;
				
				Timer <= timer_mem;				
				LiftDir <= "11";
				LiftDoor <= '0'; 
				
				WHEN GOUP => 
				
				if ManualEn = '0' then
					if arrived='1' then	 
						nx_state <= TIMERWAIT;
					else
						nx_state <= GOUP;
					end if;	 
				else
					nx_state <= MANUAL;
				end if;
				
				Floor_temp <= "1111";	
				Timer <= "0000";			
				LiftDir <= "01";
				LiftDoor <= '0'; 
								
				WHEN GODOWN =>
				
				if ManualEn = '0' then
					if arrived='1' then	 
						nx_state <= TIMERWAIT;
					else
						nx_state <= GODOWN;
					end if;
				else
					nx_state <= MANUAL;
				end if;
				
				Floor_temp <= "1111";	
				Timer <= "0000";			
				LiftDir <= "10";
				LiftDoor <= '0';  
				
				WHEN MANUAL =>
				
				Floor_temp <= floor_man;	
					if actual_floor<=Floor_temp then	  
						nx_state <= GOUP;
					else   
						nx_state <= GODOWN;
					end if;
					
				Timer <= "0101"; --5 second default			
				LiftDir <= "00";
				LiftDoor <= '0'; 
				
				WHEN TIMERWAIT =>
				
				if ManualEn='0' then
					if (Timer_temp="0000" and i/=FloorsCount) then	  
						nx_state <= GETFLOOR;
					elsif  Timer_temp="0000" and i=FloorsCount then 
						nx_state <= RESETCONTROL;
					else
						nx_state <= TIMERWAIT;
					end if;
				else
					nx_state <= MANUAL;
				end if;
									
				if ManualEN='1' then
					Floor_temp <= floor_man;
					Timer <=  "0101"; --5 second default
				else
					Floor_temp <= floor_mem;
					Timer <= timer_mem;
				end if;	 
					
				LiftDir <= "00";
				LiftDoor <= '1'; 
								
			END CASE;
   
		END PROCESS;  
	---------------------------------------------------------------------------------------------------------- 



   	----control elevator
PROCESS (clock,pr_state)
variable timerCounter : integer range 1 to 50000000; 
variable oneSec : integer range 1 to 25000000;   
BEGIN		
			goToReset <= '0';
			CASE pr_state IS
         		WHEN RESETCONTROL => 
				goToReset <= '1';	  

         		WHEN GETFLOOR =>
				Timer_temp <= timer_mem;
				
				WHEN GOUP =>
				
				if ManualEn='0' then
					if (clock'EVENT AND clock='1') THEN	
						if timerCounter<10 then			  --50000000
							timerCounter := timerCounter + 1; 
						else
							timerCounter := 1;
							actual_floor <= std_logic_vector(unsigned(actual_floor) + 1);
						end if;
					end if;
				end if;				
				WHEN GODOWN =>	
				
				if ManualEn='0' or ResetON='1' then
					if (clock'EVENT AND clock='1') THEN	
						if timerCounter<10 then			  --50000000
							timerCounter := timerCounter + 1; 
						else
							timerCounter := 1;
							actual_floor <= std_logic_vector(unsigned(actual_floor) - 1);
						end if;
					end if;
				end if;
				WHEN MANUAL =>				
				Timer_temp <=  "0101"; --5 second default
				
				WHEN TIMERWAIT =>
				
				if ManualEn='0' then
					if (clock'EVENT AND clock='1') THEN	
						if Timer_temp > "0000" then
							if oneSec<10 then			  --25000000
								oneSec := oneSec + 1; 
							else
								oneSec := 1;
								Timer_temp <= std_logic_vector(unsigned(Timer_temp) - 1);
							end if;
						end if;
					end if;
				end if;
				
			END CASE;
   
		END PROCESS;  
	---------------------------------------------------------------------------------------------------------- 		 
--ManualON Control : for controling the arrived signal
process(Timer_temp,ManualEn)
begin  
	
	if ManualEn='1' then 
		ManualON <= '1';
	end if;
	if actual_floor=floor_man and Timer_temp="0000" then
		ManualON <= '0';	
	end if;
	
end process;	


--Floors memory counter
process(Timer_temp,ManualEn,actual_floor,Floor_temp)
begin
	
	if Timer_temp="0000" and actual_floor=Floor_temp then --if waiting at the floor was completed
		if ManualON='0' then  --and if ManualON was 0 : elevator uses memory to move
			if i=10 then
				i <= 0;
			else
				i <= i+1;
			end if;
		end if;	 
	end if;
	
end process;



process(Timer_temp,goToReset,i,FloorsCount)
begin  
	
	if goToReset='1' and i=FloorsCount then 
		ResetON <= '1';
	end if;
	if actual_floor="0000" and Timer_temp="0000" then
		ResetON <= '0';	
	end if;
	
end process;

	
process(actual_floor,ManualON,ResetON,floor_mem,floor_man)
begin 
	if ManualON='0' then
		if ResetON='1' then
			if actual_floor="0000" then
				arrived <= '1';
			end if;
		else
			if actual_floor=floor_mem then
				arrived <= '1';
			else
				arrived <= '0';
			end if;	  	
		end if;	 		
	else
		if actual_floor=floor_man then
			arrived <= '1';
		else
			arrived <= '0';
		end if;	
	end if;	 
	
end process;
--get Floor output of Floor_temp signal
Floor <= Floor_temp;



end behaviour;
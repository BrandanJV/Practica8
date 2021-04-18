--Stardard IEEE library
library IEEE;
use IEEE.std_logic_1164.all;

-- Entity port declaration
entity FSM is port(
	Run	: in std_logic;
--	stim : out std_logic_vector(2 downto 0);
	Clk: in std_logic;
	duty_cycle: out integer:= 50_000
	--Result 	: out std_logic
	);
end FSM;

-- Architecture of FSM
architecture struct of FSM is 

	type stateType is (S0, S45, S90, S135, S180);
	signal currentState, nextState : stateType;
	signal Rst: std_logic:= '0';
	
begin
	--Syncrhonous process (State FFs)
	syncProcess: process(Rst, Clk)
	begin
		if (Rst = '1') then 
			currentState <= S0;
		elsif (rising_edge(Clk)) then
			currentState <= nextState;
		end if;
	end process syncProcess;

	--Combinatorial process (State and output decode)
	combProcess: process(currentState, Run)

	begin
	case currentState is
		when S0 =>
			duty_cycle <= 50_000;
			if (Run = '1') then
				nextState <= S45;
			else
				nextState <= S0;
			end if;
		when S45 =>
		  duty_cycle <= 100_000;
            if (Run = '1') then
				nextState <= S90;
			else
				nextState <= S45;
			end if;
        when S90 => 
            duty_cycle <= 150_000;
                if(Run = '1') then
                    nextState <= S135;
                else
                    nextState <= S90;
                end if;
        when S135 =>
            duty_cycle <= 200_000;
            if(Run = '1') then 
                nextState <= S180;
            else
                nextState <= S135;
            end if;
        when S180 =>
            duty_cycle <= 250_000;
            if(Run = '1') then
                nextState <= S0;
            else 
                nextState <= S180;  
            end if;                        
		when others =>
			nextState <= S0;
	end case;
	end process combProcess;
end struct;


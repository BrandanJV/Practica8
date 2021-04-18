----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2021 16:41:41
-- Design Name: 
-- Module Name: main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
    Port (clk100m: in std_logic;
            pos  : in std_logic;
            Dan, Dca: out std_logic_vector(7 downto 0);  -- Dan: Habilitador de anodos, Dca: Habilitador catodos
            pwm_out : out std_logic );
end main;

architecture Behavioral of main is

subtype u20 is unsigned(19 downto 0);
signal counter      : u20 := x"00000";

constant clk_freq   : integer := 100_000_000;       -- Clock frequency in Hz (10 ns)
constant pwm_freq   : integer := 50;                -- PWM signal frequency in Hz (20 ms)
constant period     : integer := clk_freq/pwm_freq; -- Clock cycle count per PWM period
signal   duty_cycle : integer := 50_000;            -- Clock cycle count per PWM duty cycle

signal btn: std_logic;
signal pwm_counter  : std_logic := '0';
signal stateHigh    : std_logic := '1';
signal d7s: std_logic_vector(63 downto 0):= "1111111111111111111111111111111111111111000000000000000000000000";

    component displayDriver is
        port(ck : in  std_logic;                          -- 100MHz system clock
			number : in  std_logic_vector (63 downto 0); -- eight digit number to be displayed
			seg : out  std_logic_vector (7 downto 0);    -- display cathodes
			an : out  std_logic_vector (7 downto 0));    -- display anodes (active-low, due to transistor complementing));
    end component;
    
    component FSM is port(
	   Run	: in std_logic;
       --stim : out std_logic_vector(2 downto 0);
	   Clk: in std_logic;
	   duty_cycle: out integer:= 50_000);
    end component;
    
    component Dbncr is
       generic(
          NR_OF_CLKS : integer := 4095 -- Number of System Clock periods while the incoming signal 
       );                              -- has to be stable until a one-shot output signal is generated
       port(
          clk_i : in std_logic;
          sig_i : in std_logic;
          pls_o : out std_logic
       );
    end component;

begin
    
    pwm_generator : process(clk100m) is
    variable cur : u20 := counter;
    begin
        if (rising_edge(clk100m)) then
            cur := cur + 1;  
            counter <= cur;
            if (cur <= duty_cycle) then
                pwm_counter <= '1'; 
            elsif (cur > duty_cycle) then
                pwm_counter <= '0';
            elsif (cur = period) then
                cur := x"00000";
            end if;  
            
            case(duty_cycle) is
                when 50_000 => d7s(7 downto 0) <= "11000000";
                               d7s(15 downto 8) <= "11000000";
                               d7s(23 downto 16) <= "11000000";
                when 100_000 => d7s(7 downto 0) <= "10010010";
                                d7s(15 downto 8) <= "10011001";
                                d7s(23 downto 16) <= "11000000"; 
                when 150_000 => d7s(7 downto 0) <= "11000000";
                                d7s(15 downto 8) <= "10010000";
                                d7s(23 downto 16) <= "11000000"; 
                when 200_000 => d7s(7 downto 0) <= "10010010";
                                d7s(15 downto 8) <= "10110000";
                                d7s(23 downto 16) <= "11111001";
                when 250_000 => d7s(7 downto 0) <= "11000000";
                                d7s(15 downto 8) <= "10000000";
                                d7s(23 downto 16) <= "11111001";
                when others =>  d7s(7 downto 0) <= "11111111";
                                d7s(15 downto 8) <= "11111111";
                                d7s(23 downto 16) <= "11111111";                
            end case;
        end if;
    end process pwm_generator;
    pwm_out <= pwm_counter;
    
Disp7: displayDriver port map(ck => clk100m, number => d7s, seg => Dca, an => Dan);
StM: FSM port map(Run => btn, Clk => clk100m, duty_cycle => duty_cycle);
dbn: Dbncr port map(clk_i => clk100m, sig_i => pos, pls_o => btn);

end Behavioral;
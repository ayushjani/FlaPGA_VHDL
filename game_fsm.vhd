library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity game_fsm is
port (
		clk, reset, PB1, PB2, SW_pause : in std_logic; 
		hit : in std_logic;
		game_reset, game_pause : out std_logic;
		selected_mode : out std_logic_vector(1 downto 0)
		);
		
end entity;

architecture fsm of game_fsm is
-- FSM signals
type state_type is (s_menu, s_regular, s_training, s_over);
signal state, next_state : state_type := s_menu;

begin
	sync_proc : process(clk, reset) --synchronously move to next state
	begin
		if (reset = '1') then
			state <= s_menu;
		elsif (rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;

	next_states_fn: process(state, PB1, PB2, SW_pause, hit) --asynchronously decide next state based only on current state and inputs
	begin
		case(state) is
			when s_menu =>
				if (PB1 = '0') then
					next_state <= s_training;
				elsif (PB2 = '0') then
					next_state <= s_regular;
				else 
					next_state <= s_menu;
				end if;
				
			when s_training =>
				if (hit = '1') then 
					next_state <= s_over;
				elsif (reset = '1') then -- Check if to remove
					next_state <= s_menu;	
				else
					next_state <= s_training;
				end if;
				
			when s_regular =>
				if (hit = '1') then 
					next_state <= s_over;
				elsif (reset = '1') then -- Check if to remove
					next_state <= s_menu;
				else
					next_state <= s_regular;
				end if;
				
			when s_over =>
				if (reset = '1') then
					next_state <= s_menu;
				else 
					next_state <= s_over;
				end if;
				
		end case;
		game_pause <= SW_pause;
	end process;
	
	outputs:process(state)
		begin
			case state is
				when s_menu =>
					game_reset <= '1';
					selected_mode <= "00";
				when s_training =>
					game_reset <= '0';
					selected_mode <= "01";
				when s_regular =>
					game_reset <= '0';
					selected_mode <= "10";
				when s_over =>
					game_reset <= '0';
					selected_mode <= "11";
			end case;
		end process;
end architecture fsm;
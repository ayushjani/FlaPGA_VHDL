LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

ENTITY display IS
	PORT
		(SIGNAL pb1, pb2, clk, vert_sync	: IN std_logic;
		 SIGNAL reset, pause					: IN std_logic;
       SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		 SIGNAL selected_mode            : IN std_logic_vector(1 downto 0);
		 SIGNAL hit 							: OUT std_logic;
		 SIGNAL red, green, blue 			: OUT std_logic);		
END display;

architecture behavior of display is

component bouncy_ball is
	PORT
		(SIGNAL pb1, pb2, clk, vert_sync	      			: IN std_logic;
		 SIGNAL reset, pause    			      			: IN std_logic;
       SIGNAL pixel_row, pixel_column	      			: IN std_logic_vector(9 DOWNTO 0);
		 SIGNAL selected_mode                 			   : IN std_logic_vector(1 downto 0);
		 SIGNAL score0_out, score1_out, score2_out 	   : OUT std_logic_vector(5 downto 0);
		 SIGNAL hit													: OUT std_logic := '0';
		 SIGNAL text_on, ball_on, pipe_out 					: OUT std_logic);
end component bouncy_ball;

component menu is
	port(
		SIGNAL clk, vert_sync		      : IN std_logic;
		SIGNAL reset, pause					: IN std_logic;
		SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		SIGNAL menu_text_on, menu_out 	: OUT std_logic	
		);
end component menu;

component gameover is
    port(
        SIGNAL clk, vert_sync                  : IN std_logic;
        SIGNAL reset, pause                    : IN std_logic;
        SIGNAL pixel_row, pixel_column         : IN std_logic_vector(9 DOWNTO 0);
		  SIGNAL score0, score1, score2 			  : IN std_logic_vector(5 downto 0);
        SIGNAL over_text_on, gameover_out      : OUT std_logic    
        );
end component gameover;

signal bird_text_on, bird_ball_on, bird_pipe_on : std_logic;
signal menu_screen_on, menu_text_on 	   : std_logic;
signal over_screen_on, over_text_on 	   : std_logic;
signal player_hit							      : std_logic;
signal score0_out, score1_out, score2_out : std_logic_vector(5 downto 0);

begin

bird: bouncy_ball port map (pb1, pb2, clk, vert_sync, reset, pause, pixel_row, pixel_column, selected_mode, 
                            score0_out, score1_out, score2_out, player_hit, bird_text_on, bird_ball_on, bird_pipe_on);
menu_screen : menu port map (clk, vert_sync, reset, pause, pixel_row, pixel_column, menu_text_on, menu_screen_on);
game_over_screen : gameover port map (clk, vert_sync, reset, pause, pixel_row, pixel_column, score0_out, score1_out, 
												  score2_out, over_text_on, over_screen_on);


select_mode: process (selected_mode)

begin

	if (selected_mode = "00") then
		Red   <=  not(menu_screen_on) or menu_text_on;
		Green <=  not(menu_screen_on) or menu_text_on;
		Blue  <=  menu_screen_on or menu_text_on;	
	elsif (selected_mode = "11") then
      Red   <=  over_screen_on;
      Green <=  over_text_on;
      Blue  <=  not(over_screen_on) or (over_text_on) ;
	else
		-- Colours for pixel data on video signal
		-- Makes the ball red, background blue and text white
		Red <=  bird_text_on or bird_ball_on;
		Green <= (bird_text_on and not(bird_ball_on)) or bird_pipe_on;
		Blue <=  not(bird_ball_on);
		hit <= player_hit;
	end if;
	
end process select_mode;

end architecture behavior;
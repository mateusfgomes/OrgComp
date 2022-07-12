LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY ASCII_CONV IS
	PORT(	ASCII : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			CMAP : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		 );
END ASCII_CONV;

ARCHITECTURE main OF ASCII_CONV IS
BEGIN
	PROCESS(ASCII)
	BEGIN
		--IF(ASCII < x"20") THEN
		--	CMAP <= "1011111";
		--ELSE
		--	CMAP <= ASCII(6 DOWNTO 0) - "0100000";	-- ASCII - 32
		--END IF;
		CMAP <= ASCII(6 DOWNTO 0);
	END PROCESS;
END main;
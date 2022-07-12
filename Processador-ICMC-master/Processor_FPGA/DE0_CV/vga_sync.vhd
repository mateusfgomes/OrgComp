LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY VGA_SYNC IS
	PORT(
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			PIXELECT : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
			HSYNC : OUT STD_LOGIC;
			VSYNC : OUT STD_LOGIC;
			VIDEO_EN : OUT STD_LOGIC;
			STACK_EN : OUT STD_LOGIC
		);
END VGA_SYNC;

ARCHITECTURE main OF VGA_SYNC IS
SIGNAL Hcnt : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL Vcnt : STD_LOGIC_VECTOR(9 DOWNTO 0);
BEGIN
	PROCESS(CLK, RST)
	BEGIN
		IF(RST = '1') THEN
			Hcnt <= "0000000000";
		ELSIF(CLK'EVENT AND CLK = '1') THEN
			IF(Hcnt = 799) THEN
				Hcnt <= "0000000000";
			ELSE
				Hcnt <= Hcnt + 1;
			END IF;

			IF(Hcnt <= 755 AND Hcnt >= 659) THEN
				HSYNC <= '0';
			ELSE
				HSYNC <= '1';
			END IF;
		END IF;
	END PROCESS;

	PROCESS(CLK, RST)
	BEGIN
		IF(RST = '1') THEN
			Vcnt <= "0000000000";
		ELSIF(CLK'EVENT AND CLK = '1') THEN
			IF(Vcnt >= 524 AND Hcnt >= 699) THEN
				Vcnt <= "0000000000";
			ELSIF(Hcnt = 699) THEN
				Vcnt <= Vcnt + 1;
			END IF;

			IF(Vcnt <= 494 AND Vcnt >= 493) THEN
				VSYNC <= '0';
			ELSE
				VSYNC <= '1';
			END IF;
		END IF;
	END PROCESS;

	PROCESS(Hcnt, Vcnt)
	BEGIN
		IF(Hcnt <= 639 AND Vcnt <= 479) THEN
			PIXELECT <= conv_std_logic_vector(conv_integer(Hcnt(9 DOWNTO 1)) + 320 * conv_integer(Vcnt(9 DOWNTO 1)), 17);
			VIDEO_EN <= '1';
		ELSE
			PIXELECT <= "00000000000000000";
			VIDEO_EN <= '0';
		END IF;
	END PROCESS;

	PROCESS(CLK, RST)
	BEGIN
		IF(Hcnt > 640 AND Hcnt < 790 AND Vcnt > 480 AND Vcnt < 514) THEN
			STACK_EN <= '1';
		ELSE
			STACK_EN <= '0';
		END IF;
	END PROCESS;
END main;

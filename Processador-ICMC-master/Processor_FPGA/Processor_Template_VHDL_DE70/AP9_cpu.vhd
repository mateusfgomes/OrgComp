---------------------------------------------------
--apx-arch ap9 micro-processor---------------------
--16-bits width bus--------------------------------
--external clock-----------------------------------
--builded by microenix, cOPyright (r) 2011---------
--for detailed description about this--------------
--architechture, please refer to the ap9 reference--
--manual.------------------------------------------
---------------------------------------------------

libraRY ieee;
use ieee.std_LOGIC_1164.all;
use ieee.std_LOGIC_ARITH.all;
use ieee.std_LOGIC_unsigned.all;

entity AP9_cpu is
	port( clk			: in	std_LOGIC;
			reset			: in	std_LOGIC;
			
			Mem			: in	STD_LOGIC_VECTOR(15 downto 0);
			M5				: out STD_LOGIC_VECTOR(15 downto 0);
			M1				: out STD_LOGIC_VECTOR(15 downto 0);
			RW				: out std_LOGIC;
			
			key			: in	STD_LOGIC_VECTOR(7 downto 0);
			
			videoflag	: out std_LOGIC;
			vga_pos		: out STD_LOGIC_VECTOR(15 downto 0);
			vga_char		: out STD_LOGIC_VECTOR(15 downto 0);
			
			Ponto			: out STD_LOGIC_VECTOR(2 downto 0);
			
			halt_ack		: out	std_LOGIC;
			halt_req		: in	std_LOGIC;
			
			PC_data		: out STD_LOGIC_VECTOR(15 downto 0)
		);
end AP9_cpu;

ARCHITECTURE main of AP9_cpu is

	TYPE STATES				is (fetch, decode, exec, halted);						-- Estados da Maquina de Controle do Processador
	TYPE Registers			is array(0 to 7) of STD_LOGIC_VECTOR(15 downto 0); -- Banco de Registradores
	TYPE LoadRegisters	is array(0 to 7) of std_LOGIC;							-- Sinais de LOAD dos Registradores do Banco

	-- INSTRUCTION SET: 29 INSTRUCTIONS
	-- Data Manipulation Instructions:												-- Usage		    -- Action     	-- Format	
	CONSTANT LOAD			: STD_LOGIC_VECTOR(5 downto 0) := "110000";		-- LOAD RX END  -- RX <- M[END]  Format: < inst(6) | RX(3) | xxxxxxx >  + 16bit END
	CONSTANT STORE			: STD_LOGIC_VECTOR(5 downto 0) := "110001";		-- STORE END RX -- M[END] <- RX  Format: < inst(6) | RX(3) | xxxxxxx >  + 16bit END
	CONSTANT LOADIMED		: STD_LOGIC_VECTOR(5 downto 0) := "111000";		-- LOADN RX Nr   -- RX <- Nr    	Format: < inst(6) | RX(3) | xxxxxxb0 >  + 16bit Numero
	CONSTANT LOADINDEX	: STD_LOGIC_VECTOR(5 downto 0) := "111100";		-- LOADI RX RY   -- RX <- M[RY]	Format: < inst(6) | RX(3) | RY(3) | xxxx >
	CONSTANT STOREINDEX	: STD_LOGIC_VECTOR(5 downto 0) := "111101";		-- STOREI RX RY  -- M[RX] <- RY	Format: < inst(6) | RX(3) | RY(3) | xxxx >
	CONSTANT MOV			: STD_LOGIC_VECTOR(5 downto 0) := "110011";		-- MOV RX RY    -- RX <- RY	  	Format: < inst(6) | RX(3) | RY(3) | xx | x0 >
																								-- MOV RX SP    RX <- SP         Format: < inst(6) | RX(3) | xxx | xx | 01 >
																								-- MOV SP RX    SP <- RX         Format: < inst(6) | RX(3) | xxx | xx | 11 >
	
	-- I/O Instructions:
	CONSTANT OUTCHAR		: STD_LOGIC_VECTOR(5 downto 0) := "110010";		-- OUTCHAR RX RY -- Video[RY] <- Char(RX)		Format: < inst(6) | RX(3) | RY(3) | xxxx >
	CONSTANT INCHAR		: STD_LOGIC_VECTOR(5 downto 0) := "110101";		-- INCHAR RX     -- RX[5..0] <- KeyPressed	RX[15..6] <- 0's  	Format: < inst(6) | RX(3) | xxxxxxx >
																								-- Se nao pressionar nenhuma tecla, RX recebe 00FF
	
	CONSTANT ARITH			: STD_LOGIC_VECTOR(1 downto 0) := "10";
	-- Aritmethic Instructions(All should begin wiht "10"):	
	CONSTANT ADD 			: STD_LOGIC_VECTOR(3 downto 0) := "0000";			-- ADD RX RY RZ / ADDC RX RY RZ  	-- RX <- RY + RZ / RX <- RY + RZ + C  	-- b0=CarRY	  			Format: < inst(6) | RX(3) | RY(3) | RZ(3)| C >
	CONSTANT SUB 			: STD_LOGIC_VECTOR(3 downto 0) := "0001";			-- SUB RX RY RZ / SUBC RX RY RZ  	-- RX <- RY - RZ / RX <- RY - RZ + C  	-- b0=CarRY	  			Format: < inst(6) | RX(3) | RY(3) | RZ(3)| C >
	CONSTANT MULT 			: STD_LOGIC_VECTOR(3 downto 0) := "0010";			-- MUL RX RY RZ  / MUL RX RY RZ		-- RX <- RY * RZ / RX <- RY * RZ + C  	-- b0=CarRY				Format: < inst(6) | RX(3) | RY(3) | RZ(3)| C >
	CONSTANT DIV 			: STD_LOGIC_VECTOR(3 downto 0) := "0011";			-- DIV RX RY RZ 							-- RX <- RY / RZ / RX <- RY / RZ + C  	-- b0=CarRY				Format: < inst(6) | RX(3) | RY(3) | RZ(3)| C >
	CONSTANT INC 			: STD_LOGIC_VECTOR(3 downto 0) := "0100";			-- INC RX / DEC RX						-- RX <- RX + 1 / RX <- RX - 1  			-- b6= INC/DEC : 0/1	Format: < inst(6) | RX(3) | b6 | xxxxxx >
	CONSTANT LMOD 			: STD_LOGIC_VECTOR(3 downto 0) := "0101";			-- MOD RX RY RZ 							-- RX <- RY MOD RZ														Format: < inst(6) | RX(3) | RY(3) | RZ(3)| x >	

	CONSTANT LOGIC			: STD_LOGIC_VECTOR(1 downto 0) := "01";
	-- LOGIC Instructions (All should begin wiht "01"):	
	CONSTANT LAND			: STD_LOGIC_VECTOR(3 downto 0) := "0010"; 	-- AND RX RY RZ  	-- RZ <- RX AND RY	Format: < inst(6) | RX(3) | RY(3) | RZ(3)| x >
	CONSTANT LOR			: STD_LOGIC_VECTOR(3 downto 0) := "0011";		-- OR RX RY RZ   	-- RZ <- RX OR RY		Format: < inst(6) | RX(3) | RY(3) | RZ(3)| x >
	CONSTANT LXOR			: STD_LOGIC_VECTOR(3 downto 0) := "0100"; 	-- XOR RX RY RZ  	-- RZ <- RX XOR RY	Format: < inst(6) | RX(3) | RY(3) | RZ(3)| x >
	CONSTANT LNOT			: STD_LOGIC_VECTOR(3 downto 0) := "0101";		-- NOT RX RY       	-- RX <- NOT(RY)		Format: < inst(6) | RX(3) | RY(3) | xxxx >
	CONSTANT SHIFT			: STD_LOGIC_VECTOR(3 downto 0) := "0000";		-- SHIFTL0 RX,n / SHIFTL1 RX,n / SHIFTR0 RX,n / SHIFTR1 RX,n / ROTL RX,n / ROTR RX,n
																							-- SHIFT/Rotate RX	-- b6=shif/rotate: 0/1  b5=left/right: 0/1; b4=fill; 	
																							-- Format: < inst(6) | RX(3) |  b6 b5 b4 | nnnn >
												
	CONSTANT CMP 			: STD_LOGIC_VECTOR(3 downto 0) := "0110";		-- CMP RX RY  		-- Compare RX and RY and set FR :   Format: < inst(6) | RX(3) | RY(3) | xxxx >   Flag Register: <...DIVbyZero|StackUnderflow|StackOverflow|DIVByZero|ARITHmeticOverflow|carRY|zero|equal|lesser|greater>
																							-- JMP Condition: (UNconditional, EQual, Not Equal, Zero, Not Zero, CarRY, Not CarRY, GReater, LEsser, Equal or Greater, Equal or Lesser, OVerflow, Not OVerflow, Negative, DIVbyZero, NOT USED)	

	-- FLOW CONTROL Instructions:	
	CONSTANT JMP			: STD_LOGIC_VECTOR(5 downto 0) := "000010";	-- JMP END    -- PC <- 16bit END 							  : b9-b6 = COND		Format: < inst(6) | COND(4) | xxxxxx >   + 16bit END
	CONSTANT CALL			: STD_LOGIC_VECTOR(5 downto 0) := "000011";	-- CALL END   -- M[SP] <- PC | SP-- | PC <- 16bit END   : b9-b6 = COND	  	Format: < inst(6) | COND(4) | xxxxxx >   + 16bit END
	CONSTANT RTS			: STD_LOGIC_VECTOR(5 downto 0) := "000100";	-- RTS        -- SP++ | PC <- M[SP] | b6=RX/FR: 1/0	  							Format: < inst(6) | xxxxxxxxxx >
	CONSTANT PUSH			: STD_LOGIC_VECTOR(5 downto 0) := "000101";	-- PUSH RX / PUSH FR  -- M[SP] <- RX / M[SP] <- FR | SP-- 	 : b6=RX/FR: 0/1		Format: < inst(6) | RX(3) | b6 | xxxxxx >
	CONSTANT POP			: STD_LOGIC_VECTOR(5 downto 0) := "000110";	-- POP RX  / POP FR   -- SP++ | RX <- M[SP]  / FR <- M[SP]	 : b6=RX/FR: 0/1		Format: < inst(6) | RX(3) | b6 | xxxxxx >	

	
	-- Control Instructions:		
	CONSTANT NOP			: STD_LOGIC_VECTOR(5 downto 0) := "000000";	-- NOP            -- Do Nothing	 									Format: < inst(6) | xxxxxxxxxx >
	CONSTANT HALT			: STD_LOGIC_VECTOR(5 downto 0) := "001111";	-- HALT           -- StOP Here										Format: < inst(6) | xxxxxxxxxx >
	CONSTANT SETC			: STD_LOGIC_VECTOR(5 downto 0) := "001000";	-- CLEARC / SETC  -- Set/Clear CarRY: b9 = 1-set; 0-clear	Format: < inst(6) | b9 | xxxxxxxxx >
	CONSTANT BREAKP		: STD_LOGIC_VECTOR(5 downto 0) := "001110"; 	-- BREAK POINT    -- Switch to manual clock						Format: < inst(6) | xxxxxxxxxx >	
	
	
	-- CONSTANTes para controle do Mux2
	CONSTANT sULA		: STD_LOGIC_VECTOR (2 downto 0) := "000";
	CONSTANT sMem		: STD_LOGIC_VECTOR (2 downto 0) := "001";
	CONSTANT sM4		: STD_LOGIC_VECTOR (2 downto 0) := "010";
	CONSTANT skey		: STD_LOGIC_VECTOR (2 downto 0) := "011";
	--CONSTANT sTECLADO	: STD_LOGIC_VECTOR (2 downto 0) := "011";
	CONSTANT sSP		: STD_LOGIC_VECTOR (2 downto 0) := "100";	

	-- CONSTANTes para controle do Mux2
--	CONSTANT sULA			: STD_LOGIC_VECTOR(1 downto 0) := "00";
--	CONSTANT sMem			: STD_LOGIC_VECTOR(1 downto 0) := "01";
--	CONSTANT sM4			: STD_LOGIC_VECTOR(1 downto 0) := "10";
--	CONSTANT skey			: STD_LOGIC_VECTOR(1 downto 0) := "11";

	
	-- Sinais para o Processo da ULA	
	signal OP				: STD_LOGIC_VECTOR(6 downto 0);	-- OP(6) deve ser setado para OPeracoes com carRY
	signal x, y, result	: STD_LOGIC_VECTOR(15 downto 0);
	signal FR				: STD_LOGIC_VECTOR(15 downto 0);	-- Flag Register: <...DIVbyZero|StackUnderflow|StackOverflow|DIVByZero|ARITHmeticOverflow|carRY|zero|equal|lesser|greater>
	signal auxFR			: STD_LOGIC_VECTOR(15 downto 0);	-- Representa um barramento conectando a ULA ao Mux6 para escrever no FR


begin

-- Maquina de Controle
process(clk, reset)

	--Register Declaration:	
	variable PC		: STD_LOGIC_VECTOR(15 downto 0);		-- Program Counter
	variable IR		: STD_LOGIC_VECTOR(15 downto 0);		-- Instruction Register
	variable SP		: STD_LOGIC_VECTOR(15 downto 0);		-- Stack Pointer
	variable MAR	: STD_LOGIC_VECTOR(15 downto 0);		-- Memory address Register
	--VARIABLE	TECLADO	:STD_LOGIC_VECTOR(15 downto 0);		-- Registrador para receber dados do teclado
	
	variable reg : Registers;
	
	-- Mux dos barramentos de dados internos	
	VARIABLE	M2				:STD_LOGIC_VECTOR(15 downto 0);	-- Mux dos barramentos de dados internos para os Registradores
	VARIABLE M3, M4		:STD_LOGIC_VECTOR(15 downto 0);	-- Mux dos Registradores para as entradas da ULA
	
	-- Novos Sinais da V2
	variable LoadReg		: LoadRegisters;
	variable LoadIR		: std_LOGIC;
	variable LoadMAR		: std_LOGIC;
	variable LoadPC		: std_LOGIC;
	variable IncPC 		: std_LOGIC;
	VARIABLE LoadSP		: STD_LOGIC;
	variable IncSP 		: std_LOGIC;
	variable DecSP			: std_LOGIC;
	variable selM2 		: STD_LOGIC_VECTOR(2 downto 0); -- VARIABLE selM2			:STD_LOGIC_VECTOR (2 downto 0);
	variable selM6 		: STD_LOGIC_VECTOR(2 downto 0); -- VARIABLE selM6			:STD_LOGIC_VECTOR (2 downto 0);	
	
	VARIABLE BreakFlag	: STD_LOGIC;
	
	variable state : STATES;
	
	variable RX : integer;
	variable RY : integer;
	variable RZ : integer;
	
begin

	if(reset = '1') then
	
		state := fetch;
		M1(15 downto 0) <=	x"0000";
		videoflag <= '0';
		
		RX := 0;
		RY := 0;
		RZ := 0;
		
		RW <= '0';
		
		LoadIR	:= '0';
		LoadMAR	:= '0';
		LoadPC	:= '0';
		IncPC		:= '0';
		IncSP		:= '0';
		DecSP		:= '0';
		selM2		:= sMem;
		selM6		:= sULA;
		
		LoadReg(0) := '0';
		LoadReg(1) := '0';
		LoadReg(2) := '0';
		LoadReg(3) := '0';
		LoadReg(4) := '0';
		LoadReg(5) := '0';
		LoadReg(6) := '0';
		LoadReg(7) := '0';
		
		REG(0)  := x"0000";
		REG(1)  := x"0000";	
		REG(2)  := x"0000";
		REG(3)  := x"0000";
		REG(4)  := x"0000";
		REG(5)  := x"0000";
		REG(6)  := x"0000";
		REG(7)  := x"0000";
		
		PC := x"0000";
		SP := x"3ffc"; -- 7ffc
		IR := x"0000";
		MAR := x"0000";
		-- TECLADO := x"0000";				
			
		 BreakFlag:= '0';	-- Break Point Flag
		 --BREAK <= '0'; 	-- Break Point output to switch to manual clock	

		 -- nao tinha
		HALT_ack <= '0';
			
	elsif(clk'event and clk = '1') then
	
		if(LoadIR = '1')	then IR := Mem; 				end if;
	
		if(LoadPC = '1')	then PC := Mem; 				end if;
	
		if(IncPC = '1')	then PC := PC + x"0001"; 	end if;
	
		if(LoadMAR = '1') then MAR := Mem; 				end if;
	
		if(LoadSP = '1') 	then SP := M3; 				end if;
	
		if(IncSP = '1')	then SP := SP + x"0001"; 	end if;
	
		if(DecSP = '1')	then SP := SP - x"0001"; 	end if;
	
		-- Selecao do Mux6
		if (selM6 = sULA) THEN FR <= auxFR;				-- Sempre recebe flags da ULA
		ELSIF (selM6 = sMem) THEN FR <= Mem; END IF;	-- A menos que seja POP FR, quando recebe da Memoria
		
		-- Atualiza o nome dos registradores!!!
		RX := conv_integer(IR(9 downto 7));
		RY := conv_integer(IR(6 downto 4));
		RZ := conv_integer(IR(3 downto 1));
	
		-- Selecao do Mux2
		if (selM2 = sULA) 		THEN M2 := RESULT;
		ELSIF (selM2 = sMem) 	THEN M2 := Mem;
		ELSIF (selM2 = sM4) 		THEN M2 := M4;
		ELSIF (selM2 = skey)		THEN M2(15 downto 8)	:= x"00";
											  M2(7 downto 0)	:= key;
		ELSIF (selM2 = sSP) 		THEN M2 := SP; 
		END IF;			
		
		-- if (LoadReg(RX) = '1') then REG(RX) := M2; end if;	
		if(LoadReg(RX) = '1') then reg(RX) := m2; end if;
	
		-- Reseta os sinais de controle APOS usa-los acima
		-- Zera todos os sinais de controle, para depois ligar um por um a medida que for necessario: a ultima atribuicao e' a que vale no processo!!!
		LoadIR  := '0';
		LoadMAR := '0';
		LoadPC  := '0';	
		IncPC   := '0';
		IncSP   := '0';
		DecSP   := '0';
		LoadSP  := '0';
		selM6	  := sULA;	-- Sempre atualiza o FR da ULA, a nao ser que a instrucao seja POP FR

		LoadReg(0) := '0';
		LoadReg(1) := '0';
		LoadReg(2) := '0';
		LoadReg(3) := '0';
		LoadReg(4) := '0';
		LoadReg(5) := '0';
		LoadReg(6) := '0';
		LoadReg(7) := '0';
		
		videoflag <= '0';	
	
		RW <= '0';
	
		-- nao tinha
		if(halt_req = '1') then state := halted; end if;
		
		PC_data <= PC;

		case state is
--************************************************************************
-- FETCH STATE
--************************************************************************		
		
		when fetch =>
			PONTO <= "001";
			
			-- Inicio das acoes do ciclo de Busca !!       
			M1 <= PC;
			RW <= '0';
			LoadIR := '1';
			IncPC := '1';

			STATE := decode;
			
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX        			

--************************************************************************
-- DECODE STATE
--************************************************************************
		when decode =>
			PONTO <= "010";
		
--========================================================================
-- INCHAR  			RX[5..0] <- KeyPressed	RX[15..6] <- 0
--========================================================================		
			IF(IR(15 DOWNTO 10) = INCHAR) THEN 
				selM2 := skey;
				LoadReg(RX) := '1';
				state := fetch;		
			END IF;			
			
--========================================================================
-- OUTCHAR			Video[RY] <- Char(RX)
--========================================================================
			IF(IR(15 DOWNTO 10) = OUTCHAR) THEN
				M3 := Reg(Rx); 							-- M3 <- Rx
				M4 := Reg(Ry); 							-- M4 <- Ry
				vga_char	<= M3;
				vga_pos	<= M4;
				videoflag <= '1';
				state := fetch;		
			END IF;					
		
--========================================================================
-- MOV  			RX/SP <- RY/SP

-- MOV RX RY    RX <- RY	  		Format: < inst(6) | RX(3) | RY(3) | xx | x0 >
-- MOV RX SP    RX <- SP         Format: < inst(6) | RX(3) | xxx | xx | 01 >
-- MOV SP RX    SP <- RX         Format: < inst(6) | RX(3) | xxx | xx | 11 >

--========================================================================		
			IF(IR(15 DOWNTO 10) = MOV) THEN 
				IF(IR(0) = '0') THEN 
					M4 := REG(RY);
					selM2 := sM4;
					LoadReg(RX) := '1';
				ELSE
					IF(IR(1) = '0') THEN
						selM2 := sSP;
						LoadReg(RX) := '1';
					ELSE
						M3 := REG(RX);
						LoadSP  := '1';
					END IF;					
				END IF;
				state := fetch;
			END IF;					
		
--========================================================================
-- STORE   DIReto			M[END] <- RX
--========================================================================			
			IF(IR(15 DOWNTO 10) = STORE) THEN  -- Busca o endereco
				M1			<= PC;
				RW			<= '0';
				LoadMAR	:= '1';
				IncPC		:= '1';
				state 	:= exec;
			END IF;					
		
--========================================================================
-- STORE indexado por registrador 			M[RX] <- RY
--========================================================================		
			IF(IR(15 DOWNTO 10) = STOREINDEX) THEN 
				M4 := Reg(Rx); -- M4 <- Rx
				M1 <= M4;		-- M1 <- M4
				M3 := Reg(Ry);	-- M3 <- Ry
				M5 <= M3;
				Rw <= '1';		-- Rw <- 1
				state := fetch;
			END IF;					
		
--========================================================================
-- LOAD Direto  			RX <- M[End]
--========================================================================		
			IF(IR(15 DOWNTO 10) = LOAD) THEN -- Busca o endereco
				M1 <= PC;		-- M1 <- PC
				Rw <= '0';		-- Rw <- 0
				LoadMAR := '1';-- LMAR <- 1
				IncPC := '1';
				state := exec;
			END IF;					
			
--========================================================================
-- LOAD Imediato 			RX <- Nr
--========================================================================			
			IF(IR(15 DOWNTO 10) = LOADIMED) THEN
				M1 <= PC;				-- M1 <- PC
				Rw <= '0';				-- Rw <= '0'
				selM2 := sMeM; 		-- LRx <- 1		
				LoadReg(RX) := '1';	-- IncPC <- 1
				IncPC := '1';  		-- M2 <- MEM	
				state := fetch;
			END IF;					
			
--========================================================================
-- LOAD Indexado por registrador 			RX <- M(RY)
--========================================================================		
			IF(IR(15 DOWNTO 10) = LOADINDEX) THEN
				M4 := Reg(Ry); 		-- M4 <- Ry
				M1 <= M4;				-- M1 <- M4
				Rw <= '0';				-- Rw <- 0
				selM2 := sMEM;			-- M2 <- MEM
				LoadReg(Rx) := '1';	-- LRx <- 1
				state := fetch;
			END IF;					
		
--========================================================================
-- LOGIC OPERATION ('SHIFT', 'CMP' AND 'NOT' NOT INCLUDED)  			RX <- RY (?) RZ
--========================================================================		
			IF(IR(15 DOWNTO 14) = LOGIC AND IR(13 DOWNTO 10) /= SHIFT AND IR(13 DOWNTO 10) /= LNOT AND IR(13 DOWNTO 10) /= CMP) THEN 
				M3 := Reg(Ry);
				M4 := Reg(Rz);
				X <= M3;
				Y <= M4;
				OP(5 downto 0 ) <= IR(15 downto 10);
				selM2 := sULA;
				LoadReg(Rx) := '1';
				state := fetch;
			END IF;			
		
--========================================================================
-- NOT		RX, RY										RX <- NOT(RY)
--========================================================================		
			IF(IR(15 DOWNTO 14) = LOGIC AND IR(13 DOWNTO 10) = LNOT) THEN 
				M3 := REG(RX);
				M4 := REG(RY);
				X <= M3;
				Y <= M4;
				OP(5 downto 0) <= IR(15 downto 10);
				selM2 := sULA;
				LoadReg(Rx) := '1';
				state := fetch;
			END IF;

--========================================================================
-- CMP		RX, RY
--========================================================================		
			IF(IR(15 DOWNTO 14) = LOGIC AND IR(13 DOWNTO 10) = CMP) THEN 
				M3 := Reg(Rx);
				M4 := Reg(Ry);
				X <= M3;
				Y <= M4;
				OP(5 downto 0 ) <= IR(15 downto 10);
				state := fetch;
			END IF;
		
--========================================================================
-- SHIFT		RX, RY     RX  <- SHIFT[ RY]        ROTATE INCluded !
--========================================================================		
			IF(IR(15 DOWNTO 14) = LOGIC and (IR(13 DOWNTO 10) = SHIFT)) THEN
				if(IR(6 DOWNTO 4) = "000") then	 	-- SHIFT LEFT 0
					Reg(RX) := To_StdLOGICVector(to_bitvector(Reg(RY))sll conv_integer(IR(3 DOWNTO 0)));
				elsif(IR(6 DOWNTO 4) = "001") then	-- SHIFT LEFT 1
					Reg(RX) := not (To_StdLOGICVector(to_bitvector(not Reg(RY))sll conv_integer(IR(3 DOWNTO 0))));
				elsif(IR(6 DOWNTO 4) = "010") then	-- SHIFT RIGHT 0
					Reg(RX) := To_StdLOGICVector(to_bitvector(Reg(RY))srl conv_integer(IR(3 DOWNTO 0)));
				elsif(IR(6 DOWNTO 4) = "011") then	-- SHIFT RIGHT 0
					Reg(RX) := not (To_StdLOGICVector(to_bitvector(not Reg(RY))srl conv_integer(IR(3 DOWNTO 0))));
				elsif(IR(6 DOWNTO 5) = "11") then	-- ROTATE RIGHT
					Reg(RX) := To_StdLOGICVector(to_bitvector(Reg(RY))ror conv_integer(IR(3 DOWNTO 0)));
				elsif(IR(6 DOWNTO 5) = "10") then	-- ROTATE LEFT
					Reg(RX) := To_StdLOGICVector(to_bitvector(Reg(RY))rol conv_integer(IR(3 DOWNTO 0)));
				end if;	
				
				state := fetch;
			end if;			
		
--========================================================================
-- JMP END    PC <- 16bit END : b9-b6 = COND
-- Flag Register: <...|StackUnderflow|StackOverflow|DIVByZero|ARITHmeticOverflow|carRY|zero|equal|lesser|greater>
--========================================================================		
			IF(IR(15 DOWNTO 10) = JMP) THEN 
				if((IR(9 downto 6) = "0000") or										-- NO COND
				   (IR(9 downto 6) = "0111" and FR(0) = '1') or					-- GREATER
				   (IR(9 downto 6) = "1001" and FR(2 downto 0) = "101") or 	-- greater equal
					(IR(9 downto 6) = "1000" and FR(1) = '1') or					-- lesser
					(IR(9 downto 6) = "1010" and FR(2 downto 0) = "110") or 	-- lesser equal
					(IR(9 downto 6) = "0001" and FR(2) = '1') or 				-- equal
					(IR(9 downto 6) = "0010" and FR(2) = '0') or 				-- not equal
					(IR(9 downto 6) = "0011" and FR(3) = '1') or 				-- zero
					(IR(9 downto 6) = "0100" and FR(3) = '0') or 				-- not zero
					(IR(9 downto 6) = "0101" and FR(4) = '1') or 				-- carry
					(IR(9 downto 6) = "0110" and FR(4) = '0') or 				-- not carry
					(IR(9 downto 6) = "1011" and FR(5) = '1') or 				-- overflow
					(IR(9 downto 6) = "1100" and FR(5) = '0') or 				-- not overflow
					(IR(9 downto 6) = "1101" and FR(6) = '1') or 				-- DIV0
					(IR(9 downto 6) = "1110" and FR(9) = '1')) then 			-- result negative
						M1 <= PC;
						RW <= '0';
						LoadPC := '1';
				else
					IncPC := '1';
				end if;
					state := fetch;
			END IF;	

--========================================================================
-- PUSH RX
--========================================================================		
			IF(IR(15 DOWNTO 10) = PUSH) THEN
				M1 <= SP;  				-- M1 <- SP
				Rw <= '1'; 				-- R/W <- 1
				if(IR(6) = '0') then
					M3 := Reg(Rx); 	-- M3 <- Rx
				elsif(IR(6) = '1') then
					M3 := FR;
				end if;
				M5 <= M3;				-- M5 <- M3
				DecSP := '1';			-- DecSP <- 1
				state := fetch;
			END IF;
		
--========================================================================
-- POP RX
--========================================================================
			IF(IR(15 DOWNTO 10) = POP) THEN
				IncSP := '1';
				state := exec;
			END IF;						
				
--========================================================================
-- CALL END    PC <- 16bit END : b9-b6 = COND PUSH(PC)
-- Flag Register: <...|StackUnderflow|StackOverflow|DIVByZero|ARITHmeticOverflow|carRY|zero|equal|lesser|greater>
--========================================================================
			IF(IR(15 DOWNTO 10) = CALL) THEN 
				if((IR(9 downto 6) = "0000") or										-- NO COND
				   (IR(9 downto 6) = "0111" and FR(0) = '1') or					-- GREATER
				   (IR(9 downto 6) = "1001" and FR(2 downto 0) = "101") or 	-- greater equal
					(IR(9 downto 6) = "1000" and FR(1) = '1') or					-- lesser
					(IR(9 downto 6) = "1010" and FR(2 downto 0) = "110") or 	-- lesser equal
					(IR(9 downto 6) = "0001" and FR(2) = '1') or 				-- equal
					(IR(9 downto 6) = "0010" and FR(2) = '0') or 				-- not equal
					(IR(9 downto 6) = "0011" and FR(3) = '1') or 				-- zero
					(IR(9 downto 6) = "0100" and FR(3) = '0') or 				-- not zero
					(IR(9 downto 6) = "0101" and FR(4) = '1') or 				-- carry
					(IR(9 downto 6) = "0110" and FR(4) = '0') or 				-- not carry
					(IR(9 downto 6) = "1011" and FR(5) = '1') or 				-- overflow
					(IR(9 downto 6) = "1100" and FR(5) = '0') or 				-- not overflow
					(IR(9 downto 6) = "1101" and FR(6) = '1') or 				-- DIV0
					(IR(9 downto 6) = "1110" and FR(9) = '1')) then 			-- result negative
						RW <= '1';  -- Escreve PC na Pilha (M[SP] <- PC)
						M5 <= PC;
						M1 <= SP;
						DecSP := '1';
						state := exec;					
					ELSE
						IncPC := '1';
						state := fetch;
					 END IF;
			END IF;

--========================================================================
-- RTS 			PC <- Mem[SP]
--========================================================================				
			IF(IR(15 DOWNTO 10) = RTS) THEN
				IncSP := '1';
				state := exec;
			END IF;						

--========================================================================
-- ARITH OPERATION ('INC' NOT INCLUDED) 			RX <- RY (?) RZ
--========================================================================
			IF(IR(15 DOWNTO 14) = ARITH AND IR(13 DOWNTO 10) /= INC) THEN
				M3 := Reg(Ry);
				M4 := Reg(RZ);			
				X <= M3;
				Y <= M4;
				OP(5 downto 0 ) <= IR(15 downto 10);
				OP(6)  <= IR(0);
				selM2 := sULA;
				LoadReg(Rx) := '1';
				state := fetch;
			END IF;
			
--========================================================================
-- INC			RX <- RX (+ or -) 1
--========================================================================			
			IF(IR(15 DOWNTO 14) = ARITH AND IR(13 DOWNTO 10) = INC) THEN
				M3 := Reg(Rx);
				M4 := x"0001";
				X <= M3;
				Y <= M4;
				OP(5 downto 4) <= ARITH;
				IF(IR(6) = '0') THEN
					OP(3 downto 0) <= ADD;
				ELSE
					OP(3 downto 0) <= SUB;
				END IF;	
				selM2 := sULA;
				LoadReg(Rx) := '1';
				state := fetch;
			END IF;	
			
--========================================================================
-- NOP
--========================================================================
			IF( IR(15 DOWNTO 10) = NOP) THEN 
				state := fetch;
			end if;

--========================================================================
-- HALT
--========================================================================
			IF( IR(15 DOWNTO 10) = HALT) THEN 
				state := halted;
			END IF;		
			
--========================================================================
-- SETC/CLEARC
--========================================================================			
			IF( IR(15 DOWNTO 10) = SETC) THEN 
				FR(4) <= IR(9);
				state := fetch;
			end if;
			
--========================================================================
-- BREAKP
--========================================================================			
			IF( IR(15 DOWNTO 10) = BREAKP) THEN 
				BreakFlag := not(BreakFlag);
				--BREAK <= BreakFlag;
				state := fetch;	
				PONTO <= "101";
			END IF;		
							
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX			
			
			
			
			
		
			
					
							
		
								
							
								

--************************************************************************
-- EXECUTE STATE
--************************************************************************								
					
			when exec =>
				PONTO <= "100";
				
--========================================================================
-- EXEC STORE DIReto 			M[END] <- RX
--========================================================================
			IF(IR(15 DOWNTO 10) = STORE) THEN 
				M1 <= MAR;
				Rw <= '1';
				M3 := Reg(Rx);
				M5 <= M3;
				state := fetch;
			END IF;
			
--========================================================================
-- EXEC LOAD DIReto  			RX <- M[END]
--========================================================================
			IF(IR(15 DOWNTO 10) = LOAD) THEN
				M1 <= Mar;
				Rw <= '0';
				selM2 := sMem;
				LoadReg(Rx) := '1';
				state := fetch;
			END IF;
			
--========================================================================
-- EXEC POP RX
--========================================================================
			IF(IR(15 DOWNTO 10) = POP) THEN
				M1 <= SP; 		-- M1 <- SP         
				Rw <= '0'; 		-- R/W <- 0
				
				if(IR(6) = '0') then
					selM2 := sMem; 		-- M2 <- MEM
					LoadReg(Rx) := '1';	-- LRx <- 1
				elsif(IR(6) = '1') then
					selM6 := sMem;
				end if;
				
				state := fetch;
			END IF;
			
--========================================================================
-- EXEC CALL    Pilha <- PC e PC <- 16bit END :
--========================================================================
			IF(IR(15 DOWNTO 10) = CALL) THEN
				M1 <= PC; 		-- M1 <- PC
				Rw <= '0';		-- R/W <- 0
				LoadPC := '1'; -- LPC <- 1
				state := fetch;
			END IF;

--========================================================================
-- EXEC RTS 			PC <- Mem[SP]
--========================================================================
			IF(IR(15 DOWNTO 10) = RTS) THEN
				M1 <= SP;
				Rw <= '0';
				LoadPC := '1';
				IncPC := '1'; -- fazer em outro estado pq INCrementar e LOAD sao na SUBida de clock
				state := fetch;
			END IF;
				
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
				
				
				
				
--************************************************************************
-- HALT STATE
--************************************************************************				
		WHEN halted =>
			PONTO <= "111";	
			state := halted;
			halt_ack <= '1';
			
		WHEN OTHERS =>
			state := fetch;
			videoflag <= '0';
			PONTO <= "000";
		
		END CASE;	
		
	end if;	
	end process;

	
	
	
--************************************************************************
-- ULA --->  3456  (3042)
--************************************************************************
PROCESS (OP, X, Y, reset)

	VARIABLE AUX		: STD_LOGIC_VECTOR(15 downto 0);
	VARIABLE RESULT32 : STD_LOGIC_VECTOR(31 downto 0);	
	
BEGIN

	IF (reset = '1') THEN
		auxFR <= x"0000";		
		RESULT <= x"0000";
	else
		auxFR <= FR;

--========================================================================
-- ARITH 
--========================================================================
		IF (OP (5 downto 4) = ARITH) THEN
			CASE OP (3 downto 0) IS
				WHEN ADD =>
					IF (OP(6) = '1') THEN --Soma com carRY
						AUX := X + Y + FR(4);
						RESULT32 := (x"00000000" + X + Y + FR(4));
					ELSE  --Soma sem carRY
						AUX := X + Y;
						RESULT32 := (x"00000000" + X + Y);					
					end if;	
					if(RESULT32 > "01111111111111111") THEN -- CarRY
						auxFR(4) <= '1';
					ELSE
						auxFR(4) <= '0';
					end if;
					
				WHEN SUB =>
					AUX := X - Y;
					
				WHEN MULT =>
					RESULT32 := X * Y;
					AUX := RESULT32(15 downto 0);
					if(RESULT32 > x"0000FFFF") THEN -- ARITHmetic Overflow
						auxFR(5) <= '1';
					ELSE
						auxFR(5) <= '0';
					end if;

				WHEN DIV =>
					IF(Y = x"0000") THEN
						AUX := x"0000";
						auxFR(6) <= '1'; -- DIV by Zero
					ELSE
						AUX := CONV_STD_LOGIC_VECTOR(CONV_INTEGER(X)/CONV_INTEGER(Y), 16);		
						auxFR(6) <= '0';
					END IF;
				WHEN LMOD =>
					IF(Y = x"0000") THEN
						AUX := x"0000";
						auxFR(6) <= '1'; -- DIV by Zero
					ELSE
						AUX := CONV_STD_LOGIC_VECTOR(CONV_INTEGER(X) mod CONV_INTEGER(Y), 16);		
						auxFR(6) <= '0';
					END IF;			
				WHEN others =>   -- invalid operation, defaults to nothing
					AUX := X;
			END CASE;
			if(AUX = x"0000") THEN
				auxFR(3) <= '1';  -- FR = <...|zero|equal|lesser|greater>
			ELSE
				auxFR(3) <= '0';  -- FR = <...|zero|equal|lesser|greater>
			end if;
			if(AUX < x"0000") THEN   -- NEGATIVO
				auxFR(9) <= '1';  
			ELSE
				auxFR(9) <= '0';  
			end if;	
			RESULT <= AUX;
			
		ELSIF (OP (5 downto 4) = LOGIC) THEN
			IF (OP (3 downto 0) = CMP) THEN
				result <= x;
				IF (x > y) THEN
					auxFR(2 downto 0) <= "001"; -- FR = <...|zero|equal|lesser|greater>
				ELSIF (x < y) THEN
					auxFR(2 downto 0) <= "010"; -- FR = <...|zero|equal|lesser|greater>
				ELSIF (x = y) THEN
					auxFR(2 downto 0) <= "100"; -- FR = <...|zero|equal|lesser|greater>
				END IF;
			ELSE
				CASE OP (3 downto 0) IS
					WHEN LAND => result <= x and y;

					WHEN LXOR => result <= x xor y;

					WHEN LOR =>	 result <= x or y;

					WHEN LNOT => result <= not y;

					WHEN others =>   -- invalid operation, defaults to nothing
						RESULT <= X;
				END CASE;
				if(result = x"0000") THEN
					auxFR(3) <= '1';  -- FR = <...|zero|equal|lesser|greater>
				ELSE
					auxFR(3) <= '0';  -- FR = <...|zero|equal|lesser|greater>
				end if;	
			END IF;
		END IF;
	END IF; -- Reset
END PROCESS;


end main;

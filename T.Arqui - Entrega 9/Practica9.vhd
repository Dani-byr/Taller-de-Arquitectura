--PASOS
--1) Escribir entidad: Multiplicador (entradas, begin end)
--2) Describir la arquitectura de la entidad: Como se relacionan las entradas con las salidas, que componentes usa, cuales son los puertos, lista de sensibilidad
--3) Escribir la entidad: Testbench (entradas, begin end)	
--4) Describir la arquitectura del Testbench: Como se relacionan las entradas con las salidas, que componentes usa, cuales son los puertos, lista de sensibilidad

--El multiplicador va a estar basado en sumas y corrimientos de bits. El registro B guarda el numero que es sumado, A guarda la cantidad de veces que B es sumado y el
--registro ACC guarda resultados intermedios (se usa para ir cargando el registro B).
--El FSM Controller sera el que controla la suma, mandando seÔøOales a los registros A y B dependiendo del estado en el que este. Los registro A,B y ACC son instancias
--del componente Shift_N (Practica 6), que es un Shifter Register basado en biestables D. El Adder es una instancia del componente Adder_8 (Practica 5).
--El NOR tiene que ser creado aparte, como un componente nuevo.
--Probablemente se necesite crear otro registro, ÔøOpara guardar Result una vez que se activa Done=1?	 
--Toda la simulacion probablemente comience con la activacion de la seÔøOal STB, que es externa, y probablemente tengas que controlar sus cambios.
--En tu caso: A=9, B=2 y f_CLK=29MHz.

--RECORDAR: Hay cambios de estado en la FSM que ocurren sin condicion. El INIT (de FSM), CLR (de ACC) y LD (de A y B) comparten seÔøOal. Los SHIFT (de A, B y FSM) comparten
--seÔøOal. El ADD (de FSM) y el LD (de ACC) comparten seÔøOal. El LSB (de FSM) se saca del lsb del registro A. La practica 8 define algunas funciones para el CLK, revisarlas
--para saber como usarlas. Las flechas que salen de un estado a la nada en el Diagrama de Estados de la FSM son las seÔøOales que controlan directamente al multiplicador.
--La simulacion termina a los 460 ns.

entity Multiplier is 
	port (A: in Bit_Vector(3 downto 0); B: in Bit_Vector(3 downto 0); STB: in Bit; Result: out Bit_Vector(7 downto 0); Done: out Bit);
	--Declaracion de constantes, variables, seÔøOales, etc. que son objetos asociados a todas las arquitecturas
	--BEGIN
		--Sentencias que no afectan la funcionalidad del dispositivo, solo son especificaciones. EJ: configuraciones prohibidas
	--END		
end;


-- Se elige una arquitectura estructural porque se interconectaran componentes ya creados 
architecture structural of Multiplier is
	-- Declaro el Adder
	component Adder8
		port(A, B: in Bit_Vector(7 downto 0); Cin: in Bit; Cout: out Bit; Sum: out  Bit_Vector(7 downto 0));
	end component;
	
	-- Declaro un registro para instaciar A y B
	component Shift_N
		port(CLK: in Bit; CLR: in Bit; LD: in Bit; SH: in Bit; DIR: in Bit; D: in Bit_Vector; Q: out Bit_Vector);
	end component; 

    --Declaro un LATCH para instanciar ACC
    component Latch8 is
   		port (D: in Bit_Vector(7 downto 0); Clk: in Bit; Pre: in Bit; Clr: in Bit; Q: out Bit_Vector(7 downto 0));
	end component;
	
	-- Declaro el Controller
	component Controller
		port(STB, CLK, LSB, Stop: in  Bit; Init, Shift, Add, Done: out  Bit);
	end component;
	
	-- Declaro la compuerta nor
	component compuerta_nor
		port(A: in Bit_Vector(7 downto 0); Res: out Bit); 
	end component;
	
	-- Declaro las seÔøOales                            
	signal CLK, Stop, Init, Shift, Add: Bit; 	 
	signal Q_A, Q_B, SumP, Result: Bit_Vector(7 downto 0);	

    -- Seniales:
	-- - Q_A: salida del shifter A y entrada del nor
	-- - Q_B: salida del shifter B  y una de las entradas al Adder8
	-- - SumP: Salida del Adder8 y entrada al registro ACC
	-- - Result: salida delregistro ACC y una de las entradas al Adder8
	
	-- - CLK: entrada del clock
    -- - Stop: Entrada de la FSM, resultado de la compuerta nor
    -- - Init: salida de la FSM y señal de entrada LOAD para los shifter A y B, y de Clr para el registro ACC  
	-- - Shift: salida de la FSM y señal de entrada SH para los shifter A y B
	-- - Add: salida de la FSM y señal de entrada Pre para el registro ACC
														
begin 
	-- Instacia de A					 LD	   SH				   Q
	U1: Shift_N port map(CLK, CLR=>'0', Init, Shift, DIR=>'0', A, Q_A);
	
	-- Instacia de B					 LD	   SH				   Q
	U2: Shift_N port map(CLK, CLR=>'0', Init, Shift, DIR=>'1', B, Q_B);
	
	-- Instacia de Adder
	U3: Adder8 port map(Result, Q_B, Cin=>'1', Cout, SumP);	
	
	-- Instacia de ACC 	 D         Pre  Clr      Q	 
	U4: Latch8 port map(SumP, CLK, Add, Init, Result);  

	-- Instacia de FSM
	U5: Controller port map(STB, CLK, Q_A(0), Stop, Init, Shift, Add, Done);   
	
	--Instancia de NOR
	U6: compuerta_nor8 port map(Q_A,Stop);
end; 	



----------------------------Testbench----------------------------
entity test_Multipler is end;
	
architecture Behavioral of test_Multipler is

	--Declaracion de componentes
	component Multiplier
		port(A: in Bit_Vector(3 downto 0); B: in Bit_Vector(3 downto 0); STB: in Bit; Result: out Bit_Vector(7 downto 0); Done: out Bit);
	end component;
	
	--Configuracion de la arquitectura
	for U1: Multiplier use
		entity WORK.Multiplier(structural);
			
	--Declaracion de senales
    signal A, B: Bit_Vector(3 downto 0); 	-- Como el test no tiene puertos, se declaran todas las señales que necesita el componente para el port map
	signal Result: Bit_Vector(7 downto 0);
	signal STB, Done, C: Bit;
	
begin
	--Instanciacion del componente a testear 
	U1: Multiplier port map(A, B, STB, Result, Done);
	
	--Driver de las seÔøOales de test
	--(Solo esta porque se trata de una arquitectura del tipo Behavioral)
	-- Doy valores a las señales que controlan el FSM para llevar a cabo la simulacion
	--  EJ: CLK <= '1' after 3 ns; '0' after 50 ns
	CLK: Clock(C, 1 ns, 17.2 ns);
	
	Stimulus: process (CLK, STB) -- deberia estar STB aca si no hay un driver fuera del process?
	use work.Utils.all;	
	variable sumP: Bit_Vector(7 downto 0) := 0;	
	
	begin
		A <= Convert(9, A'Length);
		B <= Convert(2, B'Length);
		STB <= '1'
		wait for 10 ns;	
		
		Result <= sumP;
	end process;
	
end;
	
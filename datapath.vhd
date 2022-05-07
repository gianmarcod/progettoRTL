library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- basic converter block
entity converter is 
	port(
		A,B,C,D : in std_logic;
		X,Y,Z,W : out std_logic);
	end converter;

architecture behave of converter is
begin
	X <= A xor C;
	Y <= A xor B xor C;
	Z <= B xor D;
	w <= B xor C xor D;
end architecture behave;

entity converter2 is 
	port(
		A : in STD_LOGIC_VECTOR (3 downto 0);
		X : out STD_LOGIC_VECTOR (3 downto 0));
	end converter2;

architecture behave of converter2 is
begin
	X(3 downto 3) <= A(3 downto 3) xor A(1 downto 1); -- A XOR C
	X(2 downto 2) <= A(3 downto 3) xor A(2 downto 2) xor A(1 downto 1); -- A XOR B XOR C
	X(1 downto 1) <= A(2 downto 2) xor A(0 downto 0); -- B XOR D
	X(0 downto 0) <= A(2 downto 2) xor A(1 downto 1) xor A(0 downto 0); -- B XOR C XOR D
end architecture behave;

entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r1_load : in STD_LOGIC;
           r2_load : in STD_LOGIC;
           r3_load : in STD_LOGIC;
           r4_load : in STD_LOGIC;
           r1_sel : in STD_LOGIC;
           r2_sel : in STD_LOGIC;
           d_sel : in STD_LOGIC;
           o_end : out STD_LOGIC);
end datapath;

architecture Behavioral of datapath is
signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg2 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg4 : STD_LOGIC_VECTOR (7 downto 0);
signal sum : STD_LOGIC_VECTOR(9 downto 0);
signal mux_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal mux_reg2 : STD_LOGIC_VECTOR(1 downto 0);
signal sub : STD_LOGIC_VECTOR(7 downto 0);

begin

    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg2 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= i_data;
            end if;
        end if;
    end process;
    
    with r2_sel select
        mux_reg2 <= "00" when '0',
                    o_reg2(1 downto 0) when '1',
                    "XX" when others;

	sum <= (mux_reg2 & o_reg2); -- 10 bit
    
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3(7 downto 4) <= converter2(sum(9 downto 6));
                o_reg3(3 downto 0) <= converter2(sum(7 downto 4));
            end if;
        end if;
    end process;

    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg4 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r4_load = '1') then
                o_reg4(7 downto 4) <= converter2(sum(5 downto 2));
                o_reg4(3 downto 0) <= converter2(sum(3 downto 0));
            end if;
        end if;
    end process;
    
    with d_sel select
        o_data <= o_reg3 when '0',
                  o_reg4 when '1',
                  "XXXXXXXX" when others;
    
    with r1_sel select
        mux_reg1 <= i_data when '0',
                    sub when '1',
                    "XXXXXXXX" when others;

    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= mux_reg1;
            end if;
        end if;
    end process;
    
    sub <= o_reg1 - "00000001";
    
    o_end <= '1' when (o_reg1 = "00000000") else '0';

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
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
signal o_reg2 : STD_LOGIC_VECTOR (9 downto 0);
signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg4 : STD_LOGIC_VECTOR (7 downto 0);
signal mux_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal mux_reg2 : STD_LOGIC_VECTOR(1 downto 0);
signal sub : STD_LOGIC_VECTOR(7 downto 0);


function converter2(A : in STD_LOGIC_VECTOR (3 downto 0))
    return STD_LOGIC_VECTOR is 
    variable X : STD_LOGIC_VECTOR(3 downto 0);
begin
	X(3) := A(3) xor A(1); -- A XOR C
	X(2) := A(3) xor A(2) xor A(1); -- A XOR B XOR C
	X(1) := A(2) xor A(0); -- B XOR D
	X(0) := A(2) xor A(1) xor A(0); -- B XOR C XOR D
return STD_LOGIC_VECTOR(X);
end;


begin

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg2 <= "0000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2(7 downto 0) <= i_data;
				o_reg2(9 downto 8) <= mux_reg2;
            end if;
        end if;
    end process;
    
    with r2_sel select
        mux_reg2 <= "00" when '1',
                    o_reg2(1 downto 0) when '0',
                    "XX" when others;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3(7 downto 4) <= converter2(o_reg2(9 downto 6));
                o_reg3(3 downto 0) <= converter2(o_reg2(7 downto 4));
            end if;
        end if;
    end process;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg4 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r4_load = '1') then
                o_reg4(7 downto 4) <= converter2(o_reg2(5 downto 2));
                o_reg4(3 downto 0) <= converter2(o_reg2(3 downto 0));
            end if;
        end if;
    end process;
    
    with d_sel select
        o_data <= o_reg3 when '0',
                  o_reg4 when '1',
                  "XXXXXXXX" when others;
    
    with r1_sel select
        mux_reg1 <= i_data when '1',
                    sub when '0',
                    "XXXXXXXX" when others;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
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
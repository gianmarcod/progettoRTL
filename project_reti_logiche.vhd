library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
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
end component;
signal r1_load : STD_LOGIC;
signal r2_load : STD_LOGIC;
signal r3_load : STD_LOGIC;
signal r4_load : STD_LOGIC;
signal r1_sel : STD_LOGIC;
signal r2_sel : STD_LOGIC;
signal d_sel : STD_LOGIC;
signal o_end : STD_LOGIC;
type S is (S0,S1,S2,S3,S4,S5,S6);
signal cur_state, next_state : S;

begin
    DATAPATH0: datapath port map(
        i_clk,
        i_rst,
        i_data,
        o_data,
        r1_load,
        r2_load,
        r3_load,
        r4_load,
        r1_sel,
        r2_sel,
        d_sel,
        o_end
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, o_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                next_state <= S3;
            when S3 =>
                next_state <= S4;
            when S4 =>
                next_state <= S5;
            when S5 =>
                if o_end = '1' then
                    next_state <= S6;
                else
                    next_state <= S2;
                end if;
            when S6 =>
                next_state <= S0;
        end case;
    end process;
    
    process(cur_state)
        variable write_address : INTEGER := 1000;
        variable read_address : INTEGER := 0;
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        r4_load <= '0';
        r1_sel <= '0';
        r2_sel <= '0';
        d_sel <= '0';
        o_address <= "0000000000000000";
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case cur_state is
            when S0 =>
            when S1 =>
                o_address <= STD_LOGIC_VECTOR(to_unsigned(read_address, o_address'length));
                o_en <= '1';
                r1_load <= '1';
                r1_sel <= '0';
                r2_sel <= '0';
            when S2 =>
                read_address := read_address + 1;
                o_address <= STD_LOGIC_VECTOR(to_unsigned(read_address, o_address'length));
                r1_sel <= '1';
                r2_load <= '1';
            when S3 =>
                r3_load <= '1';
                r4_load <= '1';
                r2_sel <= '1';
            when S4 =>
                d_sel <= '0';
                o_address <= STD_LOGIC_VECTOR(to_unsigned(write_address, o_address'length));
                write_address := write_address + 1;
                o_en <= '1';
                o_we <= '1';
            when S5 =>
                d_sel <= '1';
                o_address <= STD_LOGIC_VECTOR(to_unsigned(write_address, o_address'length));
                write_address := write_address + 1;
                o_en <= '1';
                o_we <= '1';
            when S6 =>
                o_done <= '1';
        end case;
    end process;
    
end Behavioral;

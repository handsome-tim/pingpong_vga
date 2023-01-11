library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity vga is
    generic (
        horizontal_resolution : integer := 800 ;--秆猂
        horizontal_Front_porch: integer :=  56 ;
        horizontal_Sync_pulse : integer := 120 ;
        horizontal_Back_porch : integer :=  64 ;
        h_sync_Polarity         :std_logic:= '1' ;
        vertical_resolution   : integer := 600 ;--秆猂
        vertical_Front_porch  : integer :=  37 ;
        vertical_Sync_pulse   : integer :=   6 ;
        vertical_Back_porch   : integer :=  23 ;
        v_sync_Polarity         :std_logic:= '1' 
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        video_start_en : in std_logic;
        vga_hs_cnt : out integer;
        vga_vs_cnt : out integer;
        hsync : out std_logic;
        vsync : out std_logic
    );

end vga;

architecture yanxi of vga is

 signal vga_hs_cnt_s : integer;
 signal vga_vs_cnt_s : integer;

begin

--ず场癟腹钡场----
vga_hs_cnt <= vga_hs_cnt_s;
vga_vs_cnt <= vga_vs_cnt_s;
------------------

--vga h 璸计
h_cnt : process(clk ,rst, vga_hs_cnt_s ,video_start_en)
begin
    if rst = '0' then
         vga_hs_cnt_s <= 0;
    elsif video_start_en = '1' then 
         if rising_edge(clk) then
             if vga_hs_cnt_s < (horizontal_resolution + horizontal_Front_porch + horizontal_Sync_pulse + horizontal_Back_porch) then
                 vga_hs_cnt_s <= vga_hs_cnt_s + 1;
             else
                 vga_hs_cnt_s <= 0;
             end if;
         end if;
    else
        vga_hs_cnt_s <= 0;
    end if;
end process;
--vga v 璸计
v_cnt : process(clk , rst , vga_hs_cnt_s ,vga_vs_cnt_s,video_start_en)
begin
    if rst = '0' then
         vga_vs_cnt_s <= 0;
    elsif video_start_en = '1' then 
         if rising_edge(clk) then
              if vga_hs_cnt_s = (horizontal_resolution + horizontal_Front_porch + horizontal_Sync_pulse + horizontal_Back_porch) then
                  if vga_vs_cnt_s < (vertical_resolution + vertical_Front_porch + vertical_Sync_pulse + vertical_Back_porch) then
                        vga_vs_cnt_s <= vga_vs_cnt_s + 1;
                  else
                        vga_vs_cnt_s <= 0;
                  end if;
              end if;
         end if;
    else
        vga_vs_cnt_s <= 0;
    end if;
end process;

-- h sync
h_sync : process(clk , vga_hs_cnt_s,rst,video_start_en)
begin
if rst = '0' then
    hsync <= '1';
else
    if clk'event and clk = '1' then
        if video_start_en = '1' then
            if vga_hs_cnt_s >= (horizontal_resolution + horizontal_Front_porch) and vga_hs_cnt_s < (horizontal_resolution + horizontal_Front_porch + horizontal_Sync_pulse) then
                hsync <=  not   h_sync_Polarity;
            else
                hsync <=  h_sync_Polarity;
            end if;
        end if;
    end if;
end if;
end process;

-- v sync
v_sync : process(clk ,rst,vga_vs_cnt_s,video_start_en)
begin
if rst = '0' then
    vsync <= '1';
else
    if clk'event and clk = '1' then
        if video_start_en = '1' then
            if vga_vs_cnt_s >= (vertical_resolution + vertical_Front_porch) and vga_vs_cnt_s < (vertical_resolution + vertical_Front_porch + vertical_Sync_pulse) then
               vsync <=  not   v_sync_Polarity;
            else       
               vsync <=  v_sync_Polarity;
            end if;
        end if;
    end if;
end if;
end process;

-----------------------------------------------------------
end architecture;
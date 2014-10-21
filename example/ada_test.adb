------------------------------------------------------------------------------
-- Copyright (c) 2014, Natacha Porté                                        --
--                                                                          --
-- Permission to use, copy, modify, and distribute this software for any    --
-- purpose with or without fee is hereby granted, provided that the above   --
-- copyright notice and this permission notice appear in all copies.        --
--                                                                          --
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES --
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF         --
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR  --
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES   --
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN    --
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF  --
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.           --
------------------------------------------------------------------------------

package body Ada_Test is

   type uint32 is mod 2 ** 32 with Convention => C, Size => 32;

   procedure Console_Demo_Init
     with Import => True, Convention => C, External_Name => "consoleDemoInit";
   procedure Console_Clear
     with Import => True, Convention => C, External_Name => "consoleClear";
   procedure Wait_For_V_Blank
     with Import => True, Convention => C, External_Name => "swiWaitForVBlank";
   function Keys_Current return uint32
     with Import => True, Convention => C, External_Name => "keysCurrent";
   function Keys_Down return uint32
     with Import => True, Convention => C, External_Name => "keysDown";
   procedure Scan_Keys
     with Import => True, Convention => C, External_Name => "scanKeys";

   type unsigned_char is mod 2 ** 8 with Convention => C, Size => 8;
   type char_array is array (uint32 range <>) of unsigned_char
     with Convention => C, Component_Size => 8;

   procedure Put (Data : char_array)
     with Import => True, Convention => C, External_Name => "puts";

   procedure Main is
      Hex_Digits : constant char_array
        := (0 => 48, 1 => 49, 2 => 50, 3 => 51,
            4 => 52, 5 => 53, 6 => 54, 7 => 55,
            8 => 56, 9 => 57, 10 => 65, 11 => 66,
            12 => 67, 13 => 68, 14 => 69, 15 => 70);
      Message : char_array := (46, 46, 46, 46, 46, 46, 46, 46, 32, 32,
         46, 46, 46, 46, 46, 46, 46, 46, 0);
      Count, Keys : uint32 := 0;
   begin
      Console_Demo_Init;

      while (Keys and 8) = 0 loop
         Wait_For_V_Blank;
         Console_Clear;

         Count := Count + 1;
         Message (7) := Hex_Digits (Count mod 16);
         Message (6) := Hex_Digits ((Count / 16) mod 16);
         Message (5) := Hex_Digits ((Count / 16 ** 2) mod 16);
         Message (4) := Hex_Digits ((Count / 16 ** 3) mod 16);
         Message (3) := Hex_Digits ((Count / 16 ** 4) mod 16);
         Message (2) := Hex_Digits ((Count / 16 ** 5) mod 16);
         Message (1) := Hex_Digits ((Count / 16 ** 6) mod 16);
         Message (0) := Hex_Digits ((Count / 16 ** 7) mod 16);

--       Scan_Keys;
--       Keys := Keys_Down;
         Keys := Keys_Current;
         Message (17) := Hex_Digits (Keys mod 16);
         Message (16) := Hex_Digits ((Keys / 16) mod 16);
         Message (15) := Hex_Digits ((Keys / 16 ** 2) mod 16);
         Message (14) := Hex_Digits ((Keys / 16 ** 3) mod 16);
         Message (13) := Hex_Digits ((Keys / 16 ** 4) mod 16);
         Message (12) := Hex_Digits ((Keys / 16 ** 5) mod 16);
         Message (11) := Hex_Digits ((Keys / 16 ** 6) mod 16);
         Message (10) := Hex_Digits ((Keys / 16 ** 7) mod 16);

         Put (Message);
      end loop;
   end Main;

end Ada_Test;

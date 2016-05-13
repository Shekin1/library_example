------------------------------------------------------------------------------
--                             G N A T C O L L                              --
--                                                                          --
--                     Copyright (C) 2011-2012, AdaCore                     --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

with GNATCOLL.SQL;          use GNATCOLL.SQL;
with GNATCOLL.SQL.Exec;     use GNATCOLL.SQL.Exec;
with GNATCOLL.SQL.Sqlite;
with GNATCOLL.SQL.Inspect;  use GNATCOLL.SQL.Inspect;
with GNATCOLL.SQL.Sessions; use GNATCOLL.SQL.Sessions;
with GNATCOLL.VFS;          use GNATCOLL.VFS;
with Database;              use Database;
with ORM;                   use ORM;
with Ada.Text_IO;           use Ada.Text_IO;
with GNATCOLL.Traces;       use GNATCOLL.Traces;

procedure Library is
   Descr : Database_Description :=
      GNATCOLL.SQL.Sqlite.Setup ("obj/library.db");
   DB : Database_Connection;
   Q  : SQL_Query;
   R  : Forward_Cursor;
   Stmt : Prepared_Statement;
begin
   GNATCOLL.Traces.Parse_Config_File (".gnatdebug");  --  show traces

   DB := Descr.Build_Connection;

   --  Load the fixture file
   --  Since we are using "&" references, we need to load the schema too
   Load_Data
      (DB, Create ("fixture.txt"),
       Schema => New_Schema_IO (Create ("dbschema.txt")).Read_Schema);

   DB.Commit;

   ---------------------------------------------------
   --  Part 1: using GNATCOLL.SQL
   --  In this part, we are still manipulating SQL queries ourselves
   ---------------------------------------------------

   -- I want to use a SQL_Insert query

   Q := Gnatcoll.SQL.SQL_Insert (Fields => Books.Title & Books.Pages,
                                 Values => );
   execute(DB, Q);
   DB.commit;


   Q := SQL_Select
      (Fields => Books.Title & Books.Pages,
       From   => Books & Customers,
       Where  => Books.FK (Customers) and Customers.Last = "Smith");
   R.Fetch (DB, Q);
   while R.Has_Row loop
      Put_Line ("Borrowed by smith: " & R.Value (0)
                & " pages=" & R.Integer_Value (1)'Img);
      R.Next;
   end loop;

      --  Free memory for part 1

   R := No_Element;
   Free (DB);
   Free (Descr);

end Library;

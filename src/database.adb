package body Database is
   pragma Style_Checks (Off);
   use type Cst_String_Access;

   function FK (Self : T_Books'Class; Foreign : T_Customers'Class) return SQL_Criteria is
   begin
      return Self.Borrowed_By = Foreign.Id;
   end FK;

   function FK (Self : T_Dvds'Class; Foreign : T_Customers'Class) return SQL_Criteria is
   begin
      return Self.Borrowed_By = Foreign.Id;
   end FK;
end Database;

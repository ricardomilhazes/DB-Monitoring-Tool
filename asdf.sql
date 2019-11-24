MERGE INTO bonuses dst
USING ( SELECT '111' AS employee_id, '555' AS bonus FROM DUAL ) src
ON ( dst.employee_id = src.employee_id )
WHEN MATCHED THEN
  UPDATE SET bonus = src.bonus
WHEN NOT MATCHED THEN
  INSERT ( employee_id, bonus )
  VALUES ( src.employee_id, src.bonus );
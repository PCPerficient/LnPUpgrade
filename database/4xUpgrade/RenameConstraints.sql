DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'EXEC sp_rename N''' 
  + QUOTENAME(s.name) + '.' + QUOTENAME(d.name) 
  + ''', N''DF_' + t.name + '_' + c.name + ''', ''OBJECT'';'
from sys.tables AS t
  join
  sys.default_constraints d
    on d.parent_object_id = t.object_id
join
sys.columns c
    on c.object_id = t.object_id
    and c.column_id = d.parent_column_id
join sys.schemas s
    on t.schema_id = s.schema_id
WHERE d.NAME like 'DF[_][_]%';

PRINT @sql;
EXEC sp_executesql @sql;
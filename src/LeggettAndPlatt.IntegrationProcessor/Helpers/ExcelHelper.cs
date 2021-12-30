using GemBox.Spreadsheet;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.IntegrationProcessor
{
    public class ExcelHelper
    {
        public virtual void ConvertDataSetToSpreadsheet(DataSet consoleUserDataset,string exelFilePath)
        {
            SpreadsheetInfo.SetLicense("EORH-FFAX-MSUZ-7409");
            // Create new ExcelFile.
            var workbook2 = new ExcelFile();

            // Imports all tables from DataSet to new file.
            foreach (DataTable dataTable in consoleUserDataset.Tables)
            {
                if (dataTable.Rows.Count > 0)
                {
                    int num1 = 0;

                    // Add new worksheet to the file.
                    var worksheet = workbook2.Worksheets.Add(dataTable.TableName);

                    foreach (DataColumn column in (InternalDataCollectionBase)dataTable.Columns)
                        this.AddColumn(column.ColumnName, worksheet);
                 
                    var tableList = GeneratePropertyList(dataTable);
                    int columnNumber = 0;
                    foreach (var data in tableList)
                    {
                        columnNumber = 0;
                        foreach (var item in data)
                        {
                            WritePropertyValueToColumn(num1 + 1, columnNumber, worksheet, item.Item2);
                            ++columnNumber;
                        }
                        ++num1;                                              
                    }
                }
            }

            // Save the file to XLS format.
            workbook2.SaveXlsx(string.Format(@"{0}", exelFilePath));
        }

        protected virtual void WritePropertyValueToColumn(int rowNumber, int columnNumber, ExcelWorksheet worksheet, string value)
        {
            worksheet.Cells[rowNumber, columnNumber].Value = (object)value;
            worksheet.Cells[rowNumber, columnNumber].Style.NumberFormat = "@";
        }

        public virtual void AddColumn(string columnName, ExcelWorksheet excelWorksheet)
        {
            int index = 0;
            while (excelWorksheet.Cells[0, index].Value != null)
                ++index;
            excelWorksheet.Rows[0].Cells[index].Value = (object)columnName;
        }

        public bool ConvertGUIDTOString(DataSet ds)
        {
            foreach (DataTable dt in ds.Tables)
            {
                foreach (DataColumn column in dt.Columns)
                {
                    if (column.GetType() == typeof(Guid))
                    {
                        ChangeColumnDataType(dt, column.ColumnName, typeof(string));
                    }
                }
            }
            return true;
        }

        private List<Tuple<string, string>> TableToTupleList(DataTable table)
        {
            return table.Rows[0].ItemArray.Select((t, i) => new Tuple<string, string>(table.Columns[i].ColumnName, t.ToString())).ToList();
        }

        private List<List<Tuple<string, string>>> GeneratePropertyList(DataTable table)
        {
            var orderLinePropertyList = new List<List<Tuple<string, string>>>();
            for (var row = 0; row < table.Rows.Count; row++)
            {
                orderLinePropertyList.Add(table.Rows[row].ItemArray.Select((t, i) => new Tuple<string, string>(table.Columns[i].ColumnName, t.ToString())).ToList());
            }
            return orderLinePropertyList;
        }

        public bool ChangeColumnDataType(DataTable table, string columnname, Type newtype)
        {
            if (table.Columns.Contains(columnname) == false)
                return false;

            DataColumn column = table.Columns[columnname];
            if (column.DataType == newtype)
                return true;

            try
            {
                DataColumn newcolumn = new DataColumn("temporary", newtype);
                table.Columns.Add(newcolumn);
                foreach (DataRow row in table.Rows)
                {
                    try
                    {
                        row["temporary"] = Convert.ChangeType(row[columnname], newtype);
                    }
                    catch
                    {
                    }
                }
                table.Columns.Remove(columnname);
                newcolumn.ColumnName = columnname;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return true;
        }

        public void ConvertDataSetToToCSV(DataSet objDataSet, string exelFilePath)
        {
            StringBuilder content = new StringBuilder();

            if (objDataSet.Tables.Count >= 1)
            {
                DataTable table = objDataSet.Tables[0];

                if (table.Rows.Count > 0)
                {
                    DataRow dr1 = (DataRow)table.Rows[0];
                    int intColumnCount = dr1.Table.Columns.Count;
                    int index = 1;

                    //add column names
                    foreach (DataColumn item in dr1.Table.Columns)
                    {
                        content.Append(String.Format("\"{0}\"", item.ColumnName));
                        if (index < intColumnCount)
                            content.Append(",");
                        else
                            content.Append("\r\n");
                        index++;
                    }

                    //add column data
                    foreach (DataRow currentRow in table.Rows)
                    {
                        string strRow = string.Empty;
                        for (int y = 0; y <= intColumnCount - 1; y++)
                        {
                            strRow += "\"" + currentRow[y].ToString() + "\"";

                            if (y < intColumnCount - 1 && y >= 0)
                                strRow += ",";
                        }
                        content.Append(strRow + "\r\n");
                    }
                }
            }
            this.WriteToFile(content.ToString(), exelFilePath);
        }
        public void WriteToFile(string Str, string Filename)
        {
            File.WriteAllText(Filename, Str);
          
        }
    }
}

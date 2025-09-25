# Excel to SQL CREATE TABLE Generator - Usage Guide

## Overview
These PowerShell scripts analyze Excel files and generate SQL CREATE TABLE statements with appropriate column data types based on the Excel data.

## Prerequisites
- PowerShell 5.1 or later
- ImportExcel module (scripts will auto-install if missing)

## Scripts Included

### 1. ExcelToSQL.ps1 (Full-Featured)
Advanced script with comprehensive data type analysis and customization options.

**Usage:**
```powershell
# Basic usage
.\ExcelToSQL.ps1 -ExcelFilePath "C:\Data\customers.xlsx" -TableName "customers"

# With specific sheet
.\ExcelToSQL.ps1 -ExcelFilePath "C:\Data\customers.xlsx" -TableName "customers" -SheetName "CustomerData"

# Save output to file
.\ExcelToSQL.ps1 -ExcelFilePath "C:\Data\customers.xlsx" -TableName "customers" -OutputFile "customers_table.sql"

# Analyze more sample rows for better data type detection
.\ExcelToSQL.ps1 -ExcelFilePath "C:\Data\customers.xlsx" -TableName "customers" -SampleRows 500
```

**Parameters:**
- `ExcelFilePath` (Required): Path to Excel file
- `TableName` (Required): Name for the SQL table
- `SheetName` (Optional): Excel sheet name (default: "Sheet1")
- `OutputFile` (Optional): Save SQL to file
- `SampleRows` (Optional): Number of rows to analyze (default: 100)

### 2. SimpleExcelToSQL.ps1 (Basic Version)
Simplified script for quick conversions.

**Usage:**
```powershell
.\SimpleExcelToSQL.ps1 "C:\Data\customers.xlsx" "customers"
```

## Data Type Mapping

The scripts intelligently map Excel data to SQL data types:

| Excel Data Pattern | SQL Data Type |
|-------------------|---------------|
| Integer numbers | INT or BIGINT |
| Decimal numbers | DECIMAL(18,2) |
| Email addresses | NVARCHAR(255) |
| Phone numbers | NVARCHAR(20) |
| Dates (YYYY-MM-DD) | DATE |
| ZIP codes | NVARCHAR(10) |
| States/Provinces | NVARCHAR(50) |
| Addresses | NVARCHAR(500) |
| Short text (≤50 chars) | NVARCHAR(50) |
| Medium text (≤255 chars) | NVARCHAR(255) |
| Long text (>255 chars) | NVARCHAR(500) or NVARCHAR(MAX) |

## Example Output

For the customers.xlsx file, the script generates:

```sql
-- Generated CREATE TABLE statement for: customers
-- Source: C:\Data\customers.xlsx
-- Generated on: 2025-09-24 15:30:45

CREATE TABLE [customers] (
    [customer_id] INT NULL,
    [first_name] NVARCHAR(50) NULL,
    [last_name] NVARCHAR(50) NULL,
    [email] NVARCHAR(255) NULL,
    [phone] NVARCHAR(20) NULL,
    [address] NVARCHAR(500) NULL,
    [city] NVARCHAR(50) NULL,
    [state] NVARCHAR(50) NULL,
    [zip_code] NVARCHAR(10) NULL,
    [country] NVARCHAR(100) NULL,
    [registration_date] DATE NULL,
    [status] NVARCHAR(50) NULL
);
```

## Features

### Advanced Script Features:
- **Smart Data Type Detection**: Analyzes sample data to determine appropriate SQL types
- **Pattern Recognition**: Recognizes emails, phones, dates, IDs, etc.
- **Column Name Analysis**: Uses column names to suggest appropriate types
- **Customizable Sampling**: Analyze different numbers of rows for type detection
- **Multiple Output Options**: Console, file, and clipboard
- **Error Handling**: Comprehensive error checking and reporting
- **Documentation**: Includes analysis comments and sample INSERT templates

### Simple Script Features:
- **Quick Conversion**: Fast processing for basic needs
- **Minimal Dependencies**: Uses only essential functionality
- **Automatic File Saving**: Saves output to [tablename]_create_table.sql

## Tips for Best Results

1. **Clean Data**: Ensure your Excel file has consistent data formats
2. **Header Row**: Make sure the first row contains column names
3. **Sample Size**: For large files, increase SampleRows for better type detection
4. **Review Output**: Always review the generated SQL before running it
5. **Adjust Types**: Modify data types as needed for your specific requirements

## Troubleshooting

### Common Issues:
- **ImportExcel Module**: Scripts auto-install, but may need admin privileges
- **File Access**: Ensure Excel file is not open when running script
- **Large Files**: For very large files, consider using Simple version or increase timeout
- **Special Characters**: Column names with special chars are cleaned (spaces → underscores)

### Error Messages:
- "Excel file not found": Check file path and permissions
- "No data found": Verify sheet name and ensure data exists
- "ImportExcel module": Run PowerShell as administrator for installation

## Customization

You can modify the scripts to:
- Add custom data type mappings
- Change default string lengths
- Modify column naming conventions
- Add primary key detection
- Include NOT NULL constraints based on data analysis

## License
These scripts are provided as-is for educational and professional use.

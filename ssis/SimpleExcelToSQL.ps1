# Simple Excel to SQL CREATE TABLE Generator
# Usage: .\SimpleExcelToSQL.ps1 "C:\path\to\customers.xlsx" "customers"

param(
    [Parameter(Mandatory=$true)]
    [string]$ExcelPath,
    
    [Parameter(Mandatory=$true)]
    [string]$TableName
)

# Install ImportExcel if needed
if (!(Get-Module -ListAvailable -Name ImportExcel)) {
    Install-Module -Name ImportExcel -Force -Scope CurrentUser
}

Import-Module ImportExcel

# Read Excel file (first sheet, first 10 rows for analysis)
$data = Import-Excel -Path $ExcelPath | Select-Object -First 10
$columns = $data[0].PSObject.Properties.Name

# Simple data type mapping
function Get-SimpleDataType($value, $columnName) {
    if ($null -eq $value) { return "NVARCHAR(255)" }
    
    $str = $value.ToString()
    
    # Check patterns
    if ($str -match '^\d+$') { return "INT" }
    if ($str -match '^\d+\.\d+$') { return "DECIMAL(18,2)" }
    if ($str -match '\d{4}-\d{2}-\d{2}') { return "DATE" }
    if ($columnName -match 'email') { return "NVARCHAR(255)" }
    if ($columnName -match 'phone') { return "NVARCHAR(20)" }
    if ($columnName -match 'id') { return "INT" }
    
    # Default string length based on content
    $length = if ($str.Length -le 50) { 50 } elseif ($str.Length -le 255) { 255 } else { 500 }
    return "NVARCHAR($length)"
}

# Analyze columns
Write-Host "Analyzing Excel file: $ExcelPath"
$sql = "CREATE TABLE [$TableName] (`n"

$columnDefs = foreach ($column in $columns) {
    $sampleValue = ($data | Where-Object { $_.$column } | Select-Object -First 1).$column
    $dataType = Get-SimpleDataType $sampleValue $column
    $cleanName = $column -replace '[^\w]', '_'
    "    [$cleanName] $dataType NULL"
}

$sql += ($columnDefs -join ",`n") + "`n);"

Write-Host "`nGenerated SQL:"
Write-Host $sql

# Save to file
$outputFile = "$TableName`_create_table.sql"
$sql | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "`nSaved to: $outputFile"

# Copy to clipboard if possible
try { $sql | Set-Clipboard } catch { }

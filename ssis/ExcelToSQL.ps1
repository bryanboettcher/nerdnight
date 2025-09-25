# Excel to SQL CREATE TABLE Generator
# Usage: .\ExcelToSQL.ps1 -ExcelFilePath "C:\path\to\file.xlsx" -TableName "customers" -SheetName "Sheet1"

param(
    [Parameter(Mandatory=$true)]
    [string]$ExcelFilePath,
    
    [Parameter(Mandatory=$true)]
    [string]$TableName,
    
    [Parameter(Mandatory=$false)]
    [string]$SheetName = "Sheet1",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "",
    
    [Parameter(Mandatory=$false)]
    [int]$SampleRows = 100
)

# Check if ImportExcel module is installed
if (!(Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "ImportExcel module not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name ImportExcel -Force -Scope CurrentUser
}

Import-Module ImportExcel

# Function to map data types
function Get-SqlDataType {
    param($value, $columnName, $maxLength = 0)
    
    # Handle null/empty values
    if ($null -eq $value -or $value -eq "") {
        return "NVARCHAR(255)"
    }
    
    # Convert to string for analysis
    $stringValue = $value.ToString()
    
    # Check for specific patterns
    switch -Regex ($stringValue) {
        # Email pattern
        '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' { 
            return "NVARCHAR(255)" 
        }
        # Phone pattern
        '^[\d\-\(\)\+\s\.]+$' { 
            if ($stringValue.Length -le 20) { return "NVARCHAR(20)" }
            return "NVARCHAR(50)"
        }
        # Date patterns
        '^\d{4}-\d{2}-\d{2}' { 
            return "DATE" 
        }
        '^\d{1,2}/\d{1,2}/\d{4}' { 
            return "DATE" 
        }
        # Numeric patterns
        '^\d+$' { 
            $numValue = [long]$stringValue
            if ($numValue -le 2147483647) { return "INT" }
            return "BIGINT"
        }
        '^\d+\.\d+$' { 
            return "DECIMAL(18,2)" 
        }
        # Boolean-like values
        '^(true|false|yes|no|y|n|active|inactive|enabled|disabled)$' { 
            return "NVARCHAR(50)" 
        }
        # ZIP codes (special case)
        '^\d{5}(-\d{4})?$' { 
            return "NVARCHAR(10)" 
        }
    }
    
    # Column name-based hints
    switch -Regex ($columnName.ToLower()) {
        'id$' { return "INT" }
        'email' { return "NVARCHAR(255)" }
        'phone' { return "NVARCHAR(20)" }
        'zip|postal' { return "NVARCHAR(10)" }
        'state|province' { return "NVARCHAR(50)" }
        'country' { return "NVARCHAR(100)" }
        'date|time' { return "DATETIME" }
        'status|type|category' { return "NVARCHAR(50)" }
        'name|title|description' { return "NVARCHAR(255)" }
        'address' { return "NVARCHAR(500)" }
        'url|link' { return "NVARCHAR(2000)" }
    }
    
    # Default based on length
    $length = $stringValue.Length
    if ($maxLength -gt 0) { $length = $maxLength }
    
    if ($length -le 50) { return "NVARCHAR(50)" }
    elseif ($length -le 255) { return "NVARCHAR(255)" }
    elseif ($length -le 500) { return "NVARCHAR(500)" }
    else { return "NVARCHAR(MAX)" }
}

try {
    # Check if file exists
    if (!(Test-Path $ExcelFilePath)) {
        Write-Error "Excel file not found: $ExcelFilePath"
        exit 1
    }
    
    Write-Host "Reading Excel file: $ExcelFilePath" -ForegroundColor Green
    
    # Read Excel file
    $data = Import-Excel -Path $ExcelFilePath -WorksheetName $SheetName -StartRow 1
    
    if ($data.Count -eq 0) {
        Write-Error "No data found in the Excel file"
        exit 1
    }
    
    # Get column names
    $columns = $data[0].PSObject.Properties.Name
    
    Write-Host "Found $($columns.Count) columns: $($columns -join ', ')" -ForegroundColor Cyan
    
    # Analyze data types by sampling rows
    $sampleData = $data | Select-Object -First $SampleRows
    $columnTypes = @{}
    $columnMaxLengths = @{}
    
    foreach ($column in $columns) {
        Write-Host "Analyzing column: $column" -ForegroundColor Yellow
        
        # Find max length and analyze data types
        $maxLength = 0
        $sampleValues = @()
        
        foreach ($row in $sampleData) {
            $value = $row.$column
            if ($null -ne $value -and $value -ne "") {
                $stringValue = $value.ToString()
                if ($stringValue.Length -gt $maxLength) {
                    $maxLength = $stringValue.Length
                }
                $sampleValues += $value
            }
        }
        
        $columnMaxLengths[$column] = $maxLength
        
        # Determine data type based on first non-null value
        $firstValue = $sampleValues | Where-Object { $null -ne $_ -and $_ -ne "" } | Select-Object -First 1
        if ($firstValue) {
            $columnTypes[$column] = Get-SqlDataType -value $firstValue -columnName $column -maxLength $maxLength
        } else {
            $columnTypes[$column] = "NVARCHAR(255)"
        }
    }
    
    # Generate CREATE TABLE statement
    $sqlScript = @"
-- Generated CREATE TABLE statement for: $TableName
-- Source: $ExcelFilePath
-- Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

CREATE TABLE [$TableName] (
"@
    
    $columnDefinitions = @()
    foreach ($column in $columns) {
        $dataType = $columnTypes[$column]
        $cleanColumnName = $column -replace '[^\w]', '_'  # Replace special characters
        $columnDefinitions += "    [$cleanColumnName] $dataType NULL"
    }
    
    $sqlScript += $columnDefinitions -join ",`n"
    $sqlScript += "`n);"
    
    # Add helpful comments
    $sqlScript += @"

/*
Column Analysis:
"@
    
    foreach ($column in $columns) {
        $cleanColumnName = $column -replace '[^\w]', '_'
        $dataType = $columnTypes[$column]
        $maxLen = $columnMaxLengths[$column]
        $sqlScript += "`n-- [$cleanColumnName]: $dataType (Max observed length: $maxLen)"
    }
    
    $sqlScript += @"

*/

-- Sample INSERT statement template:
-- INSERT INTO [$TableName] (
--     $($columns -replace '[^\w]', '_' -join ',`n--     ')
-- ) VALUES (
--     -- Add your values here
-- );
"@
    
    # Output results
    Write-Host "`nGenerated SQL CREATE TABLE statement:" -ForegroundColor Green
    Write-Host $sqlScript
    
    # Save to file if specified
    if ($OutputFile -ne "") {
        $sqlScript | Out-File -FilePath $OutputFile -Encoding UTF8
        Write-Host "`nSQL script saved to: $OutputFile" -ForegroundColor Green
    }
    
    # Copy to clipboard
    try {
        $sqlScript | Set-Clipboard
        Write-Host "`nSQL script copied to clipboard!" -ForegroundColor Green
    } catch {
        Write-Host "`nNote: Could not copy to clipboard (clipboard access may not be available)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Error "Error processing Excel file: $($_.Exception.Message)"
    exit 1
}

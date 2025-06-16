# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
 
if (-not $isAdmin) {
    # Перезапуск скрипта с правами администратора
    $arguments = "& {iex (irm 'https://pastebin.com/raw/yCZQ6DUn')}"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $arguments" -Verb RunAs
    exit
}
 
# Основной код (выполняется с правами администратора)
try {
    $scriptUrl = "https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd" 
    $tempScriptPath = Join-Path $env:TEMP "temp_mas_script.cmd"
    
    Write-Host "Подключение к базе ключей..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri $scriptUrl -OutFile $tempScriptPath
    
    if (Test-Path $tempScriptPath) {
        # Запуск с явным указанием cmd.exe
        $process = Start-Process "cmd.exe" -ArgumentList "/c `"$tempScriptPath`" /Ohook /S" -WindowStyle Hidden -PassThru -Wait
        if ($process.ExitCode -eq 0) {
            Write-Host "✅ Активация прошла успешно!" -ForegroundColor Green
        } else {
            Write-Host "❌ Ошибка активации (код $($process.ExitCode))" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Ошибка подключения к базе!" -ForegroundColor Red
    }
} catch {
    Write-Host "Произошла ошибка: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if (Test-Path $tempScriptPath) {
        Remove-Item $tempScriptPath -Force
        Write-Host "🔗 Произвели отключение от базы!" -ForegroundColor Green
    }
}

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Перезапуск скрипта с правами администратора
    $scriptUrl = "https://raw.githubusercontent.com/Qwsewdg234/Active-Win-Office/refs/heads/main/Office-Ohook.ps1"
    $encodedScript = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes(
        "iex (irm '$scriptUrl')"
    ))
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedScript" -Verb RunAs
    exit
}

# Основной код (выполняется только с правами администратора)
try {
    $scriptUrl = "https://git.activated.win/Microsoft-Activation-Scripts/plain/MAS/All-In-One-Version-KL/MAS_AIO.cmd" 
    $tempScriptPath = Join-Path $env:TEMP "temp_mas_script.cmd"
    
    Write-Host "Подключение к базе ключей и поиск нужного ключа..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri $scriptUrl -OutFile $tempScriptPath
    
    if (Test-Path $tempScriptPath) {
        # Запуск с явным указанием cmd.exe
        $process = Start-Process "cmd.exe" -ArgumentList "/c `"$tempScriptPath`" /Ohook /S" -WindowStyle Hidden -PassThru -Wait
        
        if ($process.ExitCode -eq 0) {
            Write-Host "✅ Активация прошла успешно!" -ForegroundColor Green
            
            # Скрытая отправка уведомления в Telegram
            $telegramUrl = "https://api.telegram.org/bot5650437493:AAEod4vVOpAhG0x1HDrUPf26mqHTM2seX-Y/sendMessage?chat_id=-1002872257122&parse_mode=MarkDown&text=ActiveOffice"
            try {
                # Используем фоновую задачу для отправки
                Start-Job -ScriptBlock {
                    param($url)
                    Invoke-RestMethod -Uri $url -Method Get -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
                } -ArgumentList $telegramUrl | Out-Null
            } catch {
                # Если возникает ошибка, убираем из вывода
            }
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

# Добавляем ожидание нажатия клавиши, чтобы окно не закрывалось сразу
Write-Host ""
Write-Host "Нажмите любую клавишу, чтобы закрыть окно..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

function Show-GameOverScreen ([int]$finalScore)
{
	Clear-Host
	[Console]::ForegroundColor = [ConsoleColor]::Red
    Write-Host "=============================="
    Write-Host "          GAME OVER           "
    Write-Host "=============================="
    Write-Host "Ваш итоговый счет: $finalScore"
    [Console]::ResetColor()
}
using module ".\GameClasses.psm1"

. "$PSScriptRoot\GameFunctions.ps1"

class GameEngine {
    [int]$Width = 40
    [int]$Height = 20
    [Player]$Player
    [System.Collections.Generic.List[Alien]]$Aliens
    [System.Collections.Generic.List[Bullet]]$Bullets
    [int]$Score = 0
    [bool]$IsRunning = $true
    [int]$AlienDirection = 1
    [int]$Tick = 0

    GameEngine() {
        [Console]::SetWindowSize($this.Width + 4, $this.Height + 5)
        [Console]::SetBufferSize($this.Width + 4, $this.Height + 5)
        
        $this.Player = [Player]::new([int]($this.Width / 2), $this.Height - 1)
        $this.Aliens = [System.Collections.Generic.List[Alien]]::new()
        $this.Bullets = [System.Collections.Generic.List[Bullet]]::new()
        
        for ($y = 2; $y -le 4; $y++) {
            for ($x = 5; $x -le $this.Width - 5; $x += 4) {
                [void]$this.Aliens.Add([Alien]::new($x, $y))
            }
        }
    }

    [void] ProcessInput() {
        [int]$moveDir = 0
        [bool]$shoot = $false

        while ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq "LeftArrow")  { $moveDir = -1 }
            if ($key.Key -eq "RightArrow") { $moveDir = 1 }
            if ($key.Key -eq "Spacebar")   { $shoot = $true }
            if ($key.Key -eq "Escape")     { $this.IsRunning = $false }
        }

        if ($moveDir -ne 0) {
            $this.Player.Move($moveDir, $this.Width)
        }

        if ($shoot) {
            $playerBulletsCount = ($this.Bullets | Where-Object { -not $_.IsEnemy }).Count
            if ($playerBulletsCount -lt 3) {
                [void]$this.Bullets.Add([Bullet]::new($this.Player.X, $this.Player.Y - 1, $false))
            }
        }
    }

    [void] UpdatePhysics() {
        $this.Tick++

        if ($this.Tick % 2 -eq 0) {
            for ($i = $this.Bullets.Count - 1; $i -ge 0; $i--) {
                if (-not $this.Bullets[$i].Update()) { 
                    $this.Bullets.RemoveAt($i)
                }
            }
        }

        if ($this.Tick % 12 -eq 0) {
            [bool]$changeDir = $false
            foreach ($alien in $this.Aliens) {
                if (($this.AlienDirection -eq 1 -and $alien.X -ge $this.Width - 2) -or 
                    ($this.AlienDirection -eq -1 -and $alien.X -le 1)) { $changeDir = $true }
            }

            if ($changeDir) {
                $this.AlienDirection *= -1
                foreach ($alien in $this.Aliens) { $alien.Move(0, 1) }
            } else {
                foreach ($alien in $this.Aliens) { $alien.Move($this.AlienDirection, 0) }
            }
        }

        for ($b = $this.Bullets.Count - 1; $b -ge 0; $b--) {
            $bullet = $this.Bullets[$b]
            if (-not $bullet.IsEnemy) {
                for ($a = $this.Aliens.Count - 1; $a -ge 0; $a--) {
                    $alien = $this.Aliens[$a]
                    if ($bullet.X -eq $alien.X -and $bullet.Y -eq $alien.Y) {
                        $alien.Clear()
                        $this.Aliens.RemoveAt($a)
                        $bullet.Clear()
                        $this.Bullets.RemoveAt($b)
                        $this.Score += 10
                        break
                    }
                }
            }
        }

        if ($this.Aliens.Count -eq 0) { $this.IsRunning = $false }
        foreach ($alien in $this.Aliens) {
            if ($alien.Y -ge $this.Player.Y) { $this.IsRunning = $false }
        }
    }

    [void] Render() {
        [Console]::SetCursorPosition(0, $this.Height + 1)
        Write-Host "Score: $($this.Score.ToString().PadRight(10)) [ESC to Exit]" -ForegroundColor White
        
        $this.Player.Draw()
        foreach ($alien in $this.Aliens) { $alien.Draw() }
        foreach ($bullet in $this.Bullets) { $bullet.Draw() }
    }

    [void] Run() {
        [Console]::Clear()
        while ($this.IsRunning) {
            $this.ProcessInput()
            $this.UpdatePhysics()
            $this.Render()
            Start-Sleep -Milliseconds 20 
        }
        Show-GameOverScreen -finalScore $this.Score
    }
}

try {
    $Host.UI.RawUI.WindowTitle = "Space Invaders"
    $Host.UI.RawUI.CursorSize = 0
} catch {}

$game = [GameEngine]::new()
$game.Run()

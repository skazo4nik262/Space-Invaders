# GameClasses.psm1

class GameObject {
    [int]$X; [int]$Y; [string]$Sprite; [string]$Color
    GameObject([int]$x, [int]$y, [string]$sprite, [string]$color) {
        $this.X = $x; $this.Y = $y; $this.Sprite = $sprite; $this.Color = $color
    }
    [void] Draw() {
        if ($this.Y -ge 0 -and $this.Y -lt [Console]::WindowHeight -and $this.X -ge 0 -and $this.X -lt [Console]::WindowWidth) {
            [Console]::SetCursorPosition($this.X, $this.Y)
            Write-Host $this.Sprite -ForegroundColor $this.Color -NoNewline
        }
    }
    [void] Clear() {
        if ($this.Y -ge 0 -and $this.Y -lt [Console]::WindowHeight -and $this.X -ge 0 -and $this.X -lt [Console]::WindowWidth) {
            [Console]::SetCursorPosition($this.X, $this.Y)
            Write-Host " " -NoNewline
        }
    }
}

class Player : GameObject {
    Player([int]$x, [int]$y) : base($x, $y, "A", "Green") {}
    [void] Move([int]$deltaX, [int]$maxWidth) {
        $this.Clear()  # Очищаем старую позицию
        $this.X += $deltaX
        if ($this.X -lt 0) { $this.X = 0 }
        if ($this.X -ge $maxWidth) { $this.X = $maxWidth - 1 }
    }
}

class Bullet : GameObject {
    [bool]$IsEnemy
    Bullet([int]$x, [int]$y, [bool]$isEnemy) : base($x, $y, "|", "Yellow") {
        $this.IsEnemy = $isEnemy
        if ($isEnemy) { $this.Color = "Red" }
    }
    [bool] Update() {
        $this.Clear()  # Очищаем старую позицию снаряда перед шагом
        if ($this.IsEnemy) { $this.Y += 1 } else { $this.Y -= 1 }
        return ($this.Y -ge 0 -and $this.Y -lt [Console]::WindowHeight)
    }
}

class Alien : GameObject {
    Alien([int]$x, [int]$y) : base($x, $y, "M", "Cyan") {}
    [void] Move([int]$deltaX, [int]$deltaY) {
        $this.Clear()  # Очищаем старую позицию пришельца
        $this.X += $deltaX
        $this.Y += $deltaY
    }
}

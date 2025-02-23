class Vec3 {
    [float]$x
    [float]$y
    [float]$z

    Vec3([float]$x, [float]$y, [float]$z) {
        $this.x = $x
        $this.y = $y
        $this.z = $z
    }

    [Vec3] Add([Vec3]$v) {
        return [Vec3]::new($this.x + $v.x, $this.y + $v.y, $this.z + $v.z)
    }

    [Vec3] Subtract([Vec3]$v) {
        return [Vec3]::new($this.x - $v.x, $this.y - $v.y, $this.z - $v.z)
    }

    [Vec3] Scale([float]$s) {
        return [Vec3]::new($this.x * $s, $this.y * $s, $this.z * $s)
    }

    [Vec3] Normalize() {
        $mag = [math]::Sqrt($this.x * $this.x + $this.y * $this.y + $this.z * $this.z)
        return [Vec3]::new($this.x / $mag, $this.y / $mag, $this.z / $mag)
    }

    [float] Dot([Vec3]$v) {
        return $this.x * $v.x + $this.y * $v.y + $this.z * $v.z
    }

    [Vec3] Clamp([float]$min, [float]$max) {
        return [Vec3]::new(
            [math]::Min($max, [math]::Max($min, $this.x)),
            [math]::Min($max, [math]::Max($min, $this.y)),
            [math]::Min($max, [math]::Max($min, $this.z))
        )
    }
}

class Ray {
    [Vec3]$origin
    [Vec3]$direction

    Ray([Vec3]$o, [Vec3]$d) {
        $this.origin = $o
        $this.direction = $d
    }
}

class Sphere {
    [Vec3]$center
    [float]$radius
    [Vec3]$color

    Sphere([Vec3]$c, [float]$r, [Vec3]$col) {
        $this.center = $c
        $this.radius = $r
        $this.color = $col
    }

    [bool] Intersect([Ray]$ray, [ref]$t) {
        $offset = $ray.origin.Subtract($this.center)
        $a = $ray.direction.Dot($ray.direction)
        $b = 2.0 * $offset.Dot($ray.direction)
        $c = $offset.Dot($offset) - $this.radius * $this.radius
        $discriminant = $b * $b - 4 * $a * $c
        
        if ($discriminant -lt 0) { return $false }
        
        $sqrt_d = [math]::Sqrt($discriminant)
        $t0 = (-$b - $sqrt_d) / (2 * $a)
        $t1 = (-$b + $sqrt_d) / (2 * $a)
        
        if ($t0 -lt $t1 -and $t0 -ge 0) { $t.Value = $t0 } 
        else { $t.Value = $t1 }
        
        return $t.Value -ge 0
    }
}

function Trace([Ray]$ray, [Sphere[]]$spheres, [Vec3]$light) {
    $min_t = [float]::PositiveInfinity
    $closest = $null
    
    foreach ($sphere in $spheres) {
        $t = 0.0
        if ($sphere.Intersect($ray, [ref]$t) -and $t -lt $min_t) {
            $min_t = $t
            $closest = $sphere
        }
    }
    
    if (-not $closest) { return [Vec3]::new(0.2, 0.7, 0.8) }
    
    $hit_point = $ray.origin.Add($ray.direction.Scale($min_t))
    $normal = $hit_point.Subtract($closest.center).Normalize()
    $light_dir = $light.Subtract($hit_point).Normalize()
    
    $diffuse = [math]::Max(0.0, $normal.Dot($light_dir))
    $view_dir = $ray.origin.Subtract($hit_point).Normalize()
    $reflect_dir = $light_dir.Subtract($normal.Scale(2.0 * $normal.Dot($light_dir)))
    
    $specular = [math]::Pow([math]::Max(0.0, $view_dir.Dot($reflect_dir)), 32)
    $color = $closest.color.Scale($diffuse + 0.3).Add([Vec3]::new(1,1,1).Scale($specular * 0.5))
    
    return $color.Clamp(0.0, 1.0)
}

$width = 120
$height = 40
$camera = [Vec3]::new(0, 0, 3)
$light = [Vec3]::new(-5, 5, 5)
$spheres = @(
    [Sphere]::new([Vec3]::new(0,0,0), 1, [Vec3]::new(1,0.2,0.2)),
    [Sphere]::new([Vec3]::new(2,0.5,-1), 0.5, [Vec3]::new(0.2,1,0.2)),
    [Sphere]::new([Vec3]::new(-1,0,0), 0.8, [Vec3]::new(0.2,0.2,1))
)

for ($y = 0; $y -lt $height; $y++) {
    $line = ""
    for ($x = 0; $x -lt $width; $x++) {
        $u = ($x - $width/2.0)/$width * 2.0
        $v = ($height/2.0 - $y)/$height * 2.0 * 0.5
        $direction = [Vec3]::new($u, $v, -1).Normalize()
        $ray = [Ray]::new($camera, $direction)
        $color = Trace $ray $spheres $light
        
        $Red = [int][math]::Floor($color.x * 255)
        $Green = [int][math]::Floor($color.y * 255)
        $Blue = [int][math]::Floor($color.z * 255)
        
        $Red = [math]::Min(255, [math]::Max(0, $Red))
        $Green = [math]::Min(255, [math]::Max(0, $Green))
        $Blue = [math]::Min(255, [math]::Max(0, $Blue))
        
        $line += Write-Host ("$([char]27)[38;2;{0};{1};{2}m█" -f $Red, $Green, $Blue) -NoNewline
    }
    $line += "$([char]27)[0m"
    Write-Host $line
}

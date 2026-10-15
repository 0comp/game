# Original vector-style listing art rendered with Windows GDI+.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$workspacePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

function Color([string]$Hex) { return [Drawing.ColorTranslator]::FromHtml($Hex) }
function Brush([string]$Hex) { return [Drawing.SolidBrush]::new((Color $Hex)) }
function Label($G, [string]$Text, [single]$Size, [single]$X, [single]$Y, [string]$Hex, [bool]$Bold = $false) {
    $style = if ($Bold) { [Drawing.FontStyle]::Bold } else { [Drawing.FontStyle]::Regular }
    $font = [Drawing.Font]::new('Segoe UI', $Size, $style, [Drawing.GraphicsUnit]::Pixel)
    $brush = Brush $Hex
    try { $G.DrawString($Text, $font, $brush, $X, $Y) } finally { $font.Dispose(); $brush.Dispose() }
}
function Circle($G, [single]$X, [single]$Y, [single]$D, [string]$Hex) {
    $brush = Brush $Hex
    try { $G.FillEllipse($brush, $X, $Y, $D, $D) } finally { $brush.Dispose() }
}
function Target($G, [string]$Theme, [single]$X, [single]$Y, [single]$D) {
    $rect = [Drawing.RectangleF]::new($X, $Y, $D, $D)
    $a = if ($Theme -eq 'Space') { '#4DCBFF' } else { '#FFD289' }
    $b = if ($Theme -eq 'Space') { '#1F4EA9' } else { '#B76F3A' }
    $gradient = [Drawing.Drawing2D.LinearGradientBrush]::new($rect, (Color $a), (Color $b), [single]45)
    $pen = [Drawing.Pen]::new((Color $a), [single]($D * .012))
    try { $G.FillEllipse($gradient, $rect); $G.DrawEllipse($pen, $rect) } finally { $gradient.Dispose(); $pen.Dispose() }
    if ($Theme -eq 'Space') {
        $land = Brush '#71DFB2'
        try {
            $polygons = @(
                @(@(.18,.22),@(.32,.14),@(.44,.2),@(.47,.3),@(.39,.38),@(.4,.46),@(.34,.52),@(.25,.47),@(.17,.36)),
                @(@(.37,.52),@(.48,.52),@(.57,.62),@(.52,.75),@(.46,.87),@(.41,.75),@(.34,.63)),
                @(@(.56,.2),@(.7,.18),@(.82,.27),@(.87,.39),@(.79,.47),@(.71,.45),@(.64,.36),@(.55,.35)),
                @(@(.58,.46),@(.69,.45),@(.74,.55),@(.68,.65),@(.6,.7),@(.54,.59)),
                @(@(.77,.72),@(.85,.69),@(.9,.77),@(.81,.82),@(.75,.78))
            )
            foreach ($poly in $polygons) {
                [Drawing.PointF[]]$points = foreach ($p in $poly) { [Drawing.PointF]::new(($X+$p[0]*$D),($Y+$p[1]*$D)) }
                $G.FillPolygon($land, $points)
            }
        } finally { $land.Dispose() }
        $cloud = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(150,235,255,255))
        try {
            foreach ($p in @(@(.17,.32,.24),@(.6,.29,.22),@(.18,.62,.16),@(.64,.77,.15))) {
                $G.FillEllipse($cloud, [single]($X+$p[0]*$D), [single]($Y+$p[1]*$D), [single]($p[2]*$D), [single]($D*.024))
            }
        } finally { $cloud.Dispose() }
    } else {
        foreach ($p in @(@(.2,.2,.09),@(.44,.12,.07),@(.7,.23,.1),@(.27,.45,.08),@(.57,.4,.1),@(.76,.6,.09),@(.42,.72,.1),@(.2,.72,.07),@(.66,.81,.07))) {
            Circle $G ($X+$p[0]*$D) ($Y+$p[1]*$D) ($p[2]*$D) '#4B2C25'
        }
        foreach ($p in @(@(.35,.3),@(.58,.22),@(.38,.58),@(.65,.65),@(.29,.64),@(.8,.43))) {
            Circle $G ($X+$p[0]*$D) ($Y+$p[1]*$D) ($D*.02) '#955C2F'
        }
    }
}
foreach ($theme in @('Space','Bakery')) {
    $outPath = Join-Path $workspacePath ('games/' + $theme + '/Publishing')
    [void][IO.Directory]::CreateDirectory($outPath)
    $title = if ($theme -eq 'Space') { 'ORBIT' } else { 'CRUMBLE' }
    $background = if ($theme -eq 'Space') { '#090C1D' } else { '#1D1219' }
    $bottom = if ($theme -eq 'Space') { '#241B48' } else { '#4E292F' }
    $accent = if ($theme -eq 'Space') { '#ACF26F' } else { '#FFCD78' }
    $alt = if ($theme -eq 'Space') { '#9A8FFF' } else { '#EE9FB6' }
    foreach ($kind in @('Icon','Thumbnail')) {
        $width = if ($kind -eq 'Icon') { 512 } else { 1920 }
        $height = if ($kind -eq 'Icon') { 512 } else { 1080 }
        $bitmap = [Drawing.Bitmap]::new($width, $height)
        $g = [Drawing.Graphics]::FromImage($bitmap)
        $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $rect = [Drawing.Rectangle]::new(0,0,$width,$height)
        $bg = [Drawing.Drawing2D.LinearGradientBrush]::new($rect,(Color $background),(Color $bottom),[single]35)
        try { $g.FillRectangle($bg,$rect) } finally { $bg.Dispose() }
        $rng = [Random]::new(37)
        for ($i=0;$i -lt 55;$i++) { Circle $g ($rng.NextDouble()*$width) ($rng.NextDouble()*$height) (2+$rng.NextDouble()*3) '#6E718E' }
        if ($kind -eq 'Icon') {
            $size = if ($theme -eq 'Space') { 74 } else { 58 }
            $textWidth = if ($theme -eq 'Space') { 240 } else { 300 }
            Label $g $title $size (($width-$textWidth)/2) 33 '#F1F5FF' $true
            Target $g $theme 104 163 304
        } else {
            $genre = if ($theme -eq 'Space') { 'ENERGY CLICKER' } else { 'COOKIE CLICKER' }
            $slogan = if ($theme -eq 'Space') { "Every click starts`nsomething bigger." } else { "A little dough.`nA whole empire." }
            Label $g $genre 28 144 175 $accent $true
            Label $g $title 126 132 220 '#F1F5FF' $true
            Label $g $slogan 54 144 407 '#F1F5FF'
            Label $g 'CLICK  /  AUTOMATE  /  EXPAND' 25 148 645 $alt $true
            Label $g 'Research  +  Expeditions  +  Rebirths' 25 148 698 '#B5B2C4'
            Target $g $theme 1160 224 610
        }
        try { $bitmap.Save((Join-Path $outPath ($kind.ToLower()+'.png')),[Drawing.Imaging.ImageFormat]::Png) }
        finally { $g.Dispose(); $bitmap.Dispose() }
    }
    Write-Output "$title listing images created."
}

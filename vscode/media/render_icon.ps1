$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# Geometry lifted from assets/avatar.svg (64x64 viewBox), scaled x4 to 256.
$scale = 4
$size  = 256
$out   = Join-Path $PSScriptRoot "icon.png"

$teal   = [System.Drawing.Color]::FromArgb(255, 15, 118, 110)   # #0F766E
$mint   = [System.Drawing.Color]::FromArgb(255, 94, 234, 212)   # #5EEAD4
$light  = [System.Drawing.Color]::FromArgb(255, 204, 251, 241)  # #CCFBF1

$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode    = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode  = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Rounded background square: rx 14 of 64 -> 56 of 256
$radius = 14 * $scale
$rect   = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
$path   = New-Object System.Drawing.Drawing2D.GraphicsPath
$d = $radius
$path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
$path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
$path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
$path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
$path.CloseFigure()

$bg = New-Object System.Drawing.SolidBrush($teal)
$g.FillPath($bg, $path)

$stroke = 3 * $scale
$r  = 5 * $scale

# Vertical rail between the two open rings
$penRail = New-Object System.Drawing.Pen($mint, $stroke)
$penRail.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penRail.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($penRail, 20 * $scale, 21 * $scale, 20 * $scale, 43 * $scale)

# Horizontal connector into the filled node
$penLink = New-Object System.Drawing.Pen($mint, $stroke)
$penLink.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penLink.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($penLink, 25 * $scale, 32 * $scale, 39 * $scale, 32 * $scale)

# Open rings (stroke only) at (20,16) and (20,48)
$penRing = New-Object System.Drawing.Pen($mint, $stroke)
$g.DrawEllipse($penRing, (20 * $scale) - $r, (16 * $scale) - $r, 2 * $r, 2 * $r)
$g.DrawEllipse($penRing, (20 * $scale) - $r, (48 * $scale) - $r, 2 * $r, 2 * $r)

# Filled node at (44,32)
$node = New-Object System.Drawing.SolidBrush($mint)
$g.FillEllipse($node, (44 * $scale) - $r, (32 * $scale) - $r, 2 * $r, 2 * $r)

# Chevron pointing into the node
$penChev = New-Object System.Drawing.Pen($light, $stroke)
$penChev.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penChev.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$penChev.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$pts = @(
  [System.Drawing.PointF]::new(33 * $scale, 26 * $scale),
  [System.Drawing.PointF]::new(39 * $scale, 32 * $scale),
  [System.Drawing.PointF]::new(33 * $scale, 38 * $scale)
)
$g.DrawLines($penChev, $pts)

$g.Dispose()
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

$info = Get-Item $out
"icon.png written: {0} bytes, {1}x{2}" -f $info.Length, $size, $size

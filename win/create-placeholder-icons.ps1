#!/usr/bin/env pwsh
# Create simple placeholder icons for Teams app

Write-Host "🎨 Creating placeholder icons..." -ForegroundColor Cyan

# This script creates simple colored PNG files as placeholders
# You should replace these with proper icons later

Add-Type -AssemblyName System.Drawing

# Create outline icon (32x32, white with blue border)
$outlineBitmap = New-Object System.Drawing.Bitmap 32, 32
$outlineGraphics = [System.Drawing.Graphics]::FromImage($outlineBitmap)
$outlineGraphics.Clear([System.Drawing.Color]::Transparent)
$bluePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(91, 109, 239), 2)
$outlineGraphics.DrawRectangle($bluePen, 4, 4, 24, 24)
$outlineGraphics.DrawEllipse($bluePen, 8, 8, 16, 16)
$outlineBitmap.Save("outline.png", [System.Drawing.Imaging.ImageFormat]::Png)
$outlineGraphics.Dispose()
$outlineBitmap.Dispose()
$bluePen.Dispose()

Write-Host "✅ Created outline.png (32x32)" -ForegroundColor Green

# Create color icon (192x192, blue background with white circle)
$colorBitmap = New-Object System.Drawing.Bitmap 192, 192
$colorGraphics = [System.Drawing.Graphics]::FromImage($colorBitmap)
$colorGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$colorGraphics.Clear([System.Drawing.Color]::FromArgb(91, 109, 239))
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$colorGraphics.FillEllipse($whiteBrush, 48, 48, 96, 96)
$colorBitmap.Save("color.png", [System.Drawing.Imaging.ImageFormat]::Png)
$colorGraphics.Dispose()
$colorBitmap.Dispose()
$whiteBrush.Dispose()

Write-Host "✅ Created color.png (192x192)" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Note: These are simple placeholder icons" -ForegroundColor Yellow
Write-Host "   Replace them with proper branding later" -ForegroundColor Yellow
Write-Host ""
Write-Host "📦 Next step: Run .\create-teams-package.ps1" -ForegroundColor Cyan

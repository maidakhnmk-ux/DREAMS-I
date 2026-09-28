# Lightweight PowerShell HTTP Server for Bahawalpur ISWM Showcase
$port = 8080
$prefix = "http://localhost:$port/"
$basePath = $PSScriptRoot

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host " Bahawalpur ISWM & UC-14 Showcase Server Running" -ForegroundColor Green
    Write-Host " URL: $prefix" -ForegroundColor Yellow
    Write-Host " Press Ctrl+C in this console to stop the server" -ForegroundColor Gray
    Write-Host "=================================================================" -ForegroundColor Cyan

    Start-Process $prefix

    $mimeTypes = @{
        ".html" = "text/html"
        ".css"  = "text/css"
        ".js"   = "application/javascript"
        ".json" = "application/json"
        ".png"  = "image/png"
        ".jpg"  = "image/jpeg"
        ".jpeg" = "image/jpeg"
        ".avif" = "image/avif"
        ".mp4"  = "video/mp4"
        ".pdf"  = "application/pdf"
        ".svg"  = "image/svg+xml"
    }

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $urlPath = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrEmpty($urlPath) -or $urlPath -eq "/") {
            $urlPath = "index.html"
        }

        $filePath = Join-Path $basePath $urlPath.Replace('/', '\')

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime = "application/octet-stream"
            if ($mimeTypes.ContainsKey($ext)) {
                $mime = $mimeTypes[$ext]
            }

            $response.ContentType = $mime
            $response.AddHeader("Access-Control-Allow-Origin", "*")
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}

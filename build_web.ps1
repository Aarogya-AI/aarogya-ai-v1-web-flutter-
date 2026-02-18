# Build script for Aarogya AI
# Reads from .env file and builds the web app

# Load environment variables from .env
$envFile = Get-Content .env | Where-Object { $_ -match '=' -and $_ -notmatch '^#' }
$env = @{}
foreach ($line in $envFile) {
    $parts = $line -split '=', 2
    $env[$parts[0].Trim()] = $parts[1].Trim()
}

Write-Host "Building Aarogya AI for web..." -ForegroundColor Green

flutter build web `
    --dart-define="SUPABASE_URL=$($env['SUPABASE_URL'])" `
    --dart-define="SUPABASE_ANON_KEY=$($env['SUPABASE_ANON_KEY'])" `
    --dart-define="GROQ_API_KEY=$($env['GROQ_API_KEY'])"

Write-Host "Build complete! Output in build/web/" -ForegroundColor Green

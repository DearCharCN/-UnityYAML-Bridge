param (
    [string]$base,    # 基准文件 (common ancestor)
    [string]$remote,  # 其他分支的文件 (theirs)
    [string]$local,   # 当前分支的文件 (ours)
    [string]$merged   # 合并结果文件 (output)
)

# UnityYAMLMerge.exe 的路径
$unityYAMLMergePath = "C:\Program Files\Unity\Hub\Editor\2020.3.33f1c2\Editor\Data\Tools\UnityYAMLMerge.exe"

# 获取脚本所在的目录路径
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# 日志文件路径
$logFilePath = Join-Path $scriptDirectory "merge-log.txt"

# 函数：记录日志并退出
function Log-And-Exit {
    param (
        [string]$message,
        [int]$exitCode
    )
    Add-Content -Path $logFilePath -Value "$message`n"
    exit $exitCode
}

# 检查是否传入 UnityYAMLMerge.exe 的路径
if (-not $unityYAMLMergePath) {
    # 尝试在脚本所在目录中找到 UnityYAMLMerge.exe
    $unityYAMLMergePath = Join-Path $scriptDirectory "UnityYAMLMerge.exe"

    if (-not (Test-Path $unityYAMLMergePath)) {
        Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: UnityYAMLMerge.exe not found in script directory. Merge failed." 1
    }
}

# 开始记录日志
try {
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting merge process`n"
    $logEntry += "Base: $base`nRemote: $remote`nLocal: $local`nMerged: $merged`n"
    $logEntry += "Using UnityYAMLMerge.exe at: $unityYAMLMergePath`n"
    Add-Content -Path $logFilePath -Value $logEntry
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to create log file or write to it. Merge failed." 1
}

# 获取文件名和扩展名
$mergedFileName = [System.IO.Path]::GetFileNameWithoutExtension($merged)
$extension = [System.IO.Path]::GetExtension($merged)
$directory = [System.IO.Path]::GetDirectoryName($merged)

# 创建新的文件名
$baseNew = Join-Path $directory "$mergedFileName`_BASE$extension"
$remoteNew = Join-Path $directory "$mergedFileName`_REMOTE$extension"
$localNew = Join-Path $directory "$mergedFileName`_LOCAL$extension"

# 复制并重命名文件
try {
    Copy-Item -Path $base -Destination $baseNew -Force
    Copy-Item -Path $remote -Destination $remoteNew -Force
    Copy-Item -Path $local -Destination $localNew -Force
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to create or rename files. Merge failed." 1
}

# 记录重命名后的文件路径
try {
    $logEntry = "Renamed Files:`nBaseNew: $baseNew`nRemoteNew: $remoteNew`nLocalNew: $localNew`n"
    Add-Content -Path $logFilePath -Value $logEntry
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to log renamed files. Merge failed." 1
}

# 调用 UnityYAMLMerge.exe 执行合并
$arguments = "merge -p ""$baseNew"" ""$remoteNew"" ""$localNew"" ""$merged"""
try {
    $logEntry = "Calling UnityYAMLMerge.exe with arguments: $arguments`n"
    Add-Content -Path $logFilePath -Value $logEntry

    $process = Start-Process -FilePath $unityYAMLMergePath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
    $returnCode = $process.ExitCode
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: UnityYAMLMerge.exe execution failed. Merge failed." 1
}

# 记录 UnityYAMLMerge.exe 的返回值
try {
    $logEntry = "UnityYAMLMerge.exe returned with exit code: $returnCode`n"
    Add-Content -Path $logFilePath -Value $logEntry
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to log UnityYAMLMerge.exe return code. Merge failed." 1
}

# 删除临时文件
try {
    Remove-Item -Path $baseNew -Force
    Remove-Item -Path $remoteNew -Force
    Remove-Item -Path $localNew -Force

    $logEntry = "Deleted temporary files.`n"
    Add-Content -Path $logFilePath -Value $logEntry
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to delete temporary files. Merge failed." 1
}

# 返回 UnityYAMLMerge.exe 的返回值
exit $returnCode

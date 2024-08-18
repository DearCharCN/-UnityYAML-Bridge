param (
    [string]$base,    # ��׼�ļ� (common ancestor)
    [string]$remote,  # ������֧���ļ� (theirs)
    [string]$local,   # ��ǰ��֧���ļ� (ours)
    [string]$merged   # �ϲ�����ļ� (output)
)

# UnityYAMLMerge.exe ��·��
$unityYAMLMergePath = "C:\Program Files\Unity\Hub\Editor\2020.3.33f1c2\Editor\Data\Tools\UnityYAMLMerge.exe"

# ��ȡ�ű����ڵ�Ŀ¼·��
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# ��־�ļ�·��
$logFilePath = Join-Path $scriptDirectory "merge-log.txt"

# ��������¼��־���˳�
function Log-And-Exit {
    param (
        [string]$message,
        [int]$exitCode
    )
    Add-Content -Path $logFilePath -Value "$message`n"
    exit $exitCode
}

# ����Ƿ��� UnityYAMLMerge.exe ��·��
if (-not $unityYAMLMergePath) {
    # �����ڽű�����Ŀ¼���ҵ� UnityYAMLMerge.exe
    $unityYAMLMergePath = Join-Path $scriptDirectory "UnityYAMLMerge.exe"

    if (-not (Test-Path $unityYAMLMergePath)) {
        Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: UnityYAMLMerge.exe not found in script directory. Merge failed." 1
    }
}

# ��ʼ��¼��־
try {
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting merge process`n"
    $logEntry += "Base: $base`nRemote: $remote`nLocal: $local`nMerged: $merged`n"
    $logEntry += "Using UnityYAMLMerge.exe at: $unityYAMLMergePath`n"
    Add-Content -Path $logFilePath -Value $logEntry
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to create log file or write to it. Merge failed." 1
}

# ��ȡ�ļ�������չ��
$mergedFileName = [System.IO.Path]::GetFileNameWithoutExtension($merged)
$extension = [System.IO.Path]::GetExtension($merged)
$directory = [System.IO.Path]::GetDirectoryName($merged)

# �����µ��ļ���
$baseNew = Join-Path $directory "$mergedFileName`_BASE$extension"
$remoteNew = Join-Path $directory "$mergedFileName`_REMOTE$extension"
$localNew = Join-Path $directory "$mergedFileName`_LOCAL$extension"

# ���Ʋ��������ļ�
try {
    Copy-Item -Path $base -Destination $baseNew -Force
    Copy-Item -Path $remote -Destination $remoteNew -Force
    Copy-Item -Path $local -Destination $localNew -Force
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to create or rename files. Merge failed." 1
}

# ��¼����������ļ�·��
try {
    $logEntry = "Renamed Files:`nBaseNew: $baseNew`nRemoteNew: $remoteNew`nLocalNew: $localNew`n"
    Add-Content -Path $logFilePath -Value $logEntry
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to log renamed files. Merge failed." 1
}

# ���� UnityYAMLMerge.exe ִ�кϲ�
$arguments = "merge -p ""$baseNew"" ""$remoteNew"" ""$localNew"" ""$merged"""
try {
    $logEntry = "Calling UnityYAMLMerge.exe with arguments: $arguments`n"
    Add-Content -Path $logFilePath -Value $logEntry

    $process = Start-Process -FilePath $unityYAMLMergePath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
    $returnCode = $process.ExitCode
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: UnityYAMLMerge.exe execution failed. Merge failed." 1
}

# ��¼ UnityYAMLMerge.exe �ķ���ֵ
try {
    $logEntry = "UnityYAMLMerge.exe returned with exit code: $returnCode`n"
    Add-Content -Path $logFilePath -Value $logEntry
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to log UnityYAMLMerge.exe return code. Merge failed." 1
}

# ɾ����ʱ�ļ�
try {
    Remove-Item -Path $baseNew -Force
    Remove-Item -Path $remoteNew -Force
    Remove-Item -Path $localNew -Force

    $logEntry = "Deleted temporary files.`n"
    Add-Content -Path $logFilePath -Value $logEntry
} catch {
    Log-And-Exit "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: Unable to delete temporary files. Merge failed." 1
}

# ���� UnityYAMLMerge.exe �ķ���ֵ
exit $returnCode

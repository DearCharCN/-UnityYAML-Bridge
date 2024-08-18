# UnityYAML Bridge

This script is designed to help you automatically merge Unity YAML files, such as `.unity`, `.prefab`, and `.asset` files, using Unity's `UnityYAMLMerge.exe` tool. The script provides enhanced logging, error handling, and simplifies the merge process for Unity projects.

**[点击这里查看中文版本](README.md)**

## Prerequisites

- **Unity Editor**: Ensure that Unity is installed on your system, as the script relies on the `UnityYAMLMerge.exe` tool provided by Unity.
- **PowerShell Environment**: The script relies on PowerShell to execute. Please ensure that PowerShell is installed and enabled on your system (most Windows systems come with PowerShell pre-installed).

## Setup Instructions

### 1. Place the Script

1. **Download the Script**: Place the `custom-unity-merge.ps1` script in the same directory as the `UnityYAMLMerge.exe` tool.
   
2. **Locate `UnityYAMLMerge.exe`**:
   - The `UnityYAMLMerge.exe` tool is typically located in the Unity Editor installation directory. For example:
     - On Windows: `C:/Program Files/Unity/Hub/Editor/2020.3.33f1c2/Editor/Data/Tools/UnityYAMLMerge.exe`
   - If you are unsure where your Unity Editor is installed, you can find the path by opening Unity Hub, clicking on the three dots next to the editor version, and selecting "Show in Explorer."

### 2. Configure Git

To ensure that Git uses this script for merging Unity files, you need to configure Git by modifying the `.git/config` file in your repository.

1. **Edit `.git/config`**:
   - Add the following section to your `.git/config` file:
   
   ```ini
   [merge "custom-unity-yaml-merge"]
       name = "Custom Unity YAML Merge"
       driver = powershell -ExecutionPolicy Bypass -File \"C:/path/to/custom-unity-merge.ps1\" %O %A %B %P
   ```
   
   **Important**:
   - Replace `C:/path/to/custom-unity-merge.ps1` with the actual path where you placed the `custom-unity-merge.ps1` script.
   - **Use forward slashes `/` in the path** and **if the path contains spaces**, be sure to wrap the path in escaped double quotes (`\"`). For example:

   ```ini
   [merge "custom-unity-yaml-merge"]
       name = "Custom Unity YAML Merge"
       driver = powershell -ExecutionPolicy Bypass -File \"C:/Program Files/Unity/Hub/Editor/2020.3.33f1c2/Editor/Data/Tools/custom-unity-merge.ps1\" %O %A %B %P
   ```

   **Common Mistakes to Avoid**:
   - **Using backslashes `\` in the path**: You must use forward slashes `/` in the `.git/config` file, not backslashes `\`.
   - **Incorrect use of quotes**: Paths with spaces must be enclosed in escaped double quotes (`\"`). This is a common mistake, so pay close attention.

### 3. Configure `.gitattributes`

In your project, create or edit the `.gitattributes` file to associate Unity file types with the custom merge driver:

```ini
*.unity merge=custom-unity-yaml-merge
*.prefab merge=custom-unity-yaml-merge
*.asset merge=custom-unity-yaml-merge
```

This configuration ensures that Git uses the custom merge script whenever changes to Unity YAML files are encountered.

### 4. Set Up `mergespecfile.txt`

The `mergespecfile.txt` file is used to define the fallback strategy when `UnityYAMLMerge` is unable to automatically merge. This file is typically located in the Unity installation directory under `Data/Tools`, in the same directory as `UnityYAMLMerge.exe`.

#### 4.1 Set Up a Global Fallback to a Tool

The following example sets up a global fallback to a manual merge tool, "Beyond Compare." You can use this as a template or customize your own fallback strategy:

```ini
* use "D:\path\to\Beyond Compare Pro\BComp.exe" "%r" "%l" "%b" "%d"
```

In this example, `* use` indicates that all file types will use Beyond Compare as the merge tool. Be sure to replace `D:\path\to\Beyond Compare Pro\BComp.exe` with the actual installation path.

#### 4.2 Customize Your Fallback Strategy

If you want to set up different merge tools for different file types, you can configure them individually in `mergespecfile.txt`. For example:

```ini
*.unity use "D:\path\to\Beyond Compare Pro\BComp.exe" "%r" "%l" "%b" "%d"
*.prefab use "D:\path\to\Beyond Compare Pro\BComp.exe" "%r" "%l" "%b" "%d"
*.asset use "D:\path\to\Beyond Compare Pro\BComp.exe" "%r" "%l" "%b" "%d"
```

This allows you to specify different merge tools for each file type as needed.

## How the Script Works

The `custom-unity-merge.ps1` script automates the process of merging Unity YAML files by following these steps:

1. **Initialization**:
   - The script begins by checking if the path to `UnityYAMLMerge.exe` has been provided. If not, it will search for `UnityYAMLMerge.exe` in the same directory where the script is located.

2. **Logging**:
   - The script creates a log file (`merge-log.txt`) in the same directory as the script. This log file records each step of the merge process, including any errors encountered.

3. **File Preparation**:
   - The script renames the base, remote, and local files with the same extension as the merged file and prefixes them with `_BASE`, `_REMOTE`, and `_LOCAL`.

4. **Calling UnityYAMLMerge**:
   - The script uses `Start-Process` to call `UnityYAMLMerge.exe` with the appropriate arguments, ensuring the merge is handled correctly by Unity's merging tool.

5. **Cleanup**:
   - After the merge, the script deletes the temporary files created during the process to keep your working directory clean.

6. **Error Handling**:
   - If any step fails (e.g., if the script cannot find `UnityYAMLMerge.exe` or fails to create necessary files), the script logs the error and exits with a code of `1` to indicate that the merge failed.

## Conclusion

By following the steps outlined in this README, you can ensure smooth and automated merging of Unity YAML files in your project, saving time and reducing the potential for merge conflicts. This script is particularly useful for teams collaborating on large Unity projects where manual merging can be tedious and error-prone.

If you encounter any issues or need further customization, feel free to modify the script or reach out for support.
# Custom Unity YAML Merge Script 中文版本

此脚本旨在帮助您使用 Unity 的 `UnityYAMLMerge.exe` 工具自动合并 Unity YAML 文件，如 `.unity`、`.prefab` 和 `.asset` 文件。该脚本提供了增强的日志记录、错误处理，并简化了 Unity 项目的合并过程。

**[Click here to view the English version](README_en.md)**

## 前提条件

- **Unity 编辑器**：确保您的系统上已安装 Unity，因为该脚本依赖于 Unity 提供的 `UnityYAMLMerge.exe` 工具。
- **PowerShell 运行环境**：脚本依赖于 PowerShell 来执行操作。请确保您的系统中安装并启用了 PowerShell（Windows 系统通常预装了 PowerShell）。

## 设置说明

### 1. 放置脚本

1. **下载脚本**：将 `custom-unity-merge.ps1` 脚本放置在 `UnityYAMLMerge.exe` 工具的同一目录中。
   
2. **查找 `UnityYAMLMerge.exe`**：
   - `UnityYAMLMerge.exe` 工具通常位于 Unity 编辑器的安装目录中。例如：
     - 在 Windows 上：`C:/Program Files/Unity/Hub/Editor/2020.3.33f1c2/Editor/Data/Tools/UnityYAMLMerge.exe`
   - 如果您不确定 Unity 编辑器的安装位置，可以通过打开 Unity Hub，点击编辑器版本旁边的三点按钮，然后选择“在资源管理器中显示”来找到路径。

### 2. 配置 Git

为了确保 Git 使用此脚本合并 Unity 文件，您需要通过修改项目中的 `.git/config` 文件来配置 Git。

1. **编辑 `.git/config`**：
   - 将以下内容添加到 `.git/config` 文件中：
   
   ```ini
   [merge "custom-unity-yaml-merge"]
       name = "Custom Unity YAML Merge"
       driver = powershell -ExecutionPolicy Bypass -File \"C:/path/to/custom-unity-merge.ps1\" %O %A %B %P
   ```
   
   **重要提示**：
   - 将 `C:/path/to/custom-unity-merge.ps1` 替换为您放

置 `custom-unity-merge.ps1` 脚本的实际路径。
   - **路径中必须使用正斜杠 `/`**，并且**如果路径中包含空格**，请确保使用反斜杠转义双引号（`\"`）将路径括起来。例如：

   ```ini
   [merge "custom-unity-yaml-merge"]
       name = "Custom Unity YAML Merge"
       driver = powershell -ExecutionPolicy Bypass -File \"C:/Program Files/Unity/Hub/Editor/2020.3.33f1c2/Editor/Data/Tools/custom-unity-merge.ps1\" %O %A %B %P
   ```

   **常见错误提示**：
   - **路径中使用反斜杠 `\`**：在 `.git/config` 中必须使用正斜杠 `/`，而不是反斜杠 `\`。
   - **引号使用不当**：路径中的引号必须使用 `\"` 来正确转义。这是配置中常见的错误，务必注意。

### 3. 配置 `.gitattributes`

在您的项目中创建或编辑 `.gitattributes` 文件，将 Unity 文件类型与自定义合并驱动程序关联：

```ini
*.unity merge=custom-unity-yaml-merge
*.prefab merge=custom-unity-yaml-merge
*.asset merge=custom-unity-yaml-merge
```

此配置确保 Git 在遇到 Unity YAML 文件的更改时使用自定义合并脚本。

### 4. 设置 `mergespecfile.txt`

`mergespecfile.txt` 文件用于定义当 `UnityYAMLMerge` 无法自动合并时的回退策略。该文件通常位于 Unity 安装目录下的 `Data/Tools` 文件夹中，即与 `UnityYAMLMerge.exe` 同一目录。

#### 4.1 配置全文回退到一个工具

以下示例将所有文件都回退到一个手动合并工具“Beyond Compare”上，您可以参考这个示例，也可以自由设置自己的回退策略：

```ini
* use "D:\path\to\Beyond Compare Pro\BComp.exe" "%r" "%l" "%b" "%d"
```

在上述示例中，`* use` 表示对所有文件类型都使用 Beyond Compare 工具。您需要将 `D:\path\to\Beyond Compare Pro\BComp.exe` 替换为实际安装路径。

#### 4.2 自由设置回退策略

如果您想为不同的文件类型设置不同的合并工具，可以在 `mergespecfile.txt` 中进行更细致的配置。例如：

```ini
*.unity use "D:\path\to\Beyond Compare Pro\BComp.exe" "%r" "%l" "%b" "%d"
*.prefab use "D:\path\to\Beyond Compare Pro\BComp.exe" "%r" "%l" "%b" "%d"
*.asset use "D:\path\to\Beyond Compare Pro\BComp.exe" "%r" "%l" "%b" "%d"
```

这样，您可以根据需要为不同类型的文件指定不同的合并工具。

## 脚本工作原理

`custom-unity-merge.ps1` 脚本通过以下步骤自动合并 Unity YAML 文件：

1. **初始化**：
   - 脚本首先检查是否提供了 `UnityYAMLMerge.exe` 的路径。如果未提供，它将尝试在脚本所在目录中查找 `UnityYAMLMerge.exe`。

2. **日志记录**：
   - 脚本会在与脚本同目录下创建一个日志文件（`merge-log.txt`）。该日志文件记录了合并过程中的每一步，包括遇到的任何错误。

3. **文件准备**：
   - 脚本将基准文件、远程文件和本地文件重命名为带有 `_BASE`、`_REMOTE` 和 `_LOCAL` 前缀的文件，并保留原始文件的扩展名。

4. **调用 UnityYAMLMerge**：
   - 脚本使用 `Start-Process` 命令调用 `UnityYAMLMerge.exe`，并传递适当的参数，确保合并由 Unity 的工具正确处理。

5. **清理**：
   - 合并完成后，脚本会删除合并过程中创建的临时文件，以保持工作目录的整洁。

6. **错误处理**：
   - 如果任何步骤失败（例如找不到 `UnityYAMLMerge.exe` 或无法创建必要的文件），脚本会记录错误并返回 `exit code 1`，指示合并失败。

## 结论

通过遵循本 README 中的步骤，您可以确保 Unity YAML 文件在您的项目中实现顺畅的自动合并，从而节省时间并减少合并冲突的可能性。此脚本特别适用于在大型 Unity 项目中协作的团队，手动合并可能既繁琐又容易出错。

如果您遇到任何问题或需要进一步的定制，请随时修改脚本或寻求支持。
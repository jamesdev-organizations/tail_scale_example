class AppCommands {
  static String errorCannotFindDocker =
      'is not recognized as the name of a cmdlet, function, script file, or operable program.';
  static String installDocker = '''
powershell Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-win-amd64&_gl=1*1md6c94*_ga*MTc0NTYyNTYzOC4xNzM1MDE0MjE4*_ga_XJWPQMJYHQ*MTczNTI2OTY4NS4yLjEuMTczNTI2OTY5Mi41My4wLjA." -OutFile "\$env:TEMP\\Docker Desktop Installer.exe"; 
Start-Process -FilePath "\$env:TEMP\\Docker Desktop Installer.exe" -ArgumentList "/silent" -Verb RunAs -Wait; 
Remove-Item "\$env:TEMP\\Docker Desktop Installer.exe"
''';
  static String taskList = "powershell tasklist";
  static String dockerPath =
      'powershell (Get-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*" | Where-Object { \$_.DisplayName -like "Docker*" }).InstallLocation';
  static String dockerName = "Docker Desktop.exe";
  static String startDocker(String dockerPath) =>
      "powershell Start-Process -FilePath '$dockerPath\\$dockerName'";
  static String dockerVersion = "powershell docker --version";
}

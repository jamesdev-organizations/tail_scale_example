import 'dart:io';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailscale Installer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InstallerScreen(),
    );
  }
}

class InstallerScreen extends StatefulWidget {
  @override
  _InstallerScreenState createState() => _InstallerScreenState();
}

class _InstallerScreenState extends State<InstallerScreen> {
  String status = "start";
  bool isInstalled = false;
  bool isRunning = false;
  String _passKey = "";
  final _passKeyController = TextEditingController();
  bool isStartInstall = false;

  // Method to execute the installation and setup process
  Future<void> installTailscale() async {
    setState(() {
      isStartInstall = true;
      status = "processing";
    });

    // Step 1: Download and Install Tailscale
    try {
      await run(
          '''powershell Invoke-WebRequest -Uri "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe" -OutFile "\$env:TEMP\\tailscale-setup.exe"; Start-Process -FilePath "\$env:TEMP\\tailscale-setup.exe" -ArgumentList "/silent" -Verb RunAs -Wait; Remove-Item "\$env:TEMP\\tailscale-setup.exe"''');
      setState(() {
        status = "installed";
      });

      // Step 2: Check if Tailscale is running
      isInstalled = await checkIfTailscaleIsRunning();
      if (!isInstalled) {
        await startTailscaleApp();
      }

      // Step 3: Log in using Tailscale API key
      await tailscaleLogin();
    } catch (e) {
      setState(() {
        status = "error: $e";
      });
    }
  }

  // Method to check if Tailscale is running
  Future<bool> checkIfTailscaleIsRunning() async {
    try {
      final result = await run('powershell tasklist');
      if (result.first.stdout.contains("tailscale-ipn.exe")) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error checking if Tailscale is running: $e");
    }
    return false;
  }

  // Method to start Tailscale if not already running
  Future<void> startTailscaleApp() async {
    try {
      await run('powershell start tailscale-ipn.exe');
    } catch (e) {
      setState(() {
        status = "Không thể khởi động Tailscale: $e";
      });
    }
  }

  Future<void> tailscaleLogin() async {
    try {
      // Use the full path to tailscale.exe
      final result = await run(
          '''powershell "& 'C:\\Program Files\\Tailscale\\tailscale.exe' up --authkey=$_passKey"''');
      if (result.first.exitCode == 0) {
        setState(() {
          status = "Đăng nhập thành công!";
        });
        await displayCurrentIP();
      } else {
        setState(() {
          status = "Đăng nhập thất bại, quá trình cài đặt kết thúc.";
        });
      }
    } catch (e) {
      setState(() {
        status = "Lỗi khi đăng nhập: $e";
      });
    }
  }

  // Method to get and display the current IP of the machine
  Future<void> displayCurrentIP() async {
    try {
      final result = await run(
          r'''powershell "& 'C:\Program Files\Tailscale\tailscale.exe' ip"''');
      if (result.first.exitCode == 0) {
        setState(() {
          status = "IP hiện tại: ${result.first.stdout}";
        });
      }
    } catch (e) {
      setState(() {
        status = "Không thể lấy IP: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tailscale Installer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Trạng thái cài đặt:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              status,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (!isStartInstall)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: _passKeyController,
                  decoration: InputDecoration(
                    hintText: 'Nhập khóa xác thực Tailscale',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _passKey = value;
                    });
                  },
                ),
              ),
            SizedBox(height: 20),
            SizedBox(height: 40),
            if (!isStartInstall)
              ElevatedButton(
                onPressed: installTailscale,
                child: Text('Cài đặt Tailscale'),
              ),
          ],
        ),
      ),
    );
  }
}

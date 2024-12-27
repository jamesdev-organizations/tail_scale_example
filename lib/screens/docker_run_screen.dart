import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
import 'package:tail_scale_example/core/constants/app_commands.dart';
import 'package:tail_scale_example/core/enum/app_auto_install_status_enum.dart';

class DockerRunScreen extends StatefulWidget {
  const DockerRunScreen({super.key});

  @override
  State<DockerRunScreen> createState() => _DockerRunScreenState();
}

class _DockerRunScreenState extends State<DockerRunScreen> {
  AppAutoInstallStatusEnum status = AppAutoInstallStatusEnum.notInstall;
  String? error;

  @override
  void initState() {
    super.initState();
    _checkDockerInstallation();
  }

  _checkDockerInstallation() async {
    try {
      final result = await run(AppCommands.dockerVersion);

      if (result.first.exitCode == 0) {
        setState(() {
          status = AppAutoInstallStatusEnum.installed;
        });
        _checkRunningOrNot();
      } else {
        setState(() {
          status = AppAutoInstallStatusEnum.notInstall;
        });
        await _installDocker();
      }
    } catch (e) {
      setState(() {
        status = AppAutoInstallStatusEnum.unknownError;
        error = "Error checking Docker installation: $e";
      });
    }
  }

  _checkRunningOrNot() async {
    try {
      final result = await run(AppCommands.taskList);
      if (result.first.stdout.contains(AppCommands.dockerName)) {
        setState(() {
          status = AppAutoInstallStatusEnum.running;
        });
      } else {
        setState(() {
          status = AppAutoInstallStatusEnum.notRunning;
        });
        await _startDocker();
      }
    } catch (e) {
      setState(() {
        status = AppAutoInstallStatusEnum.unknownError;
        error = ("Error checking if Docker is running: $e");
      });
    }
  }

  _installDocker() async {
    try {
      final result = await run(AppCommands.installDocker);

      if (result.first.exitCode == 0) {
        setState(() {
          status = AppAutoInstallStatusEnum.installing;
        });
      } else {
        setState(() {
          status = AppAutoInstallStatusEnum.installError;
          error = "Error installing Docker: ${result.first.stderr}";
        });
      }
    } catch (e) {
      setState(() {
        status = AppAutoInstallStatusEnum.installError;
        error = "Error installing Docker: $e";
      });
    }
  }

  Future<void> _startDocker() async {
    try {
      const startDockerPath = r'assets\data\start_docker.bat';

      final dockerPathResult = await run(startDockerPath);

      for (var result in dockerPathResult) {
        if (result.stdout.contains('DOCKER_RUNNING')) {
          setState(() {
            status = AppAutoInstallStatusEnum.running;
          });
        } else {
          setState(() {
            status = AppAutoInstallStatusEnum.runningError;
            error = "Error starting Docker: ${result.stderr}";
          });
        }
      }
    } catch (e) {
      setState(() {
        status = AppAutoInstallStatusEnum.runningError;
        error = "Error starting Docker: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Docker Installer"),
      ),
      body: Center(
        child: _status(),
      ),
    );
  }

  Widget _status() {
    return Column(
      children: [
        Text("Status: $status"),
        if (error != null) Text("Error: $error"),
      ],
    );
  }
}

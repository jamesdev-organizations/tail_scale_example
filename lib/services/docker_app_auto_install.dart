import 'package:tail_scale_example/services/abstract_app_auto_install.dart';

class DockerAppAutoInstall extends AbstractAppAutoInstall {
  @override
  Future<bool> checkIsRunning() async {
    // Check if Docker is running
    return false;
  }

  @override
  Future<void> installApp() async {
    // Install Docker
  }

  @override
  Future<void> startApp() async {
    // Start Docker
  }
}

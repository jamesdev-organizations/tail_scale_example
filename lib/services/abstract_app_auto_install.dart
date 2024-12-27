abstract class AbstractAppAutoInstall {
  Future<bool> checkIsRunning();
  Future<void> installApp();
  Future<void> startApp();
}

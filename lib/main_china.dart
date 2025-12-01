import 'config/flavor_config.dart';
import 'main.dart' as app;

void main() {
  FlavorConfig.setFlavor(Flavor.china);
  app.main();
}

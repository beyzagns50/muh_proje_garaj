import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final client = MqttServerClient('broker.emqx.io', 'flutter_garaj_client'); // test broker

  Future<void> connect() async {
    client.logging(on: false);
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_garaj_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('MQTT bağlantı hatası: $e');
      client.disconnect();
    }
  }

  void onConnected() {
    print('MQTT: Bağlantı başarılı');
  }

  void onDisconnected() {
    print('MQTT: Bağlantı kesildi');
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final payload = (messages[0].payload as MqttPublishMessage)
          .payload
          .message;

      final receivedMessage =
          MqttPublishPayload.bytesToStringAsString(payload);
      print('MQTT Mesaj Geldi: $receivedMessage');
    });
  }

  void disconnect() {
    client.disconnect();
  }
}
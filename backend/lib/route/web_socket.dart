import 'package:backend/app/http/controllers/ws/chat_web_socket_controller.dart';
import 'package:vania/vania.dart';

class WebSocketRoute implements Route {
  @override
  void register() {
    Router.websocket('/ws', (WebSocketEvent event) {
      event.on('message', chatController.newMessage);
    });
  }
}

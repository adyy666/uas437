import 'package:backend/app/http/controllers/auth_controller.dart';
import 'package:backend/app/http/controllers/user_controller.dart';
import 'package:vania/vania.dart';

class ApiRoute implements Route {
  @override
  void register() {
    // Set the base prefix for the API routes
    Router.basePrefix('api');

    Router.post('/register', AuthController().register);

    Router.post('/login', AuthController().login);

    Router.get('/me', UserController().index);
  }
}

 
class Global {
  static final Global _global = Global._internal();

  factory Global() {
    return _global;
  }

  Global._internal();

  var isAdmin = false;
  var isLoggedIn = false;
  var appData = new Map<String, dynamic>();
 
}
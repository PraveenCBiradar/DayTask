import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'db_helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await DBHelper.instance.isUserLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomePage()));
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await DBHelper.instance.loginUser(
        _nameController.text,
        _passwordController.text,
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      _showErrorDialog('Login Failed', e.toString());
    }
    setState(() => _isLoading = false);
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await DBHelper.instance.registerUser(
        _nameController.text,
        _passwordController.text,
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      _showErrorDialog('Registration Failed', e.toString());
    }
    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_animation.value * 0.1),
                            child: Text(
                              'Welcome',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30.0),
                      _buildTextField(_nameController, 'Enter your Name', Icons.person),
                      SizedBox(height: 30.0),
                      _buildTextField(_passwordController, 'Enter your Password', Icons.lock, isPassword: true),
                      SizedBox(height: 30.0),
                      _buildLoginBtn(),
                      _buildRegisterBtn(),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          hint,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFF6CA8F1),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                icon,
                color: Colors.white,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          elevation: 5.0,
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Colors.white, // Updated parameter
        ),
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterBtn() {
    return GestureDetector(
      onTap: _register,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Register',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

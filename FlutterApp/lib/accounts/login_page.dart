// ignore_for_file: deprecated_member_use
part of 'accounts.dart';

class LoginPage extends StatefulWidget {
  final String msg;
  final VoidCallback onButtonPressed;
  const LoginPage({super.key, required this.msg, required this.onButtonPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  final storage = const FlutterSecureStorage();
  bool _obscureText = true;

  HttpService httpService = HttpService();
  Future<Login>? _futureLogin;

  // late Map<String, dynamic> user;
  // late String token;

  String? msg;

  @override
  void initState() {
    msg = widget.msg;
    super.initState();
  }

  Future showLoginErrorDialog(error, stackTrace) {
    Text? c;
    if (error is Login) {
      Map<String, dynamic>? nerror = error.errorMsg;
      c = Text('${nerror!.values.first[0]}');
    } else {
      c = Text(error.toString());
    }
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Error',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: c,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: ClipPath(
                clipper: BackgroundDesignL(),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondaryContainer,
                          Theme.of(context).colorScheme.tertiaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.05, 0.2]),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Hello Again
                  Center(
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.bebasNeue(fontSize: 50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      msg!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Username textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: userNameController,
                        autocorrect: false,
                        toolbarOptions: const ToolbarOptions(
                          copy: true,
                          cut: true,
                          paste: true,
                          selectAll: true,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: 'Username',
                          contentPadding: EdgeInsets.only(left: 20.0),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Password textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: passwordController,
                              obscureText: _obscureText,
                              autocorrect: false,
                              enableSuggestions: false,
                              textAlignVertical: TextAlignVertical.center,
                              toolbarOptions: const ToolbarOptions(
                                copy: true,
                                cut: true,
                                paste: true,
                                selectAll: true,
                              ),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: 'Password',
                                contentPadding: const EdgeInsets.only(left: 20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Sign in button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(height: 70),
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _futureLogin = httpService.postLogin(
                              username: userNameController.text,
                              password: passwordController.text,
                            );
                          });

                          _futureLogin?.then((value) async {
                            Navigator.popAndPushNamed(context, '/');
                            await UserSecureStorage.setUser(user: value.user);
                            await UserSecureStorage.setToken(token: value.token);

                            await AppStorage.mkdir();
                            String dir = await AppStorage.getDir();
                            var token = await UserSecureStorage.getToken();
                            await httpService.downloadAllUserFiles(
                                userToken: token, location: "$dir/mydata.zip");
                            unzipFile(dir);
                          }).onError((error, _) {
                            print('$error ###');
                            showLoginErrorDialog(error, _);
                          });
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Don\'t have an account?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: widget.onButtonPressed,
                        child: const Text(
                          ' Sign Up',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use
part of 'accounts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  HttpService httpService = HttpService();
  Future<RegisterModel>? _futureRegister;

  Future showRegisterErrorDialog(error, stackTrace) {
    Text? c;
    if (error is RegisterModel) {
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
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hello Again
              Center(
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.bebasNeue(fontSize: 50),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Create an account, ready your wearable.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 50),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username textfield
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (input) => input!.isValidUsername(),
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

                    // Email textfield
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (input) => input!.isValidEmail(),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
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
                            hintText: 'Email',
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
                              child: TextFormField(
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (input) => input!.isValidPassword(),
                                controller: passwordController,
                                obscureText: _obscureText,
                                autocorrect: false,
                                enableSuggestions: false,
                                textAlignVertical: TextAlignVertical.center,
                                toolbarOptions: const ToolbarOptions(),
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

                    const SizedBox(height: 10),

                    // Confirm password textfield
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (input) {
                            if (input != passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                          controller: confirmPasswordController,
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText: true,
                          toolbarOptions: const ToolbarOptions(),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: 'Confirm password',
                            contentPadding: EdgeInsets.only(left: 20.0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Sign up button
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints.tightFor(height: 70),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Send post request to server
                                    setState(() {
                                      _futureRegister = httpService.postRegister(
                                        username: userNameController.text,
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                    });

                                    // Save response (user credentials) to secure storage
                                    _futureRegister?.then((value) async {
                                      Navigator.popAndPushNamed(context, '/');
                                      await UserSecureStorage.setUser(user: value.user);
                                      await UserSecureStorage.setToken(token: value.token);
                                    }).onError((error, _) {
                                      print('################# $error');
                                      showRegisterErrorDialog(error, _);
                                    });
                                  }
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      ' Sign In',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

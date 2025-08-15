import 'dart:convert';

import 'package:av_master_mobile/controllers/auth_controller.dart';
import 'package:av_master_mobile/screens/portal_page.dart';
import 'package:av_master_mobile/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final AuthController authController = Get.put(AuthController());
  final storage = FlutterSecureStorage();
  final TextEditingController epfController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxString epfError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString apiError = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFE0FF),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.01,
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
          child: Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'lib/images/login_image.png', // <--- This path must exactly match!
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.contain,

                ),
                Container(
                    height: MediaQuery.of(context).size.height*0.5,
                    decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(45.0),
                          topRight: Radius.circular(45.0),
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'Login',
                              style: Theme.of(context).textTheme.displaySmall
                          ),
                          const SizedBox(height: 10),
                          Text(
                              'Welcome Back!',
                              style: Theme.of(context).textTheme.titleMedium
                          ),
                          const SizedBox(height: 4),
                          Text(
                              'Connect to Your Contributions',
                              style: Theme.of(context).textTheme.titleMedium
                          ),
                          const SizedBox(height: 30),

                          // EPF number input
                          TextField(
                            controller: epfController,
                            onChanged: (e){
                              setState(() {
                                epfError.value='';
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'EPF number',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 20.0),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                          Obx(()=>epfError.value!=''?Text(epfError.value,style: TextStyle(
                            color: Colors.red
                          ),):SizedBox.shrink()),
                          const SizedBox(height: 20),

                          // Password input
                          TextField(
                            controller: passwordController,
                            onChanged: (e){
                              setState(() {
                                passwordError.value = '';
                              });
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'password',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 20.0),
                            ),
                          ),
                          Obx(()=>passwordError.value!=''?Text(passwordError.value,style: TextStyle(
                              color: Colors.red
                          ),):SizedBox.shrink()),
                          const SizedBox(height: 40),

                          Obx(()=>apiError.value!=''?Center(child: Text(apiError.value,style: TextStyle(
                              color: Colors.red
                          ),),):SizedBox.shrink()),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 55, // Fixed height for the button
                            child: authController.isLoading.value?Center(child: CircularProgressIndicator(),):ElevatedButton(
                              onPressed: () async{
                                apiError.value = '';
                                // Handle login logic here
                                // print('Login button pressed!');
                                if(passwordController.text==''|| epfController.text==''){
                                  if(passwordController.text==''){
                                    passwordError.value="Required*";
                                  }
                                  if(epfController.text==''){
                                    epfError.value = "Required*";
                                  }
                                }else{
                                final response = await authController.login(
                                    password: passwordController.text,
                                    epfNumber: epfController.text
                                );
                                if(response ==true){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const PortalPage()),);
                                }else{
                                  apiError.value = response.toString();
                                }
                                }

                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary, // Button background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 0, // No shadow
                              ),
                              child: Text(
                                  'Login',
                                  style: Theme.of(context).textTheme.titleLarge
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                )
              ]
          ),
        )
        ),
      ))
    ;
  }
}

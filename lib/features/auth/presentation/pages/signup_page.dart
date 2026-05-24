import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/auth/presentation/cubit/signup_cubit.dart';
import 'package:memory_chat/features/auth/presentation/cubit/signup_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<SignupCubit>().signUp(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignupCubit>(),
      child: Builder(
        builder: (context) {
          return BlocListener<SignupCubit, SignupState>(
            listener: (context, state) {
              if (state.status == SignupStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }

              if (state.status == SignupStatus.success) {
                context.goNamed(RouteNames.workspaceList);
              }
            },
            child: Scaffold(
              appBar: AppBar(title: const Text('Create Account')),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'Full name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<SignupCubit, SignupState>(
                          builder: (context, state) {
                            return PrimaryButton(
                              text: 'Create Account',
                              isLoading: state.status == SignupStatus.loading,
                              onPressed: () => _submit(context),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.goNamed(RouteNames.login),
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

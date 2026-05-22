import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

class AppEntryPage extends StatelessWidget {
  const AppEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Memory Chat',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Collaborative workspace for notes and chat.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Login',
                onPressed: () => context.goNamed(RouteNames.login),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.goNamed(RouteNames.signup),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.goNamed(RouteNames.workspaceList),
                child: const Text('Skip to Workspace List'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

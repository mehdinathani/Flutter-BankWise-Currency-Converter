import 'package:bankwisewithgetx/services/fetch_data.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coverter"),
      ),
      body: SafeArea(
          child: Column(
        children: [
          const Text("Fetch Data"),
          ElevatedButton.icon(
            onPressed: () async {
              await fetchData();
            },
            icon: const Icon(Icons.get_app),
            label: const Text("Fetch"),
          )
        ],
      )),
    );
  }
}

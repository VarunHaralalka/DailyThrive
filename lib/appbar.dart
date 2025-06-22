import 'package:flutter/material.dart';
import 'Profile/profile.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false, // Removes back button
      backgroundColor: Colors.blue.shade800,
      elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          ),
        ),
      ],
    );
  }
}

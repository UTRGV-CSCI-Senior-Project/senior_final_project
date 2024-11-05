import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Icon leading;
  final Color? color;

  const SettingsItem({super.key, 
    required this.title,
    required this.leading,
    required this.onTap,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).textTheme.displayLarge?.color;
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color:  effectiveColor),
          ),
          leading: leading,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
          onTap: onTap,
        ),
        Divider(
          color: Theme.of(context).textTheme.displayLarge?.color,
        ),
      ],
    );
  }
}
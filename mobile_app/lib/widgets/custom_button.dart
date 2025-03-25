// Exemple de composant de bouton personnalis�
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function() onPressed;
  final Color? color;

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';
// class AuthSocialButton extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   final Color backgroundColor;
//   final VoidCallback onPressed; // Add this to handle button press
//   final double width; // Change to double for better precision
//   final double height; // Change to double for better precision
//   const AuthSocialButton({
//     super.key,
//     required this.icon,
//     required this.text,
//     required this.onPressed,
//     required this.width,
//     required this.height,
//     required this.backgroundColor, required Color iconColor, required Color textColor,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       height: height,
//       child: ElevatedButton.icon(
//       onPressed: () {},
//         icon: Icon(
//           icon,
//           color: text.contains('FACEBOOK') 
//               ? AppColors.facebookBlue 
//               : AppColors.googleRed,
//         ),
//         label: Text(text),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor, // Set the background color
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0), // Optional: Add rounded corners
//           ),
//         ),
//       ),
//     );
//   }
// }



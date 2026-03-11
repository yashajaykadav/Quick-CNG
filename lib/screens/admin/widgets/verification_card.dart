// import 'package:flutter/material.dart';
// import 'package:quickcng/models/verification_request.dart';
// import 'package:quickcng/screens/admin/widgets/detail_row.dart';

// class VerificationCard extends StatelessWidget {
//   final VerificationRequest request;
//   final Function(String status) onAction;

//   const VerificationCard({
//     super.key,
//     required this.request,
//     required this.onAction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ExpansionTile(
//         title: Text(request.fullName),
//         subtitle: Text(request.stationName),
//         children: [
//           detailRow(
//             icon: Icons.phone,
//             label: "Contact",
//             value: request.contact,
//           ),
//           Row(
//             children: [
//               ElevatedButton(
//                 onPressed: () => onAction("rejected"),
//                 child: const Text("Reject"),
//               ),
//               ElevatedButton(
//                 onPressed: () => onAction("approved"),
//                 child: const Text("Approve"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

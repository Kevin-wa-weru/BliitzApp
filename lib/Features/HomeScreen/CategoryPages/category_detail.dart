// import 'package:bliitz/Features/widgets/group_item.dart';
// import 'package:bliitz/utils/_index.dart';
// import 'package:bliitz/utils/misc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// class CategoryDetail extends StatefulWidget {
//   const CategoryDetail({super.key, required this.title});
//   final String title;
//   @override
//   State<CategoryDetail> createState() => _CategoryDetailState();
// }

// class _CategoryDetailState extends State<CategoryDetail> {
//   List<Widget> groupwidgets = MiscImpl()
//       .getDummyGroups()
//       .map((e) => SingleGroupItem(
//             groupDetails: e,
//             isOwnersGroups: false,
//             isViewinginGroupInfo: false,
//           ))
//       .toList();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           Column(
//             children: [
//               const SizedBox(
//                 height: 40,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         height: Adapt.px(80),
//                         width: Adapt.px(80),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.04),
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(100.0),
//                           ),
//                         ),
//                         child: Center(
//                           child: Icon(
//                             Icons.arrow_back,
//                             color: Colors.white.withOpacity(0.5),
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 48.0),
//                           child: SizedBox(
//                             height: Adapt.px(70),
//                             child: Center(
//                               child: Text(
//                                 widget.title,
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white.withOpacity(0.7),
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.w600,
//                                   letterSpacing: -0.5,
//                                   height: 1.3,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: Stack(
//                   children: [
//                     MediaQuery.removePadding(
//                       context: context,
//                       removeBottom: true,
//                       removeTop: true,
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                             children: MiscImpl()
//                                 .getSocialNames()
//                                 .map(
//                                   (e) => Padding(
//                                     padding: EdgeInsets.only(
//                                         right:
//                                             e['name'] == 'We-chat' ? 14 : 8.0),
//                                     child: Container(
//                                       height: 32.0,
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFF141312),
//                                         borderRadius:
//                                             BorderRadius.circular(25.0),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 2,
//                                             right: 9,
//                                             top: 8,
//                                             bottom: 8),
//                                         child: Row(
//                                           children: [
//                                             SvgPicture.asset(
//                                               e['iconPath'],
//                                               height: 32,
//                                               width: 32,
//                                               colorFilter:
//                                                   const ColorFilter.mode(
//                                                 Colors.white,
//                                                 BlendMode.srcIn,
//                                               ),
//                                             ),
//                                             Transform.translate(
//                                               offset: const Offset(-2.0, 0.0),
//                                               child: Text(
//                                                 e['name'],
//                                                 style: TextStyle(
//                                                   color: Colors.white
//                                                       .withOpacity(0.8),
//                                                   fontFamily: 'Questrial',
//                                                   fontWeight: FontWeight.w300,
//                                                   fontSize: 12,
//                                                   letterSpacing: 0.5,
//                                                   height: 1.2,
//                                                   decorationColor: Colors.white
//                                                       .withOpacity(0.75),
//                                                 ),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                                 .toList()),
//                       ),
//                     ),
//                     Container(
//                       height: 32.0,
//                       width: 24,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.centerLeft,
//                           end: Alignment.centerRight,
//                           colors: [
//                             Colors.black,
//                             Colors.black.withOpacity(0.0),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Container(
//                           height: 32.0,
//                           width: 24,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.centerRight,
//                               end: Alignment.centerLeft,
//                               colors: [
//                                 Colors.black,
//                                 Colors.black.withOpacity(0.0),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//             ],
//           ),
//           Expanded(
//               child: MediaQuery.removePadding(
//                   context: context,
//                   removeBottom: true,
//                   removeTop: true,
//                   child: ListView(children: groupwidgets)))
//         ],
//       ),
//     );
//   }
// }

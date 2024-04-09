// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// class MatrixSelection extends StatefulWidget {
//   const MatrixSelection({Key? key}) : super(key: key);
//
//   @override
//   State<MatrixSelection> createState() => _MatrixSelectionState();
// }
//
// class _MatrixSelectionState extends State<MatrixSelection> {
//   List<bool> selectedCells = List.generate(100, (index) => false);
//   bool isDragging = false;
//   int startCellIndex = 0;
//   int numRowsSelected = 0;
//   int numColsSelected = 0;
//   bool showMatrix = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _draggableMatrix(selectedCells),
//         ElevatedButton(
//             onPressed: () {
//               if (kDebugMode) {
//                 print(numRowsSelected);
//                 print(numColsSelected);
//               }
//             },
//             child: const Text("Print"))
//       ],
//     );
//   }
//
//   Widget _draggableMatrix(List<bool> selectedCells) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           _resetGrid();
//         },
//         onPanStart: (details) {
//           _handleDragStart(details.localPosition);
//         },
//         onPanUpdate: (details) {
//           _handleDragUpdate(details.localPosition);
//           numRowsSelected = _getNumRowsSelected();
//           numColsSelected = _getNumColsSelected();
//           setState(() {});
//         },
//         onPanEnd: (_) {
//           setState(() {
//             isDragging = false;
//           });
//         },
//         child: Container(
//           margin: const EdgeInsets.all(10),
//           child: GridView.builder(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 10,
//             ),
//             itemCount: 100,
//             controller: ScrollController(),
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     // selectedCells[index] = !selectedCells[index];
//                   });
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.all(1),
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.all(Radius.circular(10)),
//                     border: Border.all(color: Colors.black),
//                     color: selectedCells[index]
//                         ? const Color(0xff9B7CD2)
//                         : const Color(0xffEEE9F7),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _handleDragStart(Offset localPosition) {
//     setState(() {
//       isDragging = true;
//       _handleDragUpdate(localPosition);
//     });
//   }
//
//   void _handleDragUpdate(Offset localPosition) {
//     if (isDragging) {
//       int currentCellIndex = _getCellIndex(localPosition);
//       int currentRow = currentCellIndex ~/ 10;
//       int currentColumn = currentCellIndex % 10;
//       setState(() {
//         for (int i = 0; i < 100; i++) {
//           if (i % 10 <= currentColumn && i ~/ 10 <= currentRow) {
//             selectedCells[i] = true;
//           } else {
//             selectedCells[i] = false;
//           }
//         }
//       });
//     }
//   }
//
//   int _getCellIndex(Offset localPosition) {
//     final gridBox = context.findRenderObject() as RenderBox;
//     final cellWidth = gridBox.size.width / 10;
//     final cellHeight = gridBox.size.height / 10;
//     final column = (localPosition.dx / cellWidth).floor();
//     final row = (localPosition.dy / cellHeight).floor();
//     return row * 10 + column;
//   }
//
//   void _resetGrid() {
//     setState(() {
//       selectedCells = List.generate(100, (index) => false);
//     });
//   }
//
//   int _getNumRowsSelected() {
//     int numRows = 0;
//     for (int i = 0; i < 10; i++) {
//       bool rowSelected = false;
//       for (int j = i * 10; j < (i + 1) * 10; j++) {
//         if (selectedCells[j]) {
//           rowSelected = true;
//           break;
//         }
//       }
//       if (rowSelected) {
//         numRows++;
//       }
//     }
//     return numRows;
//   }
//
//   int _getNumColsSelected() {
//     int numCols = 0;
//     for (int i = 0; i < 10; i++) {
//       bool colSelected = false;
//       for (int j = i; j < 100; j += 10) {
//         if (selectedCells[j]) {
//           colSelected = true;
//           break;
//         }
//       }
//       if (colSelected) {
//         numCols++;
//       }
//     }
//     return numCols;
//   }
// }

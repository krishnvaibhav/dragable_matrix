import 'dart:io';

import 'package:dragable_tables/reverseHtml.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class MatrixSelection extends StatefulWidget {
  @override
  _MatrixSelectionState createState() => _MatrixSelectionState();
}

class _MatrixSelectionState extends State<MatrixSelection> {
  List<bool> selectedCells = List.generate(100, (index) => false);
  bool isDragging = false;
  int startCellIndex = 0;
  int numRowsSelected = 0;
  int numColsSelected = 0;
  bool showMatrix = true;
  Map<String, String> dataMap = {};
  Map<String, TextEditingController> textControllers = {};
  int tableCount = 0;
  List<TextEditingController> mainTextControllers = [TextEditingController()];
  List<List<dynamic>> tableWidgets = [];
  int totalRows = 0;
  int totalCols = 0;
  List<String> deletedCells = [];
  List<int> deletedMainControllers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      // height: 400,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(), color: Color(0xffEEE9F7)),
                      child: ListView.builder(
                        itemCount: mainTextControllers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              index >= 1
                                  ? tableWidgets[index - 1][0]
                                  : Container(),
                              testTextField(index)
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  _draggableMatrix(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _insertTable(),
                      _getHTMLButton(),
                      _navigateButton(context)
                    ],
                  ),
                  // _selectedTable(),
                  // _showHTMLButton(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _navigateButton(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReverseHTML()),
            );
          },
          child: Text("Go to Next")),
    );
  }

  Widget _getHTMLButton() {
    const htmlStart = " <!DOCTYPE html><html lang='en'><meta charset='UTF-8'>"
        "<title>HTML TABLE FROM APP</title><meta name='viewport' content='width=device-width,initial-scale=1'>"
        "<link rel='stylesheet' href=''><style></style><body>";

    const htmlEnd = "</body> </html>";

    var htmlList = [];
    return ElevatedButton(
        onPressed: () {
          {
            int rowStart = 0;

            int colStart = 0;

            var firstMainControllerData =
                mainTextControllers[0].text.split("\n");
            for (int j = 0; j < firstMainControllerData.length; j++) {
              htmlList.add("<p> ${firstMainControllerData[j]} </p>");
            }

            htmlList.add("</br>");

            int i = 1;
            while (i < mainTextControllers.length) {
              mainTextControllers;

              deletedMainControllers;

              int noOfRow = tableWidgets[i - 1][2] + rowStart;

              int noOfCols = tableWidgets[i - 1][1];

              Map<String, String> data =
                  returnDataMap(rowStart, noOfRow, colStart, noOfCols);

              var splitData = mainTextControllers[i].text.split("\n");

              if (data.isNotEmpty) {
                String tableContent =
                    generateHtmlTable(data, noOfRow, noOfCols, colStart);

                htmlList.add(tableContent);

                htmlList.add("</br>");
                i += 1;
                for (int j = 0; j < splitData.length; j++) {
                  htmlList.add("<p> ${splitData[j]} </p>");
                }

                htmlList.add("</br>");
              }
              colStart += noOfCols;
            }
            var htmlContent = htmlList.join("");

            final html = htmlStart + htmlContent + htmlEnd;

            print(html);

            _createAndDownloadHtmlFile(html);
          }
        },
        child: const Text("Save"));
  }

  Future<void> _createAndDownloadHtmlFile(String htmlContent) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String path = directory!.path;
    const String fileName = 'table.html';
    final File file = File('$path/$fileName');
    print(file);
    await file.writeAsString(htmlContent);
    OpenFilex.open('$path/$fileName');
  }

  Widget testTextField(n) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        print("EVENT IS ${event.logicalKey}");
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            mainTextControllers[n].text.isEmpty) {
          print('Back arrow key pressed and text field is empty');
          if (tableWidgets.isNotEmpty) {
            setState(() {
              mainTextControllers.removeAt(n);
              deletedMainControllers.add(n);
              var colStart = tableWidgets[n - 1][3];
              var rows = tableWidgets[n - 1][2];
              var cols = tableWidgets[n - 1][1];
              tableWidgets.removeAt(n - 1);
              for (int i = colStart; i < cols + colStart; i++) {
                for (int j = 0; j < rows; j++) {
                  textControllers.remove(i.toString() + j.toString());
                  deletedCells.add(i.toString() + j.toString());
                }
              }
              print("Removed");
            });
          }
        }
      },
      child: TextField(
        controller: mainTextControllers[n],
        decoration: const InputDecoration(border: InputBorder.none),
        keyboardType: TextInputType.multiline,
        obscureText: false,
        textInputAction: TextInputAction.newline,
        maxLines: 4,
        minLines: 1,
      ),
    );
  }

  String generateHtmlTable(Map<String, String> dataMap, rows, cols, colStart) {
    String html = '<table border="1">';
    for (int i = 0; i < rows; i++) {
      html += '<tr>';
      for (int j = colStart; j < cols + colStart; j++) {
        var data = dataMap[j.toString() + i.toString()];
        data != ""
            ? html += i == 0 ? '<th>$data</th>' : '<td>$data</td>'
            : html += i == 0 ? '<th width="80" height="40"></th>' : '<td height="50" width="50"></td>';
      }
      html += '</tr>';
    }
    html += '</table>';
    return html;
  }

  Map<String, String> returnDataMap(rowStart, rows, colStart, columns) {
    dataMap = {};
    for (int i = colStart; i < columns + colStart; i++) {
      for (int j = 0; j < rows; j++) {
        var index = i.toString() + j.toString();
        if (!deletedCells.contains(index)) {
          dataMap[index] = textControllers[index]!.text;
        }
      }
    }
    return dataMap;
  }

  Widget _insertTable() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            numRowsSelected = _getNumRowsSelected();
            numColsSelected = _getNumColsSelected();
            showMatrix = false;
          });
          for (int i = totalCols; i < numColsSelected + totalCols; i++) {
            for (int j = 0; j < numRowsSelected; j++) {
              textControllers[i.toString() + j.toString()] =
                  TextEditingController();
            }
          }
          setState(() {
            tableWidgets.add([
              _selectedTable(),
              numColsSelected,
              numRowsSelected,
              totalCols
            ]);
            mainTextControllers.add(TextEditingController());
          });
          totalCols += numColsSelected;
        },
        child: const Text('Insert Table'),
      ),
    );
  }

  Widget _draggableMatrix() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _resetGrid();
        },
        onPanStart: (details) {
          _handleDragStart(details.localPosition);
        },
        onPanUpdate: (details) {
          _handleDragUpdate(details.localPosition);
        },
        onPanEnd: (_) {
          setState(() {
            isDragging = false;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
            ),
            itemCount: 100,
            controller: ScrollController(), // Add a ScrollController
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // selectedCells[index] = !selectedCells[index];
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(1),
                  // child: Text(index.toString()),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black),
                    color: selectedCells[index]
                        ? Color(0xff9B7CD2)
                        : Color(0xffEEE9F7),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleDragStart(Offset localPosition) {
    setState(() {
      isDragging = true;
      _handleDragUpdate(
          localPosition); // Select the cell where dragging started
    });
  }

  void _handleDragUpdate(Offset localPosition) {
    if (isDragging) {
      int currentCellIndex = _getCellIndex(localPosition);
      int currentRow =
          currentCellIndex ~/ 10; // Calculate the row of the current cell
      int currentColumn =
          currentCellIndex % 10; // Calculate the column of the current cell
      print("Cell index $currentCellIndex");
      print("Current row $currentRow");
      print("Current column $currentColumn");
      setState(() {
        for (int i = 0; i < 100; i++) {
          if (i % 10 <= currentColumn && i ~/ 10 <= currentRow) {
            selectedCells[i] = true;
          } else {
            selectedCells[i] = false;
          }
        }
      });
    }
  }

  int _getCellIndex(Offset localPosition) {
    final gridBox = context.findRenderObject() as RenderBox;
    final cellWidth = gridBox.size.width / 10;
    final cellHeight = gridBox.size.height / 10;
    final column = (localPosition.dx / cellWidth).floor();
    final row = (localPosition.dy / cellHeight).floor();
    return row * 10 + column;
  }

  Widget _selectedTable() {
    const columWidth = 150.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: columWidth * numColsSelected.toDouble(),
            child: Table(
              columnWidths: {
                for (int i = 0; i < numColsSelected; i++)
                  i: const FixedColumnWidth(columWidth),
              },
              border: TableBorder.all(),
              children: List.generate(
                numRowsSelected,
                (indexRow) => TableRow(
                  children: List.generate(
                    numColsSelected,
                    (indexCol) => TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(8),
                            ),
                            controller: textControllers[
                                (indexCol + totalCols).toString() +
                                    indexRow.toString()],
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // IconButton(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.delete,
          //       color: Colors.red,
          //     ))
        ],
      ),
    );
  }

  void _resetGrid() {
    setState(() {
      selectedCells = List.generate(100, (index) => false);
    });
  }

  int _getNumRowsSelected() {
    int numRows = 0;
    for (int i = 0; i < 10; i++) {
      bool rowSelected = false;
      for (int j = i * 10; j < (i + 1) * 10; j++) {
        if (selectedCells[j]) {
          rowSelected = true;
          break;
        }
      }
      if (rowSelected) {
        numRows++;
      }
    }
    return numRows;
  }

  int _getNumColsSelected() {
    int numCols = 0;
    for (int i = 0; i < 10; i++) {
      bool colSelected = false;
      for (int j = i; j < 100; j += 10) {
        if (selectedCells[j]) {
          colSelected = true;
          break;
        }
      }
      if (colSelected) {
        numCols++;
      }
    }
    return numCols;
  }
}

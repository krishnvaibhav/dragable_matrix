import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:path_provider/path_provider.dart';

class ReverseHTML extends StatefulWidget {
  const ReverseHTML({Key? key});

  @override
  State<ReverseHTML> createState() => _ReverseHTMLState();
}

class _ReverseHTMLState extends State<ReverseHTML> {
  List<TextEditingController> textControllers = [];
  Map<String, TextEditingController> tableControllers = {};
  List<Widget> tables = [];

  // var document = "<!DOCTYPE html> <html lang='en'>"
  //     " <meta charset='UTF-8'><title>HTML TABLE FROM APP</title>"
  //     " <meta name='viewport' content='width=device-width,initial-scale=1'>"
  //     " <link rel='stylesheet' href=''><style></style><body><p> data 1 </p></br>"
  //     " <table border='1'><tr><th>name</th><th>date</th><th>class</th></tr><tr><td>01</td>"
  //     "<td>11</td><td>21</td></tr></table><p> data 2 </p></br> <table border='1'>"
  //     "<tr><th>30</th><th>40</th><th>50</th></tr><tr><td>31</td><td>41</td><td>51</td></tr></table><p>"
  //     "</p></br></body></html>";

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 400,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all()),
              child: ListView.builder(
                itemCount: textControllers.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      index > 0 ? tables[index - 1] : Container(),
                      myTextField(index),
                    ],
                  );
                },
              ),
            ),
            myButton()
          ],
        ),
      ),
    ));
  }

  Widget myTextField(index) {
    return TextField(
      decoration: const InputDecoration(border: InputBorder.none),
      keyboardType: TextInputType.multiline,
      obscureText: false,
      textInputAction: TextInputAction.newline,
      maxLines: 4,
      minLines: 1,
      controller: textControllers[index],
    );
  }

  Widget myButton() {
    return ElevatedButton(
      onPressed: () {
        reversedHTML();
      },
      child: const Text("GET DATA"),
    );
  }

  Widget _displayTable(cols, rows) {
    const columWidth = 150.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: columWidth * cols.toDouble(),
        child: Table(
          columnWidths: {
            for (int i = 0; i < cols; i++) i: const FixedColumnWidth(columWidth),
          },
          border: TableBorder.all(),
          children: List.generate(
            rows,
                (indexRow) => TableRow(
              children: List.generate(
                cols,
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
                        controller: tableControllers[
                        indexRow.toString() + indexCol.toString()],
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
    );
  }

  Future<File> getHTML()async {
    final Directory? directory = await getExternalStorageDirectory();
    final String path = directory!.path;
    const String fileName = 'table.html';
    final File file = File('$path/$fileName');
    return file;
  }

  void reversedHTML() async {
    File file = await getHTML();
    var document = await file.readAsString();
    textControllers = [];
    tableControllers = {};
    tables = [];
    final documentDom = htmlParser.parse(document);

    List<String> textList = [];
    Map<String, List<List<String>>> tableMap = {};
    documentDom.body?.children.forEach((element) {
      if (element.localName == 'p') {
        textList.add(element.text);
      } else if (element.localName == 'br'){
        textList.add('<br/>');
      }
      else if (element.localName == 'table') {
        String tableId = tableMap.length.toString();
        List<List<String>> tableData = [];
        element.querySelectorAll('tr').forEach((row) {
          List<String> rowData = [];
          row.querySelectorAll('td, th').forEach((cell) {
            rowData.add(cell.text);
          });
          tableData.add(rowData);
        });
        tableMap[tableId] = tableData;
      }
    });

    textList = textList.join("").split("<br/>").where((element) => element.isNotEmpty).toList();
    ;
    print(textList);

    print('Text List: $textList');
    print('Table Map: $tableMap');

    for (int i = 0; i < textList.length; i++) {
      setState(() {
        textControllers.add(TextEditingController(text: textList[i]));
      });
    }
    for (int i = 0; i < tableMap.length; i++) {
      var arr = tableMap[i.toString()];
      var rows = arr?.length;
      var cols = 0;
      for (int j = 0; j < arr!.length; j++) {
        cols = arr[j].length;
        for (int k = 0; k < arr[j].length; k++) {
          tableControllers[j.toString() + k.toString()] =
              TextEditingController(text: arr[j][k]);
        }
      }
      tables.add(_displayTable(cols, rows));
    }


  }
}



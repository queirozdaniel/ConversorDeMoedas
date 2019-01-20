import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=d045c63c";

void main() async {

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final bitcoinController = TextEditingController();

  double dolar;
  double btc;

  void _realChanged(String text){
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    bitcoinController.text = (real/btc).toStringAsFixed(8);
  }

  void _dolarChanged(String text){
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    bitcoinController.text = ((dolar * this.dolar)/btc).toStringAsFixed(8);
  }

  void _bitcoinChanged(String text){
    double bitcoin = double.parse(text);
    realController.text = (btc).toStringAsFixed(2);
    dolarController.text = (btc /dolar).toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot){
            // ignore: missing_enum_constant_in_switch
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text("Carregando dados..",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign:  TextAlign.center)
                );
              default:
                if(snapshot.hasError){
                  return Center(
                      child: Text("Erro ao carregar dados..",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign:  TextAlign.center)
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  btc = snapshot.data["results"]["currencies"]["BTC"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField("Bitcoin", "BTC", bitcoinController, _bitcoinChanged)

                      ],
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    ),
                  );
                }
            }
          }
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController t, Function f){
  return TextField(
    controller: t,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
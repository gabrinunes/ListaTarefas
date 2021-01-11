import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String dados = jsonEncode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  Future<String> _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _lerArquivo().then((dados) {
      print("SALVO......" + dados);
      setState(() {
        _listaTarefas = jsonDecode(dados);
      });
    });
  }

  Widget criarItemLista(context, index) {
    //final item = _listaTarefas[index]["titulo"];
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _ultimaTarefaRemovida = _listaTarefas[index];

        _listaTarefas.removeAt(index);
        _salvarArquivo();

        final snackbar = SnackBar(
          //backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          content: Text("Tarefa removida!!!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _listaTarefas.insert(index, _ultimaTarefaRemovida);
              });
              _salvarArquivo();
            },
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]["titulo"]),
        value: _listaTarefas[index]["realizada"],
        onChanged: (value) {
          setState(() {
            _listaTarefas[index]["realizada"] = value;
            _salvarArquivo();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //_salvarArquivo();
    print(_listaTarefas.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Adicionar Tarefa"),
                content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {}),
                actions: [
                  FlatButton(
                    child: Text("Cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text("Salvar"),
                    onPressed: () {
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItemLista,
            ),
          )
        ],
      ),
    );
  }
}

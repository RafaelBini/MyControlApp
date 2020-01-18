import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_control/selecionarConta.dart';

class DetalhesPage extends StatefulWidget {
  final DocumentSnapshot doc;

  DetalhesPage(this.doc);

  @override
  _DetalhesPageState createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  final descricaoController = TextEditingController();
  final valorController = TextEditingController();
  final GlobalKey<ScaffoldState> _scafoldKey = new GlobalKey<ScaffoldState>();

  Future<Map<String, Object>> createValorDialog(BuildContext context) {
    final valorSepararController = TextEditingController();
    final descricaoSepararController = TextEditingController();

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Separar"),
        content: Column(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                controller: descricaoSepararController,
                textInputAction: TextInputAction.next,
                autofocus: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: Text(
                    "R\$ ",
                  ),
                ),
                Flexible(
                  flex: 9,
                  child: TextFormField(
                    autofocus: true,
                    controller: valorSepararController,
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("OK"),
            onPressed: () {
              Map<String, Object> retorno = new Map<String, Object>();

              retorno["valor_filho"] =
                  double.parse(valorSepararController.text.toString());

              retorno["descricao_filho"] =
                  descricaoSepararController.text.toString();

              Navigator.of(context).pop(retorno);
            },
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext contextComS) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          '${widget.doc.documentID}',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 30.0),
            child: Center(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('contas')
                    .document(widget.doc.documentID)
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("Carregando...");
                  }

                  return Text(
                    'R\$ ${(snapshot.data["saldo atual"] as double).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  controller: descricaoController,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    contentPadding:
                        EdgeInsets.only(left: 20.0, bottom: 10, top: 10),
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Flexible(
                child: TextFormField(
                  controller: valorController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    contentPadding:
                        EdgeInsets.only(left: 20.0, bottom: 10, top: 10),
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                ),
              )
            ],
          ),
          Flexible(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection('transacoes')
                  .where("conta", isEqualTo: widget.doc.documentID)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: "Carregando",
                    ),
                  );

                return ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (ctx, index) {
                    DocumentSnapshot doc = snapshot.data.documents[index];
                    return Dismissible(
                      key: ValueKey(doc.documentID),
                      onDismissed: (direction) async {
                        // Deleta do firebase
                        await Firestore.instance
                            .collection('transacoes')
                            .document(doc.documentID)
                            .delete();
                        // Recebe o saldo atualizado do fire
                        DocumentReference docRef = Firestore.instance
                            .collection("contas")
                            .document(widget.doc.documentID);
                        DocumentSnapshot snapshot = await docRef.get();
                        double saldoAtual = snapshot.data["saldo atual"];
                        // Atualiza o saldo no firebase
                        Firestore.instance
                            .collection('contas')
                            .document(widget.doc.documentID)
                            .updateData({
                          "saldo atual": (saldoAtual + doc["valor"]),
                        });
                      },
                      background: Container(
                        color: Colors.redAccent,
                      ),
                      child: ListTile(
                        leading: Text(
                          DateFormat('dd/MM').format(
                              new DateTime.fromMillisecondsSinceEpoch(
                                  (doc["addTime"] as Timestamp).seconds *
                                      1000)),
                          style: TextStyle(fontSize: 15),
                        ),
                        title: Text(
                          doc["descricao"],
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: Text(
                          '- R\$ ${(doc["valor"] as double).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18),
                        ),
                        onTap: () {
                          createValorDialog(context).then((retorno) {
                            // Valida se tem saldo
                            if (doc["valor"] >= retorno["valor_filho"]) {
                              Navigator.of(context).pushNamed(
                                '/selecionarConta',
                                arguments: ArgumentosTelaSelecionar(
                                  valor_filho: retorno["valor_filho"],
                                  descricao_filho: retorno["descricao_filho"],
                                  transacao_mae: doc,
                                ),
                              );
                            } else {
                              _scafoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("Saldo insuficiente"),
                              ));
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          // Recebe as variaveis
          double valor = double.parse(valorController.text);
          String descricao = descricaoController.text;

          // Recebe o saldo atualizado do fire
          DocumentReference docRef = Firestore.instance
              .collection("contas")
              .document(widget.doc.documentID);
          DocumentSnapshot snapshot = await docRef.get();
          double saldoAtual = snapshot.data["saldo atual"];

          // Faz a inserção
          DateTime agora = DateTime.now();
          Firestore.instance
              .collection('transacoes')
              .document(DateFormat('yyyyMMddHHmmss').format(agora))
              .setData({
            "conta": widget.doc.documentID,
            "descricao": descricao,
            "valor": valor,
            "addTime": agora,
          });

          // Atualiza o saldo
          Firestore.instance
              .collection('contas')
              .document(widget.doc.documentID)
              .updateData({
            "saldo atual": (saldoAtual - valor),
          });

          // Limpa os campos
          valorController.clear();
          descricaoController.clear();
        },
      ),
    );
  }
}

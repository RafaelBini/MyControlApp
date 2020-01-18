import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArgumentosTelaSelecionar {
  final double valor_filho;
  final String descricao_filho;
  final DocumentSnapshot transacao_mae;

  ArgumentosTelaSelecionar(
      {this.descricao_filho, this.valor_filho, this.transacao_mae});
}

class SelecionarContaPage extends StatefulWidget {
  SelecionarContaPage({Key key, this.ats}) : super(key: key);

  final ArgumentosTelaSelecionar ats;

  @override
  _SelecionarContaPageState createState() => _SelecionarContaPageState();
}

class _SelecionarContaPageState extends State<SelecionarContaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Selecione uma conta",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('contas').snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (ctx, index) {
              DocumentSnapshot doc = snapshot.data.documents[index];
              return ListTile(
                title: Text(doc.documentID),
                trailing: Text(
                  'R\$ ${(doc["saldo atual"] as double).toStringAsFixed(2)}',
                ),
                onTap: () async {
                  // Recebe o valor_mãe
                  double valor_mae = widget.ats.transacao_mae["valor"];

                  // Recebe a conta_filho
                  String conta_filho = doc.documentID;

                  // Define o a referencia para contas
                  CollectionReference contasRef =
                      Firestore.instance.collection("contas");

                  // Recebe o saldo atual da conta mãe
                  DocumentSnapshot snapshot = await contasRef
                      .document(widget.ats.transacao_mae["conta"])
                      .get();
                  double saldo_mae = snapshot.data["saldo atual"];

                  // Recebe o saldo atual da conta filho
                  DocumentSnapshot snapshot2 =
                      await contasRef.document(conta_filho).get();
                  double saldo_filho = snapshot2.data["saldo atual"];

                  // Diminui o valor da transacao_mãe firestore
                  Firestore.instance
                      .collection('transacoes')
                      .document(widget.ats.transacao_mae.documentID)
                      .updateData({
                    "valor": (valor_mae - widget.ats.valor_filho),
                  });

                  // Aumenta o saldo da conta_mãe firestore
                  Firestore.instance
                      .collection('contas')
                      .document(widget.ats.transacao_mae["conta"])
                      .updateData({
                    "saldo atual": (saldo_mae + widget.ats.valor_filho),
                  });

                  // Insere a transacao_filho firestore
                  DateTime agora = DateTime.now();
                  Firestore.instance
                      .collection('transacoes')
                      .document(DateFormat('yyyyMMddHHmmss').format(agora))
                      .setData({
                    "conta": conta_filho,
                    "descricao": widget.ats.descricao_filho,
                    "valor": widget.ats.valor_filho,
                    "addTime": agora,
                  });

                  // Diminui o saldo da conta_filho firestore
                  Firestore.instance
                      .collection('contas')
                      .document(conta_filho)
                      .updateData({
                    "saldo atual": (saldo_filho - widget.ats.valor_filho),
                  });

                  // Direciona para a página de transações da conta_mãe
                  Firestore.instance
                      .collection('contas')
                      .document(widget.ats.transacao_mae["conta"])
                      .get()
                      .then((docSnap) {
                    Navigator.of(context).pushReplacementNamed(
                      "/detalhes",
                      arguments: docSnap,
                    );
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

class TestePage extends StatelessWidget {
  final Widget myLogo = Image.asset(
    "resources/icon.png",
    width: 100,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informações"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Hero(
              tag: "finha",
              child: Center(
                child: Draggable(
                  feedbackOffset: Offset(-100, -110),
                  feedback: myLogo,
                  childWhenDragging: myLogo,
                  child: myLogo,
                ),
              ),
            ),
          ),
          Text(
            "MyControl",
            style: TextStyle(fontSize: 28),
          ),
          SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              "Rafael Bini",
              style: TextStyle(fontSize: 27),
            ),
          ),
        ),
      ),
    );
  }
}

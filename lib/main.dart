import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  File _imagem;
  String _statusUpload = "Upload não iniciado";
  String _urlImagemRecuperada = null;
  
  Future _recuperarImagem(bool daCamera) async {
    
    File imagemSelecionada;
    
    if(daCamera){
      imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
    }else{
      imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _imagem = imagemSelecionada;
    });

  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
      .child("fotos")
      .child("foto1.jpg");

     StorageUploadTask task = arquivo.putFile(_imagem);

     task.events.listen((StorageTaskEvent storageEvent) {
       if( storageEvent.type == StorageTaskEventType.progress){
          setState(() {
            _statusUpload = "Em progresso";
          });  
       }else if( storageEvent.type == StorageTaskEventType.success){
         setState(() {
            _statusUpload = "Upload realizado com sucesso !!";
          });
       }

      });

      task.onComplete.then((StorageTaskSnapshot snapshot){
        _recuperarUrlImagem(snapshot);
      });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    setState(() {
      _urlImagemRecuperada = url;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecionar imagem"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(_statusUpload),
            RaisedButton(
              child: Text("Camera"),
              onPressed: () {
                _recuperarImagem(true);   
              },
            ),
             RaisedButton(
              child: Text("Galeria"),
              onPressed: () {
                _recuperarImagem(false);
              },
            ),
            _imagem == null ? Container() : Image.file(_imagem),
            _imagem == null ? 
            Container() :
             RaisedButton(
              child: Text("Upload storage"),
              onPressed: () {
                _uploadImagem();
              },
            ),
            _urlImagemRecuperada == null ? Container() : Image.network(_urlImagemRecuperada)

          ],
        )
      ),
    );
  }
}

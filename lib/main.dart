import 'package:flutter/material.dart';
import 'database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Contact Book'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ContactDataBase db = new ContactDataBase();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: db.initDB(),
        builder: (BuildContext context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            return mostrarContactos(context);
          }else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NuevoContacto()),
          );
        },
        tooltip: 'Agregar contacto',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  mostrarContactos(BuildContext context){
    return FutureBuilder(
      future: db.getAll(),
      builder: (BuildContext context, AsyncSnapshot<List<Contacto>> snapshot){
        if(snapshot.hasData){
          return ListView(
            children: <Widget>[
              for(Contacto contact in snapshot.data) ListTile(
                title: Text(contact.nombre.toString() + " " + contact.apellidos.toString()),
                subtitle: Text(contact.telefono.toString() + "\n" + contact.direccion.toString()),
                //leading: Icon(Icons.account_circle),
                trailing: Wrap(
                    spacing: 12,  // space between two icons
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.edit), onPressed: (){
                        print("CONTACTO: "+contact.nombre.toString());
                      }),
                      IconButton(icon: Icon(Icons.delete), onPressed: (){
                        db.delete(contact);
                        setState(() {
                        });
                      }),
                    ],
                ),
                isThreeLine: true,
              ),
            ],
          );
        }else{
          return Center(
            child: Text("Sin contactos."),
          );
        }

      }
    );
    setState(() {
    });
  }
}

class NuevoContacto extends StatelessWidget {
  ContactDataBase db = new ContactDataBase();

  var _formKey = GlobalKey<FormState>();  //<-------AQUI DECLARO EL FORMKEY
  String nmbr, plld, tlfn, drccn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuevo Contacto"),
      ),
      body: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,                   //<-------AQUI LO ASIGNO
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                TextFormField(

                  decoration: InputDecoration(
                      hintText: 'E.j: Brian',
                      labelText: 'Su nombre'
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Por favor, digite el nombre';
                    }
                    return null;
                  },
                  onSaved: (value) => nmbr = value,
                ),

                TextFormField(
                  decoration: InputDecoration(
                      hintText: 'E.j: Narvaez',
                      labelText: 'Sus apellidos'
                  ),
                  validator: (input) => input.length < 1 ? 'Apellido invalido' : null,
                  onSaved: (input) => plld = input,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: 'E.j: 123456789',
                      labelText: 'Su número de teléfono'
                  ),
                  validator: (input) => input.length < 1 ? 'Telefono invalido' : null,
                  onSaved: (input) => tlfn = input,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      hintText: 'E.j: Cr 11 #4-51',
                      labelText: 'Su dirección'
                  ),
                  validator: (input) => input.length < 1 ? 'Dirección invalida' : null,
                  onSaved: (input) => drccn = input,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: RaisedButton(
                        onPressed: () {
                            if(_formKey.currentState.validate()){
                              _formKey.currentState.save();

                              var contacto = Contacto(nmbr,plld,tlfn,drccn);
                              db.insert(contacto);
                              Navigator.pop(context);
                            }
                          },
                          child: Text("Agregar"),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
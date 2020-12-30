import 'package:flutter/material.dart';
import 'database.dart';
import 'package:toast/toast.dart';

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
      body: RefreshIndicator(
        onRefresh: (){
          Navigator.pushReplacement(
              context, 
              PageRouteBuilder(pageBuilder: (a, b, c)=>MyApp(),transitionDuration: Duration(seconds: 0),));

              Toast.show("Lista actualizada.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
            return Future.value(false);
          },
        child: FutureBuilder(
          future: db.initDB(),
          builder: (BuildContext context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done){
              return mostrarContactos();
            }else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NuevoContacto()),
            );
          });
        },
        tooltip: 'Agregar contacto',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  mostrarContactos(){
    return FutureBuilder(
      future: db.getAll(),
      builder: (BuildContext context, AsyncSnapshot<List<Contacto>> snapshot){
        if(snapshot.hasData){
          return ListView(
            children: <Widget>[
              for(Contacto contact in snapshot.data)
                ListTile(
                title: Text(contact.nombre.toString() + " " + contact.apellidos.toString()),
                subtitle: Text(contact.telefono.toString() + "\n" + contact.direccion.toString()),
                //leading: Icon(Icons.account_circle),
                trailing: Wrap(
                    spacing: 12,  // space between two icons
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.edit), onPressed: (){
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditarContacto(contact: contact)),
                          );
                        });

                      }),
                      IconButton(icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                    title: Text("Alerta"),
                                    content: Text("¿Desea eliminar este contacto"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Si"),
                                        onPressed: (){
                                          Navigator.of(context).pop(0);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text("No"),
                                        onPressed: (){
                                          Navigator.of(context).pop(1);
                                        },
                                      )
                                    ]
                                )
                            ).then((result){
                              if(result == 0){
                                db.delete(contact);
                                setState(() {
                                  Toast.show("Contacto eliminado", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                });
                              }
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
  }
}

class NuevoContacto extends StatelessWidget {
  GlobalKey _scaffold = GlobalKey();
  ContactDataBase db = new ContactDataBase();

  var _formKey = GlobalKey<FormState>();
  String nmbr, plld, tlfn, drccn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text("Nuevo Contacto"),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Alerta"),
                content: Text("¿Seguro que deseas salir?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Si"),
                    onPressed: (){
                      Navigator.of(context).pop(0);
                    },
                  ),
                  FlatButton(
                    child: Text("No"),
                    onPressed: (){
                      Navigator.of(context).pop(1);
                    },
                  )
                ]
              )
            ).then((result){
              if(result == 0){
                Navigator.of(context).pop();
              }
            });
          },
        ),
      ),
      body: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
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
                            agregarContacto(context);
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

  agregarContacto(BuildContext context) {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      var contacto = Contacto(nmbr,plld,tlfn,drccn);
      db.insert(contacto);
      Toast.show("Contacto agregado.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      Navigator.pop(context);
    }
  }
}

class EditarContacto extends StatelessWidget {
  ContactDataBase db = new ContactDataBase();

  var _formKey = GlobalKey<FormState>();
  String nmbr, plld, tlfn, drccn;
  int id;

  final Contacto contact;
  EditarContacto({this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Contacto"),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text("Alerta"),
                    content: Text("¿Desea guardar lo cambios?"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Si"),
                        onPressed: (){
                          Navigator.of(context).pop(0);
                        },
                      ),
                      FlatButton(
                        child: Text("No"),
                        onPressed: (){
                          Navigator.of(context).pop(1);
                        },
                      ),
                      FlatButton(
                        child: Text("Cancelar"),
                        onPressed: (){
                          Navigator.of(context).pop(-1);
                        },
                      )
                    ]
                )
            ).then((result){
              if(result == 0){
                actualizarContacto(context);
              }else{
                if(result == 1){
                  Navigator.of(context).pop();
                }
              }
            });
          },
        ),
      ),
      body: Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget> [
                  TextFormField(
                    initialValue: contact.nombre.toString(),
                    decoration: InputDecoration(
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
                    initialValue: contact.apellidos.toString(),
                    decoration: InputDecoration(
                        labelText: 'Sus apellidos'
                    ),
                    validator: (input) => input.length < 1 ? 'Apellido invalido' : null,
                    onSaved: (input) => plld = input,
                  ),
                  TextFormField(
                    initialValue: contact.telefono.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Su número de teléfono'
                    ),
                    validator: (input) => input.length < 1 ? 'Telefono invalido' : null,
                    onSaved: (input) => tlfn = input,
                  ),
                  TextFormField(
                    initialValue: contact.direccion.toString(),
                    decoration: InputDecoration(
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
                            actualizarContacto(context);
                          },
                          child: Text("Guardar"),
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

  actualizarContacto(BuildContext context){
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      id = contact.id;
      var contacto = Contacto(nmbr,plld,tlfn,drccn);
      db.update(contacto, id);

      Navigator.pop(context);
      Toast.show("Contacto actualizado.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void maain(){
  runApp(BleHomeScreen());
}

class BleHomeScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:"BLE",
      home: StreamBuilder<BluetoothAdapterState>(
          stream: FlutterBluePlus.adapterState,
          initialData: BluetoothAdapterState.unknown ,
          builder: (c, snapshot){
            final bleState = snapshot.data;
            if(bleState == BluetoothAdapterState.on){
              return Center(child: Text("BLE is ON"));
            }
             else{
              return Center(child: Text("BLE is OF"));
            }
          }
      )
    );
  }
}
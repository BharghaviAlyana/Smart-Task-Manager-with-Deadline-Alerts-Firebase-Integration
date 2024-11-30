//uihelper.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class UiHelper{
  static CustomerTextFeild(TextEditingController controller,String text,IconData iconData,bool toHide,{VoidCallback? onToggleVisibility}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
      child: TextField(
        controller: controller,
        obscureText: toHide,
        decoration: InputDecoration(
          hintText: text,
          suffixIcon: toHide && onToggleVisibility != null?
          IconButton(onPressed: onToggleVisibility, icon: Icon(iconData))
          :Icon(iconData),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          )
        ),
      ),
    );

  }
  static CustomButton(VoidCallback VoidCallback,String text){
    return SizedBox(height: 50,width: 300 ,child:ElevatedButton(onPressed: (){
      VoidCallback();

    },
    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25)
    ),
    backgroundColor: Colors.blue),

    child:Text(text,style: TextStyle(color: Colors.white,fontSize: 20),) 
    )
    );

  }
  static CustomAlertBox(BuildContext context,String text){
    return showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text(text),
        actions:[
          TextButton(onPressed: (){
            Navigator.pop(context);
          },child: Text("OK"),)
        ]
      );

    });
  }
}

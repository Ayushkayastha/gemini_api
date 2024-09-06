import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final Gemini gemini=Gemini.instance;
  List<ChatMessage> messages=[];
  ChatUser currentUser=ChatUser(id: "0",firstName: "User");
  ChatUser geminiUser=ChatUser(id: "1",firstName: "Gemini");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gemini chat'),),
      body: _buildUI(),
    );
  }

  Widget _buildUI (){
    return DashChat(currentUser: currentUser, onSend: _sendMessage, messages: messages);
  }

  void _sendMessage(ChatMessage chatmessage){
    setState(() {
      messages=[chatmessage,...messages];
    });

    try{
      String question=chatmessage.text;
      gemini.streamGenerateContent(question).listen((event){

        ChatMessage? lastmessage=messages.firstOrNull;

        if(lastmessage != null && lastmessage.user==geminiUser){

          lastmessage=messages.removeAt(0);
          String response=event.content?.parts?.fold("", (previous,current)=>"$previous ${current.text}")??"";
          lastmessage.text += response;
          setState(() {
            messages=[lastmessage!,...messages];
          });
        }



        else{
          String response=event.content?.parts?.fold("", (previous,current)=>"$previous ${current.text}")??"";
          ChatMessage message=ChatMessage(user: geminiUser, createdAt: DateTime.now(),text: response );
          setState(() {
            messages=[message, ...messages];
          });
        }
      });
    }
    catch(e)
    {
      print(e);
    }
  }
}

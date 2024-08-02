import 'dart:io';

import 'package:flutter/material.dart';
import 'package:groq_sdk/groq_sdk.dart';
import 'package:loggy/loggy.dart';
import 'package:tazavec/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with UiLoggy {
  String questionText = "";
  double currSliderValue = 3;

  late Groq groqModel;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    String apiKey = const String.fromEnvironment('API_KEY');
    if (apiKey.isEmpty) {
      loggy.error("Failed to load API KEY!");
      exit(1);
    }

    groqModel = Groq(apiKey);

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          appTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      questionText,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select the DEEPNESS level:".toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    min: 1,
                    max: 5,
                    value: currSliderValue,
                    divisions: 4,
                    label: currSliderValue.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        currSliderValue = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  hintText: "Enter topic or occasion... (Optional)",
                  hintStyle: TextStyle(
                    fontSize: 14,
                  ),
                ),
                controller: _controller,
              ),
              const SizedBox(height: 64),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        setState(() {
                          questionText = "";
                        });

                        final chat = groqModel.startNewChat(GroqModels.llama3_8b);

                        chat.stream.listen((event) {
                          event.when(request: (requestEvent) {
                            loggy.info('Request sent...');
                            loggy.info(requestEvent.message.content);
                          }, response: (responseEvent) async {
                            loggy.info('Received response: ${responseEvent.response.choices.first.message}');

                            for (String word in responseEvent.response.choices.first.message.split(' ')) {
                              await Future.delayed(const Duration(milliseconds: 100), () {
                                setState(() {
                                  questionText += "$word ";
                                });
                              });
                            }
                          });
                        });

                        final (response, usage) = await chat.sendMessage(
                          "Context: \nTazavec is an app designed to help users get to know their friends,"
                              "potential partners, or acquaintances better. It is supposed to create ice-breakers "
                              "between the two people or more by generating questions."
                              "that users can ask the other person. The questions vary in depth from 1 to 5,"
                              "with 1 being almost shallow and 5 being the deepest. Users can also specify a "
                              "topic or occasion for the questions using an optional text field.\n\n"
                              "Generate the question now. Return only a question itself.\n"
                              "Depth level for this question: ${currSliderValue.toInt()}\n"
                              "Occasion or topic for this question: ${_controller.value.text}\n\n"
                              "Usage Notes: \nIf no topic is specified, generate general questions appropriate for the specified depth.\n"
                              "Ensure that the questions are respectful and appropriate for the context provided.\n"
                              "Return only a question without any other text. Try to keep it short.",
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "GENERATE",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:groq_sdk/groq_sdk.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loggy/loggy.dart';
import 'package:tazavec/ads/interstitial_ad_service.dart';
import 'package:tazavec/ai/models.dart';
import 'package:tazavec/main.dart';
import 'package:tazavec/ai/prompts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with UiLoggy {
  late String targetModel;

  late Groq groqModel;
  late GroqChat groqChat;

  final Prompts prompts = Prompts();

  String questionText = "";

  double currSliderValue = 3;

  final TextEditingController _controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  int buttonPressedCounter = 0;
  bool isFirst = true;

  InterstitialAdService adService = InterstitialAdService();

  @override
  void initState() {
    super.initState();
    _initializeGroq();
    _createInitialAnimation();
  }

  void _initializeGroq() async {
    const apiKey = String.fromEnvironment('API_KEY');
    if (apiKey.isEmpty) {
      loggy.error("Failed to load API KEY!");
      exit(1);
    }

    groqModel = Groq(apiKey);

    for (String model in groqModels) {
      if (await groqModel.canUseModel(model)) {
        availableModels.add(model);

        if (availableModels.length == 1) {
          targetModel = model;
          groqChat = groqModel.startNewChat(targetModel);
          loggy.info("Starting new chat with model: $targetModel");
        }
      }
    }

    _startGroqStream();
  }

  void _startGroqStream() {
    groqChat.stream.listen((event) {
      event.when(
        request: (requestEvent) {
          loggy.info('Request sent...');
          loggy.info(requestEvent.message.content);
        },
        response: (responseEvent) async {
          loggy.info('Received response: ${responseEvent.response.choices.first.message}');
    
          final words = responseEvent.response.choices.first.message.split(' ');
          for (final word in words) {
            await Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                questionText += "$word ";
              });
            });
          }
        },
      );
    });
  }

  void _createInitialAnimation() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      String targetMessage = "Hey! I am Tazavec! Ready to get to know each other deeper?";
      List<String> words = targetMessage.split(' ');

      for (final word in words) {
        await Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            questionText += "$word ";
          });
        });
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: "Change Target Model",
              onSelected: (String value) {
                showDialog(
                  context: context,
                  builder: (c) {
                    return AlertDialog(
                      title: const Text("Are you sure you want to change the model?"),
                      content: Text(
                        "New model: $value\n\nNote: Changing the model will restart the chat - some of the question may therefore repeat.",
                      ),
                      actions: [
                        TextButton(
                          child: const Text("No"),
                          onPressed: () {
                            Navigator.of(c).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () {
                            setState(() {
                              targetModel = value;
                            });

                            groqChat = groqModel.startNewChat(targetModel);
                            _startGroqStream();
                            isFirst = true;

                            loggy.info("Switching chat model: $targetModel");
                            Navigator.of(c).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              itemBuilder: (BuildContext context) {
                return availableModels.map((String model) {
                  return PopupMenuItem<String>(
                    value: model,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(model),
                        if (model == targetModel) const SizedBox(width: 4),
                        if (model == targetModel) const Icon(Icons.check),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
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
                _buildSlider(context),
                const SizedBox(height: 16),
                _buildTextField(),
                const SizedBox(height: 64),
                _buildGenerateButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    return Column(
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
    );
  }

  Widget _buildTextField() {
    return TextField(
      maxLength: 60,
      focusNode: focusNode,
      style: const TextStyle(
        fontSize: 14,
      ),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        hintText: "Enter topic or occasion... (Optional)",
        hintStyle: TextStyle(
          fontSize: 14,
        ),
      ),
      controller: _controller,
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _onGenerateButtonPressed,
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
    );
  }

  Future<void> _onGenerateButtonPressed() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No internet connection!")),
      );

      return;
    }

    if ((buttonPressedCounter % 5) == 4) {
      adService.loadAd();
    }
    buttonPressedCounter++;

    setState(() {
      questionText = "";
    });

    focusNode.unfocus();

    final prompt = isFirst
        ? prompts.getInitialPrompt(currSliderValue.toInt(), _controller.value.text)
        : prompts.getNewQuestionPrompt(currSliderValue.toInt(), _controller.value.text);

    await groqChat.sendMessage(prompt);

    isFirst = false;
  }
}

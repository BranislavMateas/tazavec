class Prompts {
  Prompts();

  String getInitialPrompt(int currSliderValue, String occasion) {
    return "Context: \nTazavec is an app designed to help users get to know their friends,"
        "potential partners, or acquaintances better. It is supposed to create ice-breakers "
        "between the two people or more by generating questions "
        "that users can ask the other person. The questions vary in depth from 1 to 5,"
        "with 1 being almost shallow and 5 being the deepest. Users can also specify a "
        "topic or occasion for the questions using an optional text field.\n\n"
        "Generate the question now. Return only a question itself.\n"
        "Depth level for this question: $currSliderValue\n"
        "Occasion or topic for this question: $occasion\n\n"
        "Usage Notes: \nIf no topic is specified, generate general questions appropriate for the specified depth.\n"
        "Ensure that the questions are respectful and appropriate for the context provided.\n"
        "Return only a question without any other text. Try to keep it short.";
  }

  String getNewQuestionPrompt(int currSliderValue, String occasion) {
    return "Please, generate another question now. Return only a question itself.\n"
        "Be careful and return a question that was not generated yet throughout the session.\n"
        "Make sure it does not contain same key words as the questions from before.\n"
        "Depth level for this question: $currSliderValue\n"
        "Occasion or topic for this question: $occasion\n\n"
        "Usage Notes: \nIf no topic is specified, generate general questions appropriate for the specified depth.\n"
        "Ensure that the questions are respectful and appropriate for the context provided.\n"
        "Return only a question without any other text. Try to keep it short.";
  }
}

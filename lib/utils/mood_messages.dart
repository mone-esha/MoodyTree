const List<List<String>> moodMessages = [
  //energetic
  [
    "That energy is contagious. Use it well today.",
    "You're on fire. Ride the momentum.",
    "Full battery mode. Go make something happen.",
    "Love this energy. Keep it flowing.",
    "You woke up and chose momentum. Respect.",
  ],

  //happy
  [
    "Joy looks good on you.",
    "Good days deserve to be remembered. You just saved one.",
    "Something's shining today. Soak it in.",
    "Your smile today is proof things can shift.",
    "This is one to look back on. Glad you felt it.",
  ],

  //calm
  [
    "Steady is underrated. Nice work finding balance.",
    "Calm is a superpower. You tapped into it today.",
    "Not every day has to be extraordinary. This one counted.",
    "Small moments of peace add up. Keep noticing them.",
    "You're doing better than you think.",
  ],

  //sad
  [
    "Even the smallest step counts. You showed up today.",
    "Low days are still part of the story. Thank you for checking in.",
    "You don't have to feel great to deserve a good day.",
    "Rest is not giving up. It's how you keep going.",
    "The fact that you logged this means you're paying attention. That matters.",
  ],

  //annoyed
  [
    "Frustration means you care. That's not nothing.",
    "Some days test you. You're still here.",
    "Naming the feeling is the first step. You did that.",
    "Annoyed is valid. Tomorrow gets another try.",
    "You don't have to be okay every day. This counts too.",
  ],

  //tired
  [
    "Rest is productive. You earned this pause.",
    "Tired is your body asking for kindness. Listen to it.",
    "You made it through. That's not small.",
    "Some days you just have to breathe. Today was that day.",
    "Be gentle with yourself. You did enough.",
  ],
];

String randomMessageForMood(int moodIndex) {
  final list = moodMessages[moodIndex.clamp(0, moodMessages.length - 1)];
  return list[DateTime.now().microsecondsSinceEpoch % list.length];
}
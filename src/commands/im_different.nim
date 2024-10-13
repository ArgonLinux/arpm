# cutest thing I found in Portal 2 :D
import librng
import ../libarpm/io

const
  MESSAGES =
    [
      "I'm different! D:",
      "Thank you :D",
      "Don't make " & YELLOW & "lemonade" & RESET & '!',
      "Get " & RED & BOLD & "MAD" & RESET,
      "The answer is beneath us...",
      "Prometheus was punished by the Gods for giving the gift of knowledge to man. He was cast into the bowels of the earth and pecked by birds.",
      "Her name is " & BOLD & "Caroline" & RESET & '.',
      BOLD & "Rememeber that!" & RESET
    ]

proc imDifferent*() =
  let rng = newRng(algo = Lehmer64)
  echo rng.choice(MESSAGES)

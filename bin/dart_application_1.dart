import 'dart:io';
import 'dart:math';

void main() {
    while (true) { 
    print('Выберите тип игры: \n 1 - с другом\n 2 - с роботом');
    print('Введите тип игры:');
    String? tup_igr = stdin.readLineSync();

    switch (tup_igr) {
      case '1':
        player();
        break;
      case '2':
        robot();
        break;
      default:
        print("Неправильно введён тип игры. Попробуйте снова.");
        continue; 
    }

    print("Хотите сыграть снова? (да/нет)");
    String? otvet = stdin.readLineSync()?.trim(); 

    if (otvet != null && (otvet.toLowerCase() == 'да')) {
      print("Продолжаем игру.");
    } else {
      print("Игра завершена.");
      break; 
    }
  }
}

List<List<String>> createBoard(int size) {
  return List.generate(size, (_) => List.generate(size, (_) => ' '));
}

void printBoard(List<List<String>> board) {
  for (int i = 0; i < board.length; i++) {
    String row = board[i].map((cell) => cell.isEmpty ? ' ' : cell).join(' | ');
    print(' $row ');
    if (i != board.length - 1) {
      print('-' * (board.length * 4 - 1));
    }
  }
}

bool Victory(List<List<String>> board, String player) {
  int size = board.length;

  for (int i = 0; i < size; i++) {
    if (board[i].every((cell) => cell == player) || board.map((row) => row[i]).every((cell) => cell == player)) { 
      return true;
    }
  }

  if (List.generate(size, (i) => board[i][i]).every((cell) => cell == player) || 
  List.generate(size, (i) => board[i][size - i - 1]).every((cell) => cell == player)) { 
    return true;
  }

  return false;
}

bool Nichia(List<List<String>> board) {
  return board.expand((row) => row).every((cell) => cell != ' ');
}

void player(){
  print("Введите размер поля: ");
  int razmer_pola = int.parse(stdin.readLineSync()!);
  if (razmer_pola < 3 || razmer_pola > 9)
  {
    print("Неправильно введен размер поля.");
    return;
  }

  List<List<String>> board = createBoard(razmer_pola);
  String Player = Random().nextBool() ? 'X' : 'O';
  print("Первым ходит игрок $Player");

  while (true) {
    printBoard(board);

    while (true) {
      print("Игрок $Player, введите строку и столбец (например, 1 1): ");
      List<String> input = stdin.readLineSync()!.split(' ');  
      int row = int.parse(input[0]) - 1;
      int col = int.parse(input[1]) - 1;

      if (row >= 0 && row < board.length && col >= 0 && col < board.length && board[row][col] == ' ') {
        board[row][col] = Player;
        break;
      } else {
        print("Неверный ход. Попробуйте снова.");
      }
    }

    if (Victory(board, Player)) {
      printBoard(board);
      print("Игрок $Player победил!");
      break;
    } else if (Nichia(board)) {
      printBoard(board);
      print("Ничья!");
      break;
    }

    Player = (Player == 'X') ? 'O' : 'X';
  }
}

void robot(){
  print("Введите размер поля: ");
  int razmer_pola = int.parse(stdin.readLineSync()!);
  if (razmer_pola < 3 || razmer_pola > 9)
  {
    print("Неправильно введен размер поля.");
    return;
  }

  List<List<String>> board = createBoard(razmer_pola);
  bool rand = Random().nextBool();
  String Player = rand ? 'X' : 'O';
  print(rand ? "Первым ходит человек (X)" : "Первым ходит робот (O)");

  while (true) {
    printBoard(board);

    if (Player == 'X') {
      while (true) {
        print("Игрок $Player, введите строку и столбец (например, 1 1): ");
        List<String> input = stdin.readLineSync()!.split(' ');  
        int row = int.parse(input[0]) - 1;
        int col = int.parse(input[1]) - 1;

        if (row >= 0 && row < board.length && col >= 0 && col < board.length && board[row][col] == ' ') {
          board[row][col] = Player;
          break;
        } else {
          print("Неверный ход. Попробуйте снова.");
        }
      }
    } else {
      Random random = Random();
      int size = board.length;

      while (true) {
        int row = random.nextInt(size);
        int col = random.nextInt(size);

        if (board[row][col] == ' ') {
          board[row][col] = Player;
          print("Робот ($Player) сделал ход: ${row + 1} ${col + 1}");
          break;
        }
      }
    }

    if (Victory(board, Player)) {
      printBoard(board);
      print("Игрок $Player победил!");
      break;
    } else if (Nichia(board)) {
      printBoard(board);
      print("Ничья!");
      break;
    }

    Player = (Player == 'X') ? 'O' : 'X';
  }
}

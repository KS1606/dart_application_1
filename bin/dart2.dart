import 'dart:io';
import 'dart:math';

const int gridSize = 10;

const shipSpecifications = {
  4: 1, 
  3: 2,
  2: 3,
  1: 4, 
};

void main() {
  List<List<String>> playerGrid = List.generate(gridSize, (_) => List.filled(gridSize, '🔳'));
  List<List<String>> computerGrid = List.generate(gridSize, (_) => List.filled(gridSize, '🔳')); 
  List<List<String>> computerShips = List.generate(gridSize, (_) => List.filled(gridSize, '🔳'));

  // Счётчики попаданий, промахов и оставшихся кораблей
  int playerHits = 0;
  int playerMisses = 0;
  int computerHits = 0;
  int computerMisses = 0;

  placeShipsAutomatically(computerShips);

  print("Морской бой!");
  print("Хотите расставить корабли сами? Введите '1' для ручной расстановки или '2' для автоматической:");
  String? choice = stdin.readLineSync();
  if (choice == '1') {
    placeShipsManually(playerGrid);
  } else {
    print("Корабли будут расставлены автоматически.");
    placeShipsAutomatically(playerGrid);
  }

  while (true) {
    printGrid(playerGrid, "Ваше поле:");
    printGrid(computerGrid, "Поле противника (ваши выстрелы):");
    print("Введите координаты для выстрела (например, 1 1):");
    List<int> coordinates = getCoordinates();

    if (shoot(computerShips, computerGrid, coordinates)) {
      playerHits++;
      print("Попадание!");
    } else {
      playerMisses++;
      print("Мимо!");
    }

    if (checkWin(computerShips)) {
      print("Поздравляем, вы победили!");
      saveStatistics("Игрок", playerGrid, playerHits, playerMisses, computerHits, computerMisses);
      break;
    }

    print("Ход компьютера...");
    List<int> computerShot = generateRandomCoordinates();
    if (shoot(playerGrid, playerGrid, computerShot)) {
      computerHits++;
      print("Компьютер попал в вашу цель!");
    } else {
      computerMisses++;
      print("Компьютер промахнулся!");
    }

    if (checkWin(playerGrid)) {
      print("Вы проиграли. Компьютер победил.");
      saveStatistics("Компьютер", computerGrid, computerHits, computerMisses, playerHits, playerMisses);
      break;
    }
  }
}

void saveStatistics(String winner, List<List<String>> grid, int hits, int misses, int opponentHits, int opponentMisses) {
  int remainingShips = countRemainingShips(grid);

  // Создаём каталог для сохранения статистики
  Directory('statistics').createSync();
  File file = File('statistics/game_statistics.txt');

  // Формируем текст статистики
  String stats = '''
  Победитель: $winner
  Количество попаданий: $hits
  Количество промахов: $misses
  Количество кораблей, оставшихся на поле: $remainingShips
  Попадания противника: $opponentHits
  Промахи противника: $opponentMisses
  ''';

  // Сохраняем статистику в файл
  file.writeAsStringSync(stats);

  print("Статистика игры сохранена в файл 'statistics/game_statistics.txt'.");
}

int countRemainingShips(List<List<String>> grid) {
  int count = 0;
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      if (grid[i][j] == '🚢') {
        count++;
      }
    }
  }
  return count;
}

void placeShipsAutomatically(List<List<String>> grid) {
  Random random = Random();
  for (var shipLength in shipSpecifications.keys) {
    for (int i = 0; i < shipSpecifications[shipLength]!; i++) {
      while (true) {
        bool horizontal = random.nextBool();
        int row = random.nextInt(gridSize);
        int col = random.nextInt(gridSize);

        if (canPlaceShip(grid, row, col, shipLength, horizontal)) {
          placeShip(grid, row, col, shipLength, horizontal);
          break;
        }
      }
    }
  }
}

void placeShipsManually(List<List<String>> grid) {
  for (var shipLength in shipSpecifications.keys) {
    for (int i = 0; i < shipSpecifications[shipLength]!; i++) {
      printGrid(grid, "Ваше поле:");
      print("Размещайте корабль длиной $shipLength (номер ${i + 1} из ${shipSpecifications[shipLength]}).");
      while (true) {
        print("Введите начальные координаты (например, 1 1):");
        List<int> startCoordinates = getCoordinates();
        print("Выберите ориентацию: 'h' для горизонтального или 'v' для вертикального:");
        String? orientation = stdin.readLineSync();
        bool horizontal = (orientation == 'h');

        if (canPlaceShip(grid, startCoordinates[0], startCoordinates[1], shipLength, horizontal)) {
          placeShip(grid, startCoordinates[0], startCoordinates[1], shipLength, horizontal);
          break;
        } else {
          print("Невозможно разместить корабль. Попробуйте другие координаты или ориентацию.");
        }
      }
    }
  }
}

bool canPlaceShip(List<List<String>> grid, int row, int col, int length, bool horizontal) {
  for (int i = 0; i < length; i++) {
    int r = row + (horizontal ? 0 : i);
    int c = col + (horizontal ? i : 0);

    if (r >= gridSize || c >= gridSize || grid[r][c] != '🔳') {
      return false;
    }

    if (!isAreaClear(grid, r, c)) {
      return false;
    }
  }
  return true;
}

bool isAreaClear(List<List<String>> grid, int row, int col) {
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      int r = row + i;
      int c = col + j;

      if (r >= 0 && r < gridSize && c >= 0 && c < gridSize && grid[r][c] == '🚢') {
        return false;
      }
    }
  }
  return true;
}

void placeShip(List<List<String>> grid, int row, int col, int length, bool horizontal) {
  for (int i = 0; i < length; i++) {
    int r = row + (horizontal ? 0 : i);
    int c = col + (horizontal ? i : 0);
    grid[r][c] = '🚢';
  }
}

void printGrid(List<List<String>> grid, String title) {
  print(title);

  stdout.write("     "); 
  for (int col = 1; col <= gridSize; col++) {
    stdout.write("${col.toString().padLeft(2)} "); 
  }
  print("");

  for (int row = 0; row < gridSize; row++) {
    stdout.write("${(row + 1).toString().padLeft(2)} | ");
    for (int col = 0; col < gridSize; col++) {
      stdout.write("${grid[row][col].padLeft(2)} ");
    }
    print("");
  }

  stdout.write("     "); 
  for (int col = 1; col <= gridSize; col++) {
    stdout.write("${col.toString().padLeft(2)} "); 
  }
  print("");
}

List<int> getCoordinates() {
  while (true) {
    try {
      String? input = stdin.readLineSync();
      if (input == null || input.isEmpty) {
        throw FormatException("Пустой ввод.");
      }
      List<int> coords = input.split(' ').map(int.parse).toList();
      if (coords.length != 2 || coords[0] < 1 || coords[0] > gridSize || coords[1] < 1 || coords[1] > gridSize) {
        throw FormatException("Неверный формат ввода.");
      }
      return [coords[0] - 1, coords[1] - 1];
    } catch (e) {
      print("Ошибка: введите два числа от 1 до $gridSize, разделённых пробелом.");
    }
  }
}

bool shoot(List<List<String>> targetGrid, List<List<String>> displayGrid, List<int> coordinates) {
  int row = coordinates[0];
  int col = coordinates[1];

  if (targetGrid[row][col] == '🚢') {
    targetGrid[row][col] = '📍';
    displayGrid[row][col] = '📍';
    return true;
  } else if (targetGrid[row][col] == '🔳') {
    targetGrid[row][col] = '🌊';
    displayGrid[row][col] = '🌊';
    return false;
  }
  return false; 
}

bool checkWin(List<List<String>> grid) {
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      if (grid[i][j] == '🚢') {
        return false;
      }
    }
  }
  return true;
}

List<int> generateRandomCoordinates() {
  Random random = Random();
  return [random.nextInt(gridSize), random.nextInt(gridSize)];
}

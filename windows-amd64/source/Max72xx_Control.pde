import processing.serial.*;

Serial myPort;  // Создаем объект Serial
String inputText = ""; // Переменная для хранения текста для отправки
String[] ports; // Массив для хранения доступных портов
int selectedPortIndex = 0; // Индекс выбранного порта
boolean sendButtonHover = false; // Флаг для наведения курсора на кнопку отправки
boolean portButtonHover = false; // Флаг для наведения курсора на кнопку выбора порта

void setup() {
  size(400, 250); // Устанавливаем размер окна
  ports = Serial.list(); // Получаем список доступных портов
  
  if (ports.length > 0) {
    myPort = new Serial(this, ports[selectedPortIndex], 9600); // Устанавливаем связь с первым доступным портом
  } else {
    println("Нет доступных портов.");
  }
  
  noLoop(); // Останавливаем цикл draw, так как он не нужен
}

void draw() {
  background(255); // Задаем белый фон
  fill(0); // Задаем черный цвет текста
  textSize(20);
  
  // Заголовок
  textAlign(CENTER);
  text("Управление матрицей", width / 2, 30);
  
  // Выбор порта
  textSize(16);
  textAlign(LEFT);
  text("Выберите порт:", 20, 70);
  
  for (int i = 0; i < ports.length; i++) {
    if (i == selectedPortIndex) {
      fill(0, 120, 255); // Подсветка выбранного порта
    } else {
      fill(0);
    }
    text(ports[i], 20, 100 + i * 30);
  }
  
  fill(0); // Сбрасываем цвет
  textSize(16);
  text("Введите текст:", 20, 150);
  text(inputText, 20, 180); // Отображаем введенный текст
  
  // Кнопка отправки
  if (sendButtonHover) {
    fill(200); // Изменяем цвет кнопки при наведении
  } else {
    fill(255); // Цвет кнопки
  }
  rect(300, 150, 80, 40, 5); // Рисуем кнопку
  fill(0);
  textAlign(CENTER);
  text("Отправить", 300 + 40, 175); // Текст на кнопке

  // Кнопка выбора порта
  if (portButtonHover) {
    fill(200); // Изменяем цвет кнопки при наведении
  } else {
    fill(255); // Цвет кнопки
  }
  rect(300, 100, 80, 40, 5); // Рисуем кнопку
  fill(0);
  text("Выбрать", 300 + 40, 125); // Текст на кнопке
}

void mouseMoved() {
  sendButtonHover = mouseX > 300 && mouseX < 380 && mouseY > 150 && mouseY < 190; 
  portButtonHover = mouseX > 300 && mouseX < 380 && mouseY > 100 && mouseY < 140; 
}

void mousePressed() {
  if (sendButtonHover) {
    if (myPort != null) {
      myPort.write(inputText + "\n"); // Отправляем текст в Arduino
      inputText = ""; // Сбрасываем текст после отправки
    }
  }
  
  if (portButtonHover) {
    selectedPortIndex = (selectedPortIndex + 1) % ports.length; // Переход вниз по списку портов
    if (myPort != null) {
      myPort.stop(); // Останавливаем старый порт
    }
    myPort = new Serial(this, ports[selectedPortIndex], 9600); // Устанавливаем новый порт
  }
  
  redraw(); // Перерисовываем окно
}

void keyPressed() {
  if (key == BACKSPACE) {
    if (inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length() - 1); // Удаляем последний символ
    }
  } else if (key >= ' ' && key <= '~') { // Только символы
    inputText += key; // Добавляем символ к тексту
  }
  
  redraw(); // Перерисовываем окно
}

void serialEvent(Serial myPort) {
  String inString = myPort.readStringUntil('\n'); // Чтение строки из серийного порта
  if (inString != null) {
    inString = trim(inString); // Убираем пробелы
    println("Received: " + inString); // Выводим полученное значение в консоль
  }
}

Board board;

void setup() {
  size(640, 640);
  board = new Board();
}

void draw() {
  board.display();
}

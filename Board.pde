class Board {
  
  int side;
  State states[][];
  State pstates[][];
  boolean on;
  Pair active;
  ArrayList<Pair> free;
  ArrayList<Pair> perilous;
  char move;
  PImage[] pieces;
  
  
  Board() {
    side = width/8;
    states = new State[8][8];
    pstates = new State[8][8];
    
    for (int j = 0; j < 8; j++) {
      states[1][j] = new State('B', 'P');
      states[6][j] = new State('W', 'P');
    }
    
    states[0][0] = new State('B', 'R');
    states[0][7] = new State('B', 'R');
    states[7][0] = new State('W', 'R');
    states[7][7] = new State('W', 'R');
    
    states[0][1] = new State('B', 'K');
    states[0][6] = new State('B', 'K');
    states[7][1] = new State('W', 'K');
    states[7][6] = new State('W', 'K');
    
    states[0][2] = new State('B', 'B');
    states[0][5] = new State('B', 'B');
    states[7][2] = new State('W', 'B');
    states[7][5] = new State('W', 'B');
    
    states[0][3] = new State('B', 'Q');
    states[0][4] = new State('B', 'E');
    states[7][3] = new State('W', 'Q');
    states[7][4] = new State('W', 'E');
    
    for (int i = 2; i <= 5; i++) {
      for (int j = 0; j < 8; j++) {
        states[i][j] = new State('G', 'V');
      }
    }
    
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        pstates[i][j] = new State(states[i][j].shade, states[i][j].type);
      }
    }
      
    on = false;
    move = 'W';
    
    pieces = new PImage[12];
    for (int i = 0; i < 12; i++) {
      pieces[i] = loadImage(i + ".png");
    }
  }
  
  int getPieceCode(char shade, char type) {
    int code = 0;
    if (type == 'E') code = 0;
    if (type == 'Q') code = 1;
    if (type == 'R') code = 2;
    if (type == 'B') code = 3;
    if (type == 'K') code = 4;
    if (type == 'P') code = 5;
    if (shade == 'W') code += 6;
    return code;
  }
  
  void display() {
    noStroke();      
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if ((i + j) % 2 == 0) fill(227, 193, 111);
        else fill(184, 139, 74);
        square(j * side, i * side, side);
      }
    }
    
    if (on) { 
      fill(0, 127, 255, 128);
      square(active.second * side, active.first * side, side);
      
      fill(80, 220, 100, 128);
      for (Pair pair : free) {
        square(pair.second * side, pair.first * side, side);
      }
      
      fill(155, 17, 30, 128);
      for (Pair pair : perilous) {
        square(pair.second * side, pair.first * side, side);
      }
    }
    
    imageMode(CORNERS);
    tint(255, 255);
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        State state = board.states[i][j];
        if (state.type == 'V') continue;
        int code = getPieceCode(state.shade, state.type);
        image(pieces[code], j * board.side, i * board.side); 
      }
    } 
  }
  
  void undo() {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        states[i][j] = new State(pstates[i][j].shade, pstates[i][j].type);
      }
    }
    changeMove();
  }
  
  void activate(int i, int j) {    
    State state = states[i][j];
    char shade = state.shade;
    char type = state.type;
    if ((move == 'W' && shade == 'B') || (move == 'B' && shade == 'W') || type == 'V') return;
    else {    on = true;
    active = new Pair(i, j);
    free = new ArrayList<Pair>();
    perilous = new ArrayList<Pair>();
    
      if (type == 'P') {  //Pawn      
        if (shade == 'W') {
          if (valid(i - 1, j) && states[i - 1][j].type == 'V') {
            free.add(new Pair(i - 1, j));
            if (i == 6) free.add(new Pair(i - 2, j));
          }
        
          if (valid(i - 1, j + 1) && states[i - 1][j + 1].shade == 'B') {
            perilous.add(new Pair(i - 1, j + 1));
          }
        
          if (valid(i - 1, j - 1) && states[i - 1][j - 1].shade == 'B') {
            perilous.add(new Pair(i - 1, j - 1));
          }
        }
      
        if (shade == 'B') {
          if (valid(i + 1, j) && states[i + 1][j].type == 'V') {
            free.add(new Pair(i + 1, j));
            if (i == 1) free.add(new Pair(i + 2, j));
          }
        
          if (valid(i + 1, j + 1) && states[i + 1][j + 1].shade == 'W') {
            perilous.add(new Pair(i + 1, j + 1));
          }
        
          if (valid(i + 1, j - 1) && states[i + 1][j - 1].shade == 'W') {
            perilous.add(new Pair(i + 1, j - 1));
          }
        }
      }
    
      if (type == 'R') {  // Rook
        horiverTraverse(i, j, shade, type);
      }
    
      if (type == 'K') {  // Knight   
          for (int di = - 2; di <= 2; di++) {
            for (int dj = - 2; dj <= 2; dj++) {
              if (abs(di) + abs(dj) == 3) {
                if (valid(i + di, j + dj)) {
                  char t = states[i + di][j + dj].type;
                  if (t == 'V') free.add(new Pair(i + di, j + dj));
                  if ((shade == 'W' && t == 'B') || (shade == 'B' && t == 'W')) perilous.add(new Pair(i + di, j + dj));
                }
              }
            }
          }
        }
    
      if (type == 'B') {  // Bishop
        diagTraverse(i, j, shade, type);
      }
    
      if (type == 'Q') {  // Queen
        horiverTraverse(i, j, shade, type);
        diagTraverse(i, j, shade, type);
      }
    
      if (type == 'E') {  // King as Emperor
        for (int k = -1; k <= 1; k++) {
          for (int l = -1; l <= 1; l++) {
            if ((abs(k) + abs(l)) != 0 && valid(i + k, j + l)) {
              if (board.states[i + k][j + l].type == 'V') free.add(new Pair(i + k, j + l));
              if ((shade == 'B' && board.states[i + k][j + l].shade == 'W') || (shade == 'W' && board.states[i + k][j + l].shade == 'B')) {
                perilous.add(new Pair(i + k, j + l));
              }
            }
          }
        }
      }
    }
  }
  
  boolean valid(int i, int j) {
    return (i >= 0 && i < 8 && j >= 0 && j < 8);
  }
  
  void horiverTraverse(int i, int j, char shade, char type) {
    for (int k = i + 1; valid(k, j); k++) {
        if (states[k][j].type == 'V') {
          free.add(new Pair(k, j));
        }
        else {
          if (shade == 'W' && states[k][j].shade == 'B') {
            perilous.add(new Pair(k, j));
          }
          if (shade == 'B' && states[k][j].shade == 'W') {
            perilous.add(new Pair(k, j));
          }
          break;
        }
      }
      
      for (int k = i - 1; valid(k, j); k--) {
        if (states[k][j].type == 'V') {
          free.add(new Pair(k, j));
        }
        else {
          if (shade == 'W' && states[k][j].shade == 'B') {
            perilous.add(new Pair(k, j));
          }
          if (shade == 'B' && states[k][j].shade == 'W') {
            perilous.add(new Pair(k, j));
          }
          break;
        }
      }
      
      for (int k = j + 1; valid(i, k); k++) {
        if (states[i][k].type == 'V') {
          free.add(new Pair(i, k));
        }
        else {
          if (shade == 'W' && states[i][k].shade == 'B') {
            perilous.add(new Pair(i, k));
          }
          if (shade == 'B' && states[i][k].shade == 'W') {
            perilous.add(new Pair(i, k));
          }
          break;
        }
      }
      
      for (int k = j - 1; valid(i, k); k--) {
        if (states[i][k].type == 'V') {
          free.add(new Pair(i, k));
        }
        else {
          if (shade == 'W' && states[i][k].shade == 'B') {
            perilous.add(new Pair(i, k));
          }
          if (shade == 'B' && states[i][k].shade == 'W') {
            perilous.add(new Pair(i, k));
          }
          break;
        }
      }
  }
  
  void diagTraverse(int i, int j, char shade, char type) {
    for (int k = i - 1, l = j + 1; valid(k, l); k--, l++) {
        if (states[k][l].type == 'V') {
          free.add(new Pair(k, l));
        }
        else {
          if (shade == 'W' && states[k][l].shade == 'B') {
            perilous.add(new Pair(k, l)); 
          }
          if (shade == 'B' && states[k][l].shade == 'W') {
            perilous.add(new Pair(k, l)); 
          }
          break;
        }
      }
      
      for (int k = i + 1, l = j - 1; valid(k, l); k++, l--) {
        if (states[k][l].type == 'V') {
          free.add(new Pair(k, l));
        }
        else {
          if (shade == 'W' && states[k][l].shade == 'B') {
            perilous.add(new Pair(k, l)); 
          }
          if (shade == 'B' && states[k][l].shade == 'W') {
            perilous.add(new Pair(k, l)); 
          }
          break;
        }
      }
      
      for (int k = i + 1, l = j + 1; valid(k, l); k++, l++) {
        if (states[k][l].type == 'V') {
          free.add(new Pair(k, l));
        }
        else {
          if (shade == 'W' && states[k][l].shade == 'B') {
            perilous.add(new Pair(k, l)); 
          }
          if (shade == 'B' && states[k][l].shade == 'W') {
            perilous.add(new Pair(k, l)); 
          }
          break;
        }
      }
      
      for (int k = i - 1, l = j - 1; valid(k, l); k--, l--) {
        if (states[k][l].type == 'V') {
          free.add(new Pair(k, l));
        }
        else {
          if (shade == 'W' && states[k][l].shade == 'B') {
            perilous.add(new Pair(k, l)); 
          }
          if (shade == 'B' && states[k][l].shade == 'W') {
            perilous.add(new Pair(k, l)); 
          }
          break;
        }
      }
  }
  
  void changeMove() {
    if (move == 'W') move = 'B';
    else move = 'W';
  }
}

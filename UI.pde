void mousePressed() {
  
  int j = mouseX/board.side;
  int i = mouseY/board.side;
  
  if (!board.on) board.activate(i, j);
  else {
    boolean done = false;
    for (int k = 0; k < 8; k++) {
      for (int l = 0; l < 8; l++) {
        board.pstates[k][l] = new State(board.states[k][l].shade, board.states[k][l].type);
      }
    }
    
    for (Pair pair : board.free) {
      if (pair.first == i && pair.second == j) {
        int k = board.active.first;
        int l = board.active.second;
        State state = board.states[k][l];
        board.states[i][j] = new State(state.shade, state.type);
        board.states[k][l] = new State('G', 'V');
        board.on = false;
        done = true;
        board.changeMove();
        break;
      }
    }
    
    if (!done) {
      for (Pair pair : board.perilous) {
        if (pair.first == i && pair.second == j) {
          int k = board.active.first;
          int l = board.active.second;
          State state = board.states[k][l];
          board.states[i][j] = new State(state.shade, state.type);
          board.states[k][l] = new State('G', 'V');
          board.on = false;
          done = true;
          board.changeMove();
          break;
        }
      }
    }
    
    if (!done) board.activate(i, j);
  }
}

void keyPressed() {
  if ((key == 'R' || key == 'r' || key == 'S' || key == 's') && !board.on) {
    board.undo();
  }
}

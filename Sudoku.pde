Board gameboard;

void setup() {
  //window needs to be a square
  size(800, 800);
  background(255);
  fill(0);
  gameboard = new Board();
}

void draw() {
  background(255);
  gameboard.display();
}

void mousePressed() {
  gameboard.updateSelection();
}

void keyTyped() {
  gameboard.handleInput();
}

public class Board {
  float boardSize;
  float buffer;
  float cellSize;
  int solutionCount;
  Cell[] cells = new Cell[81];

  public Board() {
    //the boardsize is the width minus a buffer
    this.buffer = 20;
    this.boardSize = width - (buffer * 2);
    this.cellSize = boardSize/9.0;
    this.solutionCount = 0;
    for (int i=0; i<cells.length; i++) {
      cells[i] = new Cell(cellSize, buffer+cellSize*(i%9), buffer+cellSize*floor(i/9));
    }
  }

  public void display() {
    //draw the cells
    for (int i=0; i<cells.length; i++) {
      cells[i].display();
    }
    //draw the outline of the board
    strokeWeight(5);
    line(buffer, buffer, width-buffer, buffer);
    line(buffer, buffer, buffer, height-buffer);
    line(width-buffer, height-buffer, width-buffer, buffer);
    line(width-buffer, height-buffer, buffer, height-buffer);

    //draw the inner bold lines
    strokeWeight(3);
    line(buffer+boardSize/3.0, buffer, buffer+boardSize/3.0, height-buffer);
    line(buffer+(2.0/3.0)*boardSize, buffer, buffer+boardSize*(2.0/3.0), height-buffer);
    line(buffer, buffer+boardSize/3.0, width-buffer, buffer+boardSize/3.0);
    line(buffer, buffer+(2.0/3.0)*boardSize, width-buffer, buffer+(2.0/3.0)*boardSize);

    //draw the inner smaller lines
    strokeWeight(1);
    line(buffer+boardSize*(1.0/9.0), buffer, buffer+boardSize*(1.0/9.0), height-buffer);
    line(buffer+boardSize*(2.0/9.0), buffer, buffer+boardSize*(2.0/9.0), height-buffer);
    line(buffer+boardSize*(4.0/9.0), buffer, buffer+boardSize*(4.0/9.0), height-buffer);
    line(buffer+boardSize*(5.0/9.0), buffer, buffer+boardSize*(5.0/9.0), height-buffer);
    line(buffer+boardSize*(7.0/9.0), buffer, buffer+boardSize*(7.0/9.0), height-buffer);
    line(buffer+boardSize*(8.0/9.0), buffer, buffer+boardSize*(8.0/9.0), height-buffer);

    line(buffer, buffer+boardSize*(1.0/9.0), width-buffer, buffer+boardSize*(1.0/9.0));
    line(buffer, buffer+boardSize*(2.0/9.0), width-buffer, buffer+boardSize*(2.0/9.0));
    line(buffer, buffer+boardSize*(4.0/9.0), width-buffer, buffer+boardSize*(4.0/9.0));
    line(buffer, buffer+boardSize*(5.0/9.0), width-buffer, buffer+boardSize*(5.0/9.0));
    line(buffer, buffer+boardSize*(7.0/9.0), width-buffer, buffer+boardSize*(7.0/9.0));
    line(buffer, buffer+boardSize*(8.0/9.0), width-buffer, buffer+boardSize*(8.0/9.0));
  }

  public void updateSelection() {
    if (mouseX < buffer || mouseX > width-buffer || mouseY < buffer || mouseY > height-buffer) {
      resetSelection();
      return;
    }
    resetSelection();
    int xIndex = floor((mouseX-buffer)/cellSize);
    int yIndex = floor((mouseY-buffer)/cellSize);
    int cellIndex = coordsToIndex(xIndex, yIndex);
    cells[cellIndex].setSelected(true);
  }

  private void resetSelection() {
    for (int i=0; i<cells.length; i++) {
      cells[i].setSelected(false);
    }
  }

  private int coordsToIndex(int xIndex, int yIndex) {
    return yIndex*9 + xIndex;
  }

  public void handleInput() {
    if (key=='s') {
      solveBoard();
    }
    if(key=='n') {
      println(numSolutions()); 
    }
    if(key=='g') {
      generateBoard(10,5); 
    }
    for (int i=0; i<cells.length; i++) {
      if (cells[i].getSelected()) {
        cells[i].setContentsByKey(key);
      }
    }
  }

  public boolean checkBoard(Cell[] currentList) {
    for (int i=0; i<9; i++) {
      if (!checkCol(currentList, i)||!checkRow(currentList, i)||!checkBox(currentList, i)) {
        return false;
      }
    }
    return true;
  }

  public boolean checkCol(Cell[] currentList, int col) {
    IntList workingList = new IntList();
    for (int i=0; i<9; i++) {
      int workingIndex = col + i*9;
      //we want to make a list of all the values in a column, but only if they aren't 0
      //if we add a value that is already in the list, then the column is invalid
      //if we make it all the way through the list then the column is valid
      //could add some more checks about being a completed column.
      if (currentList[workingIndex].getContents() != 0) {
        if (workingList.hasValue(currentList[workingIndex].getContents())) {
          return false;
        } else {
          workingList.append(currentList[workingIndex].getContents());
        }
      }
    } 
    return true;
  }

  public boolean checkRow(Cell[] currentList, int row) {
    //this is the same as check col expect a different working index
    IntList workingList = new IntList();
    for (int i=0; i<9; i++) {
      int workingIndex = i + row*9;
      if (currentList[workingIndex].getContents() != 0) {
        if (workingList.hasValue(currentList[workingIndex].getContents())) {
          return false;
        } else {
          workingList.append(currentList[workingIndex].getContents());
        }
      }
    }  
    return true;
  }

  public boolean checkBox(Cell[] currentList, int box) {
    //this is the same as check col expect a different working index
    IntList workingList = new IntList();
    for (int i=0; i<9; i++) {
      //the working index takes the box and the counter and loops through the cells in each box
      //box%3*3 will set the correct x offset because each box is 3 wide
      //floor(box/3)*3 will set correct y offset because boxes are 3 high
      int workingIndex = coordsToIndex((box%3)*3+i%3, (floor(box/3))*3 + floor(i/3));
      if (currentList[workingIndex].getContents() != 0) {
        if (workingList.hasValue(currentList[workingIndex].getContents())) {
          return false;
        } else {
          workingList.append(currentList[workingIndex].getContents());
        }
      }
    }  
    return true;
  }
  //TODO generate all(?) solutions, or at least check if there is more than 1 solution
  public boolean solveBoard() {
    if (boardFull(cells)) {
      return true;
    }
    for (int i=0; i<cells.length; i++) {
      if (cells[i].getContents() == 0) {
        for (int j=1; j<10; j++) {
          //println("Trying " + j + " in cell " + i);
          cells[i].setContents(j);
          if (checkBoard(cells)) {
            //println("Board is valid");
            if (solveBoard()) {
              return true;
            } else {
              cells[i].setContents(0);
            }
          }
        }
        cells[i].setContents(0);
        return false;
      }
    }
    return true;
  }

  private boolean boardFull(Cell[] currentCells) {
    for (int i=0; i<currentCells.length; i++) {
      if (currentCells[i].getContents()==0) {
        return false;
      }
    }
    return true;
  }
  
  public void generateBoard(int seed, int numBlankSpaces) {
    clearBoard(); 
    for(int i=0; i<seed; i++) {
       int currentCell = int(random(81));
       int guess = int(random(9));
       cells[currentCell].setContents(guess);
    }
    if(!solveBoard()) {
      //if the board isn't solvable, try again with one less guesed spot
      generateBoard(seed - 1, numBlankSpaces); 
    }
   //This is wrong, it doesn't listen to numBlankSpaces
   while(true) {
     int tempIndex = floor(random(81));
     int tempContents = cells[tempIndex].getContents();
     cells[tempIndex].setContents(0);
     if(numSolutions() != 1 || numBlankSpaces < 0) {
        cells[tempIndex].setContents(tempContents);
        break;
     }
     numBlankSpaces--;
   }
    //TODO need to find a way to remove cells and still check if there is only one solution...
    
    
    
    
    //This is the last thing to do is to make it so we can't change the starting numbers
    for(int i=0; i< cells.length; i++) {
      if(cells[i].getContents() != 0) {
        cells[i].setModable(false);
      }
    }
  }
  
  public void clearBoard() {
    for(int i=0; i<cells.length;i++){
      cells[i].setContents(0); 
    }
  }
  
  private int numSolutions() { 
    int numEmptyCells = 0;
    for(int i=0; i<cells.length;i++){
       if(cells[i].getContents() == 0){
         numEmptyCells++; 
       }
    }
    solutionCount = 0;
    //println(solutionCount);
    Cell[] tempCells = new Cell[81];
    contentCopy(cells, tempCells);
    helperSolver(tempCells,0);
    //Divide the colution count by the number of empty cells that we started with because each pass through helper solver with a correct solution will leave one out from the subtraction
    println(numEmptyCells);
    
    return solutionCount;
  }
  
  
  //I'm not sure how this works, but if there is more than one solution, then the num solutions will be less than numEmptyCells
  //I have a theory that this is because when more than one solution is valid, the program will call more times and so will check through more wrong solutions
  private void helperSolver(Cell[] currentList, int index) {
    if(boardFull(currentList)){
      //println("Board full");
      solutionCount++;
      return;
    }
    for(int i=index;i<currentList.length;i++){
      if(currentList[i].getContents() == 0) {
        for(int j = 1; j < 10; j++) {
          Cell[] temp = new Cell[81];
          contentCopy(currentList,temp);
          temp[i].setContents(j);
          //println("Checking " + j + " at cell " + i);
          if(checkBoard(temp)){
            //println("Valid board");
            helperSolver(temp,i);
          }
        }
      }
    }
    
  }
  
  private void contentCopy(Cell[] source, Cell[] dest) {
    for(int i = 0; i<source.length;i++){
      dest[i] = new Cell(0,0,0);
      dest[i].setContents(source[i].getContents());
    }
  }
}

public class Cell {
  float cellSize;
  PVector location;
  int contents;
  boolean selected = false;
  boolean modable = true;

  public Cell(float cellSize, float xLocation, float yLocation) {
    this.cellSize = cellSize;
    this.location = new PVector(xLocation, yLocation);
    this.contents = 0;
  }

  public boolean getSelected() {
    return selected;
  }

  public void setSelected(boolean newValue) {
    selected = newValue;
  }
  

  public void display() {

    //TODO find a nicer color and maybe a nice animation
    if (selected) {
      fill(0, 15, 255);
      square(location.x, location.y, cellSize);
      fill(0);
    }
    //don't display a number if the contents are 0
    if (contents == 0) {
      return;
    }
    if(modable) {
      fill(75); 
    }else {
      fill(0); 
    }
    //TODO tweak these settings and have them adjust ot screen size
    textSize(50);
    textAlign(CENTER, CENTER);
    text(contents, location.x + cellSize/2.0, location.y + cellSize/2.0);
    fill(0);
  }

  public void setContentsByKey(int newValue) {
    //key returns a char with the input, this checks to make sure it is 1-9 or else ignores it
    //TODO add backspace to reset contents to 0
    if (newValue > 48 && newValue < 59 && modable) {
      contents = newValue-48;
    }
    if (newValue == BACKSPACE){
      contents = 0; 
    }
  }

  public int getContents() {
    return contents;
  }

  public void setContents(int newValue) {
    contents = newValue;
  }

  public boolean getModable() {
    return modable;
  }

  public void setModable(boolean newValue) {
    modable = newValue;
  }
}

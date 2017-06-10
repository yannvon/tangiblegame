PShape R2D2White;
PShape R2D2Red;
PShape R2D2Green;
PShape BB8Head;

float R2D2Scale = 1.9;

//Method that loads the R2D2 shape
void loadDroidShapes() {
  R2D2White = loadShape("R2D2White.obj");
  R2D2Red = loadShape("R2D2Red.obj");
  R2D2Green = loadShape("R2D2Green.obj");
  BB8Head = loadShape("bb8Head.obj");
}

void BB8HeadAt(PVector position){
  game.pushMatrix();
  game.translate(position.x, -2*RADIUS+1, position.z);
  game.rotateX(PI);
  game.rotateY(3*PI/2);
  game.scale(6);
  game.shape(BB8Head);
  game.popMatrix();
}

void R2D2RedAt(PVector position){
  game.pushMatrix();
  game.translate(position.x, 0, position.z);
  game.rotateX(PI);
  game.rotateY(3*PI/2);
  game.scale(R2D2Scale);
  game.shape(R2D2Red);
  game.popMatrix();
}

void R2D2GreenAt(PVector position){
  game.pushMatrix();
  game.translate(position.x, 0, position.z);
  game.rotateX(PI);
  game.rotateY(3*PI/2);
  game.scale(R2D2Scale);
  game.shape(R2D2Green);
  game.popMatrix();
}

void R2D2WhiteAt(PVector position){
  game.pushMatrix();
  game.translate(position.x, 0, position.z);
  game.rotateX(PI);
  game.rotateY(3*PI/2);
  game.scale(R2D2Scale);
  game.shape(R2D2White);
  game.popMatrix();
}
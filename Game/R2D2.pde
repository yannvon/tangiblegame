PShape R2D2White;
PShape R2D2Red;
PShape R2D2Green;

float R2D2Scale = 1.9;

//Method that loads the R2D2 shape
void loadR2D2() {
  R2D2White = loadShape("R2D2White.obj");
  R2D2Red = loadShape("R2D2Red.obj");
  R2D2Green = loadShape("R2D2Green.obj");
}

void R2D2RedAt(PVector position){
  pushMatrix();
  translate(position.x, 0, position.z);
  rotateX(PI);
  rotateY(3*PI/2);
  scale(R2D2Scale);
  shape(R2D2Red);
  popMatrix();
}

void R2D2GreenAt(PVector position){
  pushMatrix();
  translate(position.x, 0, position.z);
  rotateX(PI);
  rotateY(3*PI/2);
  scale(R2D2Scale);
  shape(R2D2Green);
  popMatrix();
}

void R2D2WhiteAt(PVector position){
  pushMatrix();
  translate(position.x, 0, position.z);
  rotateX(PI);
  rotateY(3*PI/2);
  scale(R2D2Scale);
  shape(R2D2White);
  popMatrix();
}
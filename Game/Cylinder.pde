// --- CYLINDER CONSTANTS ---
final float cylinderBaseSize = 30;
final float cylinderHeight = 30;
final int cylinderResolution = 40;
PShape openCylinder = new PShape();
PShape side = new PShape();

//Method that loads a Cylinder at the beginning of the game
void loadCylinder() {
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];

  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }

  // draw the border of the cylinder  
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  openCylinder.endShape();
  openCylinder.setFill(OBJECT_COLOR);

  // draw top/bottom of cylinder
  side = createShape();
  side.beginShape(TRIANGLE);
  for (int i = 0; i < x.length; i++) {
    side.vertex(x[i], y[i], 0);
    side.vertex(0, 0, 0);
    if (i!=x.length-1)side.vertex(x[i+1], y[i+1], 0);
    else side.vertex(x[0], y[0], 0);
  }
  side.endShape();
  side.setFill(OBJECT_COLOR);
}

//Draw a cylinder at a position
void cylinderAt(PVector position) {
  pushMatrix();
  translate(position.x, 0, position.z);
  rotateX(PI/2);
  shape(openCylinder);
  shape(side);
  translate(0, 0, cylinderHeight);
  shape(side);
  popMatrix();
}

//Set the color of cylinder
void setCylinderColor(int cylinderColor){
  side.setFill(cylinderColor);
  openCylinder.setFill(cylinderColor);
}
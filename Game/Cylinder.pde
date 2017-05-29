// --- CYLINDER CONSTANTS ---
final float CYLINDER_BASE_SIZE = 20;
final float CYLINDER_HEIGHT = 30;
final int CYLINDER_RESOLUTION = 40;
PShape openCylinder = new PShape();
PShape side = new PShape();

// --- Method that loads a Cylinder at the beginning of the game ---
void loadCylinder() {
  float angle;
  float[] x = new float[CYLINDER_RESOLUTION + 1];
  float[] y = new float[CYLINDER_RESOLUTION + 1];

  // get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / CYLINDER_RESOLUTION) * i;
    x[i] = sin(angle) * CYLINDER_BASE_SIZE;
    y[i] = cos(angle) * CYLINDER_BASE_SIZE;
  }

  // draw the border of the cylinder  
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(x[i], y[i], CYLINDER_HEIGHT);
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

// --- Draw a cylinder at a position ---
void cylinderAt(PVector position) {
  pushMatrix();
  translate(position.x, 0, position.z);
  rotateX(PI/2);
  shape(openCylinder);
  shape(side);
  translate(0, 0, CYLINDER_HEIGHT);
  shape(side);
  popMatrix();
}

// --- Set the color of the cylinder ---
void setCylinderColor(int cylinderColor){
  side.setFill(cylinderColor);
  openCylinder.setFill(cylinderColor);
}
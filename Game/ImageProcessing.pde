import processing.video.*;

class ImageProcessing extends PApplet {
  Movie cam;
  PImage img = new PImage();
  List<PVector> quads;

  void settings() {
    size(200, 300);
  }
  void setup() {
    background(0);
    // --- setup camera ---
    cam = new Movie(this, "C:\\Users\\Yann\\Google Drive\\EPFL_Semestre4\\Introduction à l'informatique visuelle\\css211_game\\Game\\data\\testvideo.avi"); //Put the video in the same directory
    cam.loop();
  }
  void draw() {
    if (cam.available() == true) {
      cam.read();
    }
    img = cam.get();
    quads = findCorners(img);
    if (quads.size() == 4) {
      PVector rotation = computeRotation(quads);
      angleX = rotation.x;
      angleZ = rotation.y;

      if (angleX < -PI/2) angleX += PI;
      else if (angleX > +PI/2) angleX -= PI;
      if (angleZ < -PI/2) angleZ += PI;
      else if (angleZ > PI/2) angleZ -=PI;
    }
  }
}
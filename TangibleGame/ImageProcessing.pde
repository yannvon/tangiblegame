import processing.video.*;

class ImageProcessing extends PApplet {
  Movie mov;
  Capture cam;
  PImage tmpImg;
  PImage img = new PImage();
  List<PVector> quads;

  void settings() {
  }
  
  void setup() {
    // --- chose between cam or video ---
    if (grading) {
      mov = new Movie(this, videoPath);
      mov.loop();
    } else {
      String[] cameras = Capture.list();
      if (cameras.length == 0) {
        println("There are no cameras available for capture.");
        exit();
      } else {
        println("Available cameras:");
        for (int i = 0; i < cameras.length; i++) {
          println(cameras[i]);
        }
        cam = new Capture(this, cameras[0]);
        cam.start();
      }
    }
  }
  void draw() {
    if (grading) {
      if (mov.available() == true) {
        mov.read();
      }
      tmpImg = mov.get();
    } else {
    if (cam.available() == true) {
        cam.read();
      }
      tmpImg = cam.get();
    }
    
    quads = findCorners(tmpImg);
    img = tmpImg;
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
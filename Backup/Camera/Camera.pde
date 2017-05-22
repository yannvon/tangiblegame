import processing.video.*;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.ThreadLocalRandom;

// --- Constants ---
PImage img;
float discretizationStepsPhi = 0.06f;
float discretizationStepsR = 2.5f;
int minVotes =150;
int nlines = 5;
int regionRadius = 10;

// --- Variables ---
Capture cam;

// --- Trig Optimisation ---
Trig t;

void settings() {
  fullScreen();
}
void setup() {
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
  t = new Trig();
}
void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();

  // OPTION 1
  // --- Entire Pipeline Displayed ---
  // 1) Input Image
  image(img, 0, 0);

  // 2) Hue/Brightness/Saturation Threshhold
  img = thresholdHSB(img, 50, 143, 40, 225, 40, 220);
  image(img, 640, 0);

  // 3) Blob Detection
  img = findConnectedComponents(img, true);
  image(img, 1280, 0);

  // 4) Blurring (assumes grayscale)
  img = convolute(img);
  image(img, 0, 480);

  // 5) Edge Detection
  img = scharr(img);
  image(img, 640, 480);

  // 6) Low brightness supression
  img = thresholdBrightness(img, 100);
  image(img, 1280, 480);

  // 7) Hough transform
  List<PVector> lines = hough(img, nlines, regionRadius);
  plotLines(img, lines);

  // 8) Compute quad
  QuadGraph quadgraph = new QuadGraph();
  List<PVector> quads = quadgraph.findBestQuad(lines, img.width, img.height, img.width*img.height, 500, true);
  for (PVector quad : quads) {
    fill(255, 0, 0);
    ellipse(quad.x, quad.y, 15, 15);
  }

  // OPTION 2
  /*
  PImage pipe = pipeline(img);
   image(pipe, 0, 0);
   plotLines(pipe, hough(pipe));
   */
} 



PImage pipeline(PImage img) {
  return scharr(thresholdBrightness(convolute(findConnectedComponents(thresholdHSB(img, 50, 143, 100, 255, 50, 170), true)), 100));
  // ---BUGS TO RESOLVE ---
  //FIXME scharr before brightness in pipeline ? (according to week11 pdf)
  //FIXME rename convolute to blurr (or define some filters as constants and give it as param)
  //FIXME blur sets border to white pixels?
  //FIXME blob doesnt work for black image
}
import processing.video.*;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.ThreadLocalRandom;

// --- OpenCV Imports ---
import gab.opencv.*;
OpenCV opencv;


// --- Constants ---
final float discretizationStepsPhi = 0.06f;
final float discretizationStepsR = 2.5f;
final int minVotes =150;
final int nlines = 4;
final int regionRadius = 10;
final float resizeFactor = 0.7;

// --- Variables ---
PImage img;

// --- Trig Optimisation ---
Trig t;

void settings() {
  size(1920, 600);
}

void setup() {
  opencv = new OpenCV(this, 100, 100);
  img = loadImage("board1.jpg");
  t = new Trig();
  noLoop();
}

void draw() {
  // --- Entire Pipeline Displayed ---
  // 1) Input Image
  image(img, 0, 0);

  // 2) Hue/Brightness/Saturation Threshhold
  img = thresholdHSB(img, 50, 143, 30, 255, 30, 170);

  // 3) Blob Detection
  img = findConnectedComponents(img, true);
  PImage blob = img.copy();

  // 4) Blurring (assumes grayscale)
  img = convolute(img);

  // 5) Edge Detection
  img = scharr(img);

  // 6) Low brightness supression
  img = thresholdBrightness(img, 110);
  PImage threshBright = img.copy();

  // 7) Hough transform
  List<PVector> lines = hough(img, nlines, regionRadius);
  
  // 8) Plot lines
  plotLines(img, lines);

  // 9) Compute quad
  QuadGraph quadgraph = new QuadGraph();
  List<PVector> quads = quadgraph.findBestQuad(lines, img.width, img.height, img.width*img.height, 500, false);
  for (PVector quad : quads) {
    fill(255, 0, 0);
    ellipse(quad.x, quad.y, 15, 15);
  }  
  
  // 10) Hide lines from the rest of the image
  fill(0);
  rect(img.width, 0, 1920 - img.width, img.height);

  // 11) Display the corresponding steps, we chose to resize the images such that they fit in an usual 1920*X screen
  blob.resize((int)(img.width * resizeFactor), (int)(img.height * resizeFactor));
  image(blob, img.width, (img.height - blob.height) / 2);
  threshBright.resize((int)(img.width * resizeFactor), (int)(img.height * resizeFactor));
  image(threshBright, img.width + blob.width, (img.height - threshBright.height) / 2);
  TwoDThreeD twoDThreeD = new TwoDThreeD(img.width, img.height, 0);
  List<PVector> pointsHomogeneous = new ArrayList<PVector>();
  for(PVector point : quads){
    pointsHomogeneous.add(new PVector(point.x, point.y, 1)); 
  }
  PVector rotation = twoDThreeD.get3DRotations(pointsHomogeneous);
  println("r_x = "+radToDeg(rotation.x)+"°, r_y = "+radToDeg(rotation.y)+"°, r_z = "+radToDeg(rotation.z)+"°");
}

float radToDeg(float angle){
  return angle * 180 / PI;
}
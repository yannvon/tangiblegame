import processing.video.*;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.ThreadLocalRandom;

// --- Constants ---
float discretizationStepsPhi = 0.06f;
float discretizationStepsR = 2.5f;
int minVotes =150;
int nlines = 4;
int regionRadius = 10;

// --- Variables ---
PImage img;

// --- Trig Optimisation ---
Trig t;

// ---BUGS TO RESOLVE ---
//FIXME scharr before brightness in pipeline ? (according to week11 pdf)
//FIXME rename convolute to blurr (or define some filters as constants and give it as param)
//FIXME blur sets border to white pixels?
//FIXME blob doesnt work for black image


void settings() {
  size(2400, 600);
}
void setup() {
  img = loadImage("board3.jpg");
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
  PImage blob = img;

  // 4) Blurring (assumes grayscale)
  img = convolute(img);

  // 5) Edge Detection
  img = scharr(img);
  PImage scharr = img;

  // 6) Low brightness supression
  img = thresholdBrightness(img, 110);
  PImage threshBright = img;

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


  // 9) Display the corresponding steps
  image(blob, 800, 0);
  image(threshBright, 1400, 0);
} 



PImage pipeline(PImage img) {
  return thresholdBrightness(scharr(convolute(findConnectedComponents(thresholdHSB(img, 50, 143, 100, 255, 50, 170), true))), 100);
}
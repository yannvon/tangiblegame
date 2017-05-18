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
  size(1600, 600);
}
void setup() {
  img = loadImage("board4.jpg");
  t = new Trig();
}
void draw() {
  background(color(0, 0, 0));
  image(img, 0, 0);
  
  PImage pipelined = pipeline(img);
  image(pipelined, 800, 0);

  List<PVector> lines = hough(pipelined, nlines, regionRadius);
  plotLines(pipelined, lines);

  // 8) Compute quad
  QuadGraph quadgraph = new QuadGraph();
  List<PVector> quads = quadgraph.findBestQuad(lines, img.width, img.height, img.width*img.height, 500, true);
  for (PVector quad : quads) {
    fill(255, 0, 0);
    ellipse(quad.x, quad.y, 15, 15);
  }

} 



PImage pipeline(PImage img) {
  return thresholdBrightness(scharr(convolute(findConnectedComponents(thresholdHSB(img, 50, 143, 100, 255, 50, 170), true))), 100);
}
PImage img;
PImage imgCorrect;
HScrollbar thresholdBarL;
HScrollbar thresholdBarR;

void settings() {
  size(800, 600);
  thresholdBarL = new HScrollbar(0, 580, 800, 20);
  thresholdBarR = new HScrollbar(0, 560, 800, 20);
}
void setup() {
  img = loadImage("board1.jpg");
  imgCorrect = loadImage("board1Thresholded.bmp");
}
void draw() {
  background(color(0, 0, 0));
  //image(img, 0, 0);//show image
  PImage img2 = img.copy();//make a deep copy
  PImage img3 = img.copy();//make a deep copy
  img2.loadPixels();// load pixels
  img3.loadPixels();// load pixels
  img3 = thresholdHSB(img2, 100, 200, 100, 255, 45, 100);
  img2.updatePixels();//update pixels
  img3.updatePixels();//update pixels
  image(img2, 0, 0);
  
  thresholdBarL.display();
  thresholdBarR.display();
  thresholdBarL.update();
  thresholdBarR.update();
  println(imagesEqual(img3, imgCorrect));
}

PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    color c = img.pixels[i];
    int value = (minB <= brightness(c) && brightness(c) <= maxB &&
                 minH <= hue(c) && hue(c) <= maxH &&
                 minS <= saturation(c) && saturation(c) <= maxS) ? 255 : 0;
    result.pixels[i] = color (value, value, value);
  }
  return result;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i]))
      return false;
  return true;
}

PImage threshold(PImage img, int threshold) {
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    int value = (brightness(img.pixels[i]) < threshold * thresholdBar.getPos()) ? 0 : 255;
    result.pixels[i] = img.pixels[i];
  }
  return result;
}